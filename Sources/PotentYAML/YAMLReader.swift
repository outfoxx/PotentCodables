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

    guard let parser = Libfyaml.createParser().map(Parser.init) else {
      throw Error.unableToCreateParser
    }
    defer { parser.destroy() }

    return try data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in

      parser.setInput(ptr.bindMemory(to: CChar.self))

      try parser.expect(eventType: FYET_STREAM_START)

      return try YAMLReader(parser: parser, schema: schema).stream()
    }
  }

  let parser: Parser
  let schema: YAMLSchema

  init(parser: Parser, schema: YAMLSchema = .core) {
    self.parser = parser
    self.schema = schema
  }

  private func stream() throws -> YAML.Sequence {

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


  private func document() throws -> YAML {

    let root = try parser.next()
    defer { parser.free(event: root) }

    let document = try value(event: root)

    try parser.expect(eventType: FYET_DOCUMENT_END)

    return document
  }


  private func mapping() throws -> YAML.Mapping {

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


  private func sequence() throws -> YAML.Sequence {

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

  private func scalar(value: String, style: fy_scalar_style, tag: YAML.Tag?, anchor: String?) throws -> YAML {
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

  private func untaggedScalar(
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

  private func boolTaggedScalar(value: String, anchor: String?) throws -> YAML {

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

  private func value(event: Parser.Event) throws -> YAML {
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

      let event: UnsafeMutablePointer<fy_event>

      init(_ event: UnsafeMutablePointer<fy_event>) {
        self.event = event
      }

      var type: fy_event_type { event.pointee.type }

      var anchor: String? {
        guard let token = event.pointee.scalar.anchor else { return nil }
        return String(token: token)
      }

      var tag: String? {
        guard let token = event.pointee.scalar.tag else { return nil }
        return String(token: token)
      }

      var scalar: (String, fy_scalar_style)? {
        guard let token = event.pointee.scalar.value else { return nil }
        return String(token: token).map { ($0, fy_token_scalar_style(token)) }
      }

      var style: fy_node_style {
        return fy_event_get_node_style(event)
      }

    }

    let parser: OpaquePointer

    func setInput(_ bytes: UnsafeBufferPointer<CChar>) {

      fy_parser_set_string(parser, bytes.baseAddress, bytes.count)
    }

    private func nextIfPresent() -> Event? {

      return fy_parser_parse(parser).map(Event.init)
    }

    func next() throws -> Event {

      guard let event = nextIfPresent() else {
        throw error(fallback: .unexpectedEOF)
      }

      return event
    }

    func expect(eventType: fy_event_type) throws {

      let event = try next()
      defer { free(event: event) }

      if event.type != eventType {
        throw error(fallback: .unexpectedEvent)
      }
    }

    func error(fallback: Error) -> Error {

      guard let diag = fy_parser_get_diag(parser) else {
        return fallback
      }

      var prev: UnsafeMutableRawPointer?
      if let error = fy_diag_errors_iterate(diag, &prev) {
        return Error.parserError(message: String(cString: error.pointee.msg),
                                 line: Int(error.pointee.line),
                                 column: Int(error.pointee.column))
      }

      return fallback
    }

    func destroy() {
      fy_parser_destroy(parser)
    }

    func free(event: Event) {
      fy_parser_event_free(parser, event.event)
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
