//
//  YAMLWriter.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Cfyaml
import Foundation
import PotentCodables
import Regex


internal struct YAMLWriter {

  typealias Error = YAMLSerialization.Error

  enum Width: UInt8 {
    case normal = 80
    case wide = 120
    case infinite = 0xff
  }

  struct Options {

    static let `default` = Options()

    var schema: YAMLSchema = .core
    var preferredCollectionStyle: YAML.CollectionStyle = .any
    var preferredStringStyle: YAML.StringStyle = .any
    var json: Bool = false
    var pretty: Bool = true
    var width: Width = .normal
    var sortedKeys: Bool = false
    var explicitDocumentMarkers: Bool = false
  }

  static let disallowedPlainSequencesRegex: Regex = #"(:\s)|(\s#)"#

  public static func hasDisallowedPlainSequences(in string: String) -> Bool {
    return disallowedPlainSequencesRegex.firstMatch(in: string) != nil
  }

  let emitter: OpaquePointer
  let options: Options

  static func write(_ documents: YAML.Sequence, options: Options = .default) throws -> String {
    var output = ""
    try write(documents, options: options) { output += $0 ?? "" }
    return output
  }

  static func write(_ documents: YAML.Sequence,
                    options: Options = Options(),
                    writer: @escaping Libfyaml.EmitterWriter) throws {

    try withUnsafePointer(to: writer) { writerPtr in

      var flags: fy_emitter_cfg_flags
      switch (options.pretty, options.json, options.width) {
      case (true, true, let width):
        flags = FYECF_MODE_JSON | .width(width)
      case (true, false, let width):
        flags = FYECF_MODE_PRETTY | .width(width)
      case (false, true, let width):
        flags = FYECF_MODE_JSON_ONELINE | .width(width)
      case (false, false, let width):
        flags = FYECF_MODE_ORIGINAL | FYECF_INDENT_DEFAULT | .width(width)
      }

      guard let emitter = Libfyaml.createEmitter(flags: flags, output: emitOutput, writer: writerPtr) else {
        throw Error.unableToCreateEmitter
      }
      defer { fy_emitter_destroy(emitter) }

      return try YAMLWriter(emitter: emitter, options: options)
        .emit(documents: documents)
    }
  }

  private func emit(documents: [YAML]) throws {

    let implicitDocumentMarkers = !options.explicitDocumentMarkers && documents.count == 1 ? 1 : 0

    try emit(type: FYET_STREAM_START)

    for document in documents {
      try emit(type: FYET_DOCUMENT_START, args: implicitDocumentMarkers, 0, 0)

      try emit(value: document)

      try emit(type: FYET_DOCUMENT_END, args: implicitDocumentMarkers)
    }

    try emit(type: FYET_STREAM_END)

    try failIfError()
  }

  private func emit(value: YAML) throws {

    switch value {
    case .null(anchor: let anchor):
      try emit(scalar: "null", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .string(let string, style: let style, tag: let tag, anchor: let anchor):
      try emit(string: string, style: style, anchor: anchor, tag: tag?.rawValue)

    case .integer(let integer, anchor: let anchor):
      try emit(scalar: integer.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .float(let float, anchor: let anchor):
      try emit(scalar: float.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .bool(let bool, anchor: let anchor):
      try emit(scalar: bool ? "true" : "false", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .sequence(let sequence, style: let style, tag: let tag, anchor: let anchor):
      try emit(sequence: sequence, style: style, anchor: anchor, tag: tag)

    case .mapping(let mapping, style: let style, tag: let tag, anchor: let anchor):
      try emit(mapping: mapping, style: style, anchor: anchor, tag: tag)

    case .alias(let alias):
      try emit(alias: alias)

    }
  }

  private func emit(mapping: YAML.Mapping, style: YAML.CollectionStyle, anchor: String?, tag: YAML.Tag?) throws {
    try emit(
      type: FYET_MAPPING_START,
      args: style.nodeStyle(preferred: options.preferredCollectionStyle).rawValue,
      anchor.varArg,
      (tag?.rawValue).varArg
    )
    var mapping = mapping
    if options.sortedKeys {
      mapping = mapping.sorted {
        $0.key.description < $1.key.description
      }
    }
    try mapping.forEach { entry in
      try emit(value: entry.key)
      try emit(value: entry.value)
    }
    try emit(type: FYET_MAPPING_END)
  }

  private func emit(sequence: [YAML], style: YAML.CollectionStyle, anchor: String?, tag: YAML.Tag?) throws {
    try emit(
      type: FYET_SEQUENCE_START,
      args: style.nodeStyle(preferred: options.preferredCollectionStyle).rawValue,
      anchor.varArg,
      (tag?.rawValue).varArg
    )
    try sequence.forEach { element in
      try emit(value: element)
    }
    try emit(type: FYET_SEQUENCE_END)
  }

  private func emit(string: String, style: YAML.StringStyle, anchor: String?, tag: String?) throws {

    let stringStyle: YAML.StringStyle
    if style == .any && (options.schema.requiresQuotes(for: string) || Self.hasDisallowedPlainSequences(in: string)) {
      stringStyle = (options.preferredStringStyle.isQuoted ? options.preferredStringStyle : .doubleQuoted)
    }
    else {
      stringStyle = style != .any ? style : options.preferredStringStyle
    }

    let scalarStyle = fy_scalar_style(rawValue: stringStyle.rawValue)

    try emit(scalar: string, style: scalarStyle, anchor: anchor, tag: tag)
  }

  private func emit(scalar: String, style: fy_scalar_style, anchor: String?, tag: String?) throws {

    try scalar.withCString { scalarPtr in
      try anchor.withCString { anchorPtr in
        try tag.withCString { tagPtr in
          try emit(type: FYET_SCALAR, args: style.rawValue, scalarPtr, FY_NT, anchorPtr, tagPtr)
        }
      }
    }
  }

  private func emit(alias: String) throws {
    try alias.withCString { aliasPtr in
      try emit(type: FYET_ALIAS, args: aliasPtr)
    }
  }

  private func emit(type: fy_event_type, args: CVarArg...) throws {
    let res = withVaList(args) { valist in
      fy_emit_vevent(emitter, type, valist)
    }
    if res == -1 {
      throw error()
    }
  }

  private func failIfError() throws {

    guard Libfyaml.hasError(in: fy_emitter_get_diag(emitter)) else {
      return
    }

    throw error()
  }

  private func error() -> Error {

    guard let error = Libfyaml.error(from: fy_emitter_get_diag(emitter)) else {
      return .emitError(message: "Unknown emitter error")
    }

    return .emitError(message: error.message)
  }

  private static let emitOutput: Libfyaml.EmitterOutput = { _, _, str, len, userInfo in

    guard let writer = userInfo?.assumingMemoryBound(to: Libfyaml.EmitterWriter.self).pointee else {
      fatalError()
    }

    guard let str = str else {
      writer(nil)
      return 0
    }

    let strPtr = UnsafeMutableRawPointer(mutating: str)
    writer(String(bytesNoCopy: strPtr, length: Int(len), encoding: .utf8, freeWhenDone: false))
    return len
  }
}


extension Optional where Wrapped: CVarArg {

  var varArg: CVarArg { self ?? unsafeBitCast(0, to: OpaquePointer.self) }

}

extension Optional where Wrapped == String {

  func withCString<Result>(_ body: (UnsafePointer<Int8>) throws -> Result) rethrows -> Result {
    if let str = self {
      return try str.withCString(body)
    }
    else {
      return try body(UnsafePointer<Int8>(unsafeBitCast(0, to: OpaquePointer.self)))
    }
  }

}


extension YAML.CollectionStyle {

  func nodeStyle(preferred: Self) -> fy_node_style {
    switch (self, preferred) {
    case (.any, .any): return FYNS_ANY
    case (.any, .flow), (.flow, _): return FYNS_FLOW
    case (.any, .block), (.block, _): return FYNS_BLOCK
    }
  }

}
