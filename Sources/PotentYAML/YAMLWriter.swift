//
//  YAMLWriter.swift
//  
//
//  Created by Kevin Wooten on 9/2/20.
//

import Foundation
import Cfyaml

struct YAMLWriter {
  
  enum Error: Swift.Error {
    case createEmitterFailed
    case emitFailed
  }
  
  typealias Writer = (String?) -> Void
  
  public static func write(_ documents: [YAML], sortedKeys: Bool = false, writer: @escaping Writer) throws {
    
    func output(emitter: OpaquePointer?, writeType: fy_emitter_write_type,
                str: UnsafePointer<Int8>?, len: Int32,
                userInfo: UnsafeMutableRawPointer?) -> Int32 {
      let writer = userInfo!.assumingMemoryBound(to: Writer.self).pointee
      guard let str = str else {
        writer(nil)
        return 0
      }
      let strPtr = UnsafeMutableRawPointer(mutating: str)
      writer(String(bytesNoCopy: strPtr, length: Int(len), encoding: .utf8, freeWhenDone: false))
      return len
    }
    
    try withUnsafePointer(to: writer) { writerPtr in
      
      var flags: UInt32 = 0
      if sortedKeys {
        flags |= FYECF_SORT_KEYS.rawValue
      }
      
      var emitterCfg = fy_emitter_cfg(flags: fy_emitter_cfg_flags(rawValue: flags), output: output,
                                      userdata: UnsafeMutableRawPointer(mutating: writerPtr), diag: nil)
      
      guard let emitter = fy_emitter_create(&emitterCfg) else {
        throw Error.createEmitterFailed
      }
      defer { fy_emitter_destroy(emitter) }

      emit(emitter: emitter, type: FYET_STREAM_START)
      
      try documents.forEach {
        emit(emitter: emitter, type: FYET_DOCUMENT_START, args: 0, 0, 0)
        
        try emit(emitter: emitter, value: $0, sortedKeys: sortedKeys)
        
        emit(emitter: emitter, type: FYET_DOCUMENT_END)
      }
      
      emit(emitter: emitter, type: FYET_STREAM_END)
    }
    
  }
  
  private static func emit(emitter: OpaquePointer, value: YAML, sortedKeys: Bool) throws {
    
    switch value {
    case .null(anchor: let anchor):
      emit(emitter: emitter, scalar: "null", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .string(let string, style: let style, tag: let tag, anchor: let anchor):
      emit(emitter: emitter, scalar: string, style: fy_scalar_style(rawValue: style.rawValue), anchor: anchor, tag: tag?.rawValue)

    case .integer(let integer, anchor: let anchor):
      emit(emitter: emitter, scalar: integer.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .float(let float, anchor: let anchor):
      emit(emitter: emitter, scalar: float.value, style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .bool(let bool, anchor: let anchor):
      emit(emitter: emitter, scalar: bool ? "true" : "false", style: FYSS_PLAIN, anchor: anchor, tag: nil)

    case .sequence(let sequence, style: let style, tag: let tag, anchor: let anchor):
      emit(emitter: emitter, type: FYET_SEQUENCE_START, args: style.nodeStyle.rawValue, anchor.varArg, (tag?.rawValue).varArg)
      try sequence.forEach { element in
        try emit(emitter: emitter, value: element, sortedKeys: sortedKeys)
      }
      emit(emitter: emitter, type: FYET_SEQUENCE_END)

    case .mapping(var mapping, style: let style, tag: let tag, anchor: let anchor):
      emit(emitter: emitter, type: FYET_MAPPING_START, args: style.nodeStyle.rawValue, anchor.varArg, (tag?.rawValue).varArg)
      if sortedKeys {
        mapping = mapping.sorted { a, b in
          a.key.description < b.key.description
        }
      }
      try mapping.forEach { entry in
        try emit(emitter: emitter, value: entry.key, sortedKeys: sortedKeys)
        try emit(emitter: emitter, value: entry.value, sortedKeys: sortedKeys)
      }
      emit(emitter: emitter, type: FYET_MAPPING_END)

    case .alias(let alias):
      emit(emitter: emitter, type: FYET_ALIAS, args: alias)
      
    }
  }

  private static func emit(emitter: OpaquePointer, scalar: String, style: fy_scalar_style, anchor: String?, tag: String?) {
    scalar.withCString { scalarPtr in
      anchor.withCString { anchorPtr in
        tag.withCString { tagPtr in
          emit(emitter: emitter, type: FYET_SCALAR, args: style.rawValue, scalarPtr, FY_NT, anchorPtr, tagPtr)
        }
      }
    }
  }
  
  private static func emit(emitter: OpaquePointer, type: fy_event_type, args: CVarArg...) {
    withVaList(args) { valist in
      let event = fy_emit_event_vcreate(emitter, type, valist)
      event?.pointee.type = type
      fy_emit_event(emitter, event)
    }
  }
  
}

extension Optional where Wrapped : CVarArg {
  
  var varArg: CVarArg { self ?? unsafeBitCast(0, to: OpaquePointer.self) }
  
}


extension Optional where Wrapped == String {
  
  func withCString<Result>(_ body: (UnsafePointer<Int8>) throws -> Result) rethrows -> Result {
    if let str = self {
      return try str.withCString(body)
    } else {
      return try body(UnsafePointer<Int8>(unsafeBitCast(0, to: OpaquePointer.self)))
    }
  }
  
}

extension YAML.CollectionStyle {
 
  var nodeStyle: fy_node_style {
    switch self {
    case .any: return FYNS_ANY
    case .flow: return FYNS_FLOW
    case .block: return FYNS_BLOCK
    }
  }
  
}
