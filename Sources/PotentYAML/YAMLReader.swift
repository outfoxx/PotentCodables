//
//  YAMLReader.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Cfyaml
import Foundation


internal struct YAMLReader {

  typealias Error = YAMLSerialization.Error

  static func read(data: Data, schema: YAMLSchema = .core) throws -> YAML.Sequence {

    var diagCfg =
      fy_diag_cfg(
        fp: nil,
        output_fn: nil,
        user: nil,
        level: FYET_ERROR,
        module_mask: UInt32.max,
        colorize: false,
        show_source: false,
        show_position: true,
        show_type: false,
        show_module: false,
        source_width: Int32.max,
        position_width: 4,
        type_width: 0,
        module_width: 0
      )
    let diag = fy_diag_create(&diagCfg)
    fy_diag_set_collect_errors(diag, true)
    defer { fy_diag_destroy(diag) }

    var parseCfg = fy_parse_cfg(search_path: nil, flags: FYPCF_QUIET, userdata: nil, diag: diag)

    guard let parser = fy_parser_create(&parseCfg).map({ Parser(rawParser: $0, rawDiag: diag) }) else {
      throw Error.unableToCreateParser
    }

    defer { parser.destroy() }

    return try data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in

      let bytes = ptr.bindMemory(to: Int8.self)

      fy_parser_set_string(parser.rawParser, bytes.baseAddress, bytes.count)

      _ = try parser.expect(eventType: FYET_STREAM_START)

      return try YAMLReader(parser: parser, schema: schema).stream()
    }
  }

  let parser: Parser
  let schema: YAMLSchema

  init(parser: Parser, schema: YAMLSchema = .core) {
    self.parser = parser
    self.schema = schema
  }

  func stream() throws -> YAML.Sequence {

    var documents: YAML.Sequence = []

    while true {

      let event = try parser.next()
      defer { parser.free(event: event) }

      guard event.type != FYET_STREAM_END else {
        break
      }

      if event.type == FYET_DOCUMENT_START {
        documents.append(try document())
      }
      else {
        throw parser.error(fallback: .unexpectedEvent)
      }
    }

    return documents
  }


  func document() throws -> YAML {

    let root = try parser.next()
    defer { parser.free(event: root) }

    let document = try value(event: root)

    _ = try parser.expect(eventType: FYET_DOCUMENT_END)

    return document
  }


  func mapping() throws -> YAML.Mapping {

    var result: YAML.Mapping = []

    while true {

      let event = try parser.next()
      defer { parser.free(event: event) }

      guard event.type != FYET_MAPPING_END else {
        break
      }

      let key = try value(event: event)

      let valEvent = try parser.next()
      defer { parser.free(event: valEvent) }

      let val = try value(event: valEvent)

      result.append(YAML.Mapping.Element(key: key, value: val))
    }

    return result
  }


  func sequence() throws -> YAML.Sequence {

    var result: YAML.Sequence = []

    while true {

      let event = try parser.next()
      defer { parser.free(event: event) }

      guard event.type != FYET_SEQUENCE_END else {
        break
      }

      let val = try value(event: event)

      result.append(val)
    }

    return result
  }

  func scalar(value: String, style: fy_scalar_style, tag: YAML.Tag?, anchor: String?) throws -> YAML {
    guard let stringStyle = YAML.StringStyle(rawValue: style.rawValue) else {
      preconditionFailure("String style not recognized")
    }

    switch tag {
    case .none:
      return try untaggedScalar(value: value, stringStyle: stringStyle, style: style, anchor: anchor)

    case .some(YAML.Tag.null):
      return .null(anchor: anchor)

    case .some(YAML.Tag.bool):
      return try boolTaggedScalar(value: value, anchor: anchor)

    case .some(YAML.Tag.int):
      return .integer(YAML.Number(value), anchor: anchor)

    case .some(YAML.Tag.float):
      return .float(YAML.Number(value), anchor: anchor)

    case .some(let tag):
      return .string(value, style: stringStyle, tag: tag, anchor: anchor)
    }

  }

  func untaggedScalar(
    value: String,
    stringStyle: YAML.StringStyle,
    style: fy_scalar_style,
    anchor: String?
  ) throws -> YAML {

    if style == FYSS_PLAIN {

      if schema.isNull(value) {
        return .null(anchor: anchor)
      }

      if schema.isTrue(value) {
        return .bool(true, anchor: anchor)
      }

      if schema.isFalse(value) {
        return .bool(false, anchor: anchor)
      }

      if schema.isInt(value) {
        return .integer(YAML.Number(value.lowercased(), isInteger: true, isNegative: value.hasPrefix("-")),
                        anchor: anchor)
      }

      if schema.isFloat(value) {
        return .float(YAML.Number(value.lowercased(), isInteger: false, isNegative: value.hasPrefix("-")),
                      anchor: anchor)
      }

    }

    return .string(value, style: stringStyle, tag: nil, anchor: nil)
  }

  func boolTaggedScalar(value: String, anchor: String?) throws -> YAML {

    if let bool = Bool(value.lowercased()) {
      return .bool(bool, anchor: anchor)
    }
    else if value == "1" {
      return .bool(true, anchor: anchor)
    }
    else if value == "0" {
      return .bool(false, anchor: anchor)
    }

    throw Error.invalidTaggedBool
  }

  func value(event: Parser.Event) throws -> YAML {
    switch event.type {
    case FYET_MAPPING_START:
      let value = try mapping()
      return .mapping(value, style: event.style.collectionStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)

    case FYET_SEQUENCE_START:
      let value = try sequence()
      return .sequence(value, style: event.style.collectionStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)

    case FYET_SCALAR:
      guard let (scalarValue, scalarStyle) = event.scalar else {
        return .null(anchor: event.anchor)
      }
      return try scalar(value: scalarValue, style: scalarStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)

    case FYET_ALIAS:
      return YAML.alias(event.anchor ?? "")

    default:
      throw parser.error(fallback: .unexpectedEvent)
    }

  }

  struct Parser {

    struct Event {
      let rawEvent: UnsafeMutablePointer<fy_event>

      var type: fy_event_type { rawEvent.pointee.type }

      var anchor: String? {
        guard let token = rawEvent.pointee.scalar.anchor else { return nil }
        return String(token: token)
      }

      var tag: String? {
        guard let token = rawEvent.pointee.scalar.tag else { return nil }
        return String(token: token)
      }

      var scalar: (String, fy_scalar_style)? {
        guard let token = rawEvent.pointee.scalar.value else { return nil }
        return String(token: token).map { ($0, fy_token_scalar_style(token)) }
      }

      var style: fy_node_style {
        return fy_event_get_node_style(rawEvent)
      }

    }

    let rawParser: OpaquePointer
    let rawDiag: OpaquePointer?

    func nextIfPresent() -> Event? {
      return fy_parser_parse(rawParser).map { Event(rawEvent: $0) }
    }

    func next() throws -> Event {
      guard let event = nextIfPresent() else {
        throw error(fallback: .unexpectedEOF)
      }
      return event
    }

    func expect(eventType: fy_event_type) throws -> Event {

      let event = try next()

      if event.type != eventType {
        throw error(fallback: .unexpectedEvent)
      }

      return event
    }

    func error(fallback: Error) -> Error {
      guard let diag = rawDiag else { return fallback }

      var prev: UnsafeMutableRawPointer?
      if let error = fy_diag_errors_iterate(diag, &prev) {
        return Error.parserError(message: String(cString: error.pointee.msg),
                                 line: Int(error.pointee.line),
                                 column: Int(error.pointee.column))
      }

      return fallback
    }

    func destroy() {
      fy_parser_destroy(rawParser)
    }

    func free(event: Event) {
      fy_parser_event_free(rawParser, event.rawEvent)
    }

  }

}

extension String {

  init?(token: OpaquePointer) {
    var tokenLen = 0
    guard let tokenData = fy_token_get_text(token, &tokenLen) else {
      return nil
    }
    self.init(data: Data(bytes: UnsafeRawPointer(tokenData), count: tokenLen), encoding: .utf8)
  }

}

extension fy_node_style {

  var collectionStyle: YAML.CollectionStyle {
    switch self {
    case FYNS_FLOW: return .flow
    case FYNS_BLOCK: return .block
    default: return .block
    }
  }

}
