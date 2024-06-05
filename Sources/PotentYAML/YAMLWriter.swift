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

internal struct YAMLWriter {

  typealias Error = YAMLSerialization.Error

  typealias Writer = (String?) -> Void

  enum Width {
    case normal
    case wide
    case infinite
  }

  let emitter: OpaquePointer
  let sortedKeys: Bool
  let preferredCollectionStyle: YAML.CollectionStyle
  let preferredStringStyle: YAML.StringStyle

  static func write(_ documents: YAML.Sequence,
                    preferredStyles: (collection: YAML.CollectionStyle, string: YAML.StringStyle) = (.block, .plain),
                    json: Bool = false,
                    pretty: Bool = true,
                    width: Width = .normal,
                    sortedKeys: Bool = false,
                    writer: @escaping Writer) throws {

    func output(
      emitter: OpaquePointer?,
      writeType: fy_emitter_write_type,
      str: UnsafePointer<Int8>?,
      len: Int32,
      userInfo: UnsafeMutableRawPointer?
    ) -> Int32 {
      guard let writer = userInfo?.assumingMemoryBound(to: Writer.self).pointee else {
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

    try withUnsafePointer(to: writer) { writerPtr in

      var flags =
        switch (pretty, json) {
        case (true, true): FYECF_MODE_JSON.rawValue
        case (true, false): FYECF_MODE_PRETTY.rawValue
        case (false, true): FYECF_MODE_JSON_ONELINE.rawValue
        default: FYECF_DEFAULT.rawValue
        }

      switch width {
      case .normal:
        flags |= FYECF_WIDTH_80.rawValue
      case .wide:
        flags |= FYECF_WIDTH_132.rawValue
      case .infinite:
        flags |= FYECF_WIDTH_INF.rawValue
      }

      var emitterCfg = fy_emitter_cfg(
        flags: fy_emitter_cfg_flags(rawValue: flags),
        output: output,
        userdata: UnsafeMutableRawPointer(mutating: writerPtr),
        diag: nil
      )

      guard let emitter = fy_emitter_create(&emitterCfg) else {
        throw Error.unableToCreateEmitter
      }
      defer { fy_emitter_destroy(emitter) }

      let writer = YAMLWriter(
        emitter: emitter,
        sortedKeys: sortedKeys,
        preferredCollectionStyle: preferredStyles.collection,
        preferredStringStyle: preferredStyles.string
      )

      return try writer.emit(documents: documents)
    }
  }

  private func emit(documents: [YAML]) throws {

    emit(type: FYET_STREAM_START)

    for document in documents {
      emit(type: FYET_DOCUMENT_START, args: 0, 0, 0)

      try emit(value: document)

      emit(type: FYET_DOCUMENT_END)
    }

    emit(type: FYET_STREAM_END)
  }

  private func emit(value: YAML) throws {

    switch value {
    case .null(anchor: let anchor):
      emit(scalar: "null", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .string(let string, style: let style, tag: let tag, anchor: let anchor):
      let stringStyle = style != .any ? style : preferredStringStyle
      let scalarStyle =  fy_scalar_style(rawValue: stringStyle.rawValue)
      emit(scalar: string, style: scalarStyle, anchor: anchor, tag: tag?.rawValue)

    case .integer(let integer, anchor: let anchor):
      emit(scalar: integer.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .float(let float, anchor: let anchor):
      emit(scalar: float.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .bool(let bool, anchor: let anchor):
      emit(scalar: bool ? "true" : "false", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .sequence(let sequence, style: let style, tag: let tag, anchor: let anchor):
      try emit(sequence: sequence, style: style, anchor: anchor, tag: tag)

    case .mapping(let mapping, style: let style, tag: let tag, anchor: let anchor):
      try emit(mapping: mapping, style: style, anchor: anchor, tag: tag)

    case .alias(let alias):
      emit(alias: alias)

    }
  }

  private func emit(mapping: YAML.Mapping, style: YAML.CollectionStyle, anchor: String?, tag: YAML.Tag?) throws {
    emit(
      type: FYET_MAPPING_START,
      args: style.nodeStyle(preferred: preferredCollectionStyle).rawValue,
      anchor.varArg,
      (tag?.rawValue).varArg
    )
    var mapping = mapping
    if sortedKeys {
      mapping = mapping.sorted {
        $0.key.description < $1.key.description
      }
    }
    try mapping.forEach { entry in
      try emit(value: entry.key)
      try emit(value: entry.value)
    }
    emit(type: FYET_MAPPING_END)
  }

  private func emit(sequence: [YAML], style: YAML.CollectionStyle, anchor: String?, tag: YAML.Tag?) throws {
    emit(
      type: FYET_SEQUENCE_START,
      args: style.nodeStyle(preferred: preferredCollectionStyle).rawValue,
      anchor.varArg,
      (tag?.rawValue).varArg
    )
    try sequence.forEach { element in
      try emit(value: element)
    }
    emit(type: FYET_SEQUENCE_END)
  }

  private func emit(
    scalar: String,
    style: fy_scalar_style,
    anchor: String?,
    tag: String?
  ) {
    scalar.withCString { scalarPtr in
      anchor.withCString { anchorPtr in
        tag.withCString { tagPtr in
          emit(type: FYET_SCALAR, args: style.rawValue, scalarPtr, FY_NT, anchorPtr, tagPtr)
        }
      }
    }
  }

  private func emit(
    alias: String
  ) {
    alias.withCString { aliasPtr in
      emit(type: FYET_ALIAS, args: aliasPtr)
    }
  }

  private func emit(type: fy_event_type, args: CVarArg...) {
    withVaList(args) { valist in
      let event = fy_emit_event_vcreate(emitter, type, valist)
      fy_emit_event(emitter, event)
    }
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
