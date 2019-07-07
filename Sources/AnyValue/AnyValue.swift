//
//  AnyValue.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/15/19.
//

import Foundation


public enum AnyValue : Hashable {

  public enum Error : Swift.Error {
    case unsupportedType
    case unsupportedValue(Any)
  }

  case `nil`
  case bool(Bool)
  case string(String)
  case int8(Int8)
  case int16(Int16)
  case int32(Int32)
  case int64(Int64)
  case uint8(UInt8)
  case uint16(UInt16)
  case uint32(UInt32)
  case uint64(UInt64)
  case float(Float)
  case double(Double)
  case decimal(Decimal)
  case data(Data)
  case url(URL)
  case uuid(UUID)
  case date(Date)
  case array([AnyValue])
  case dictionary([String: AnyValue])

  /// Wraps the value into an equivalent `AnyValue` tree
  public static func wrapped(_ value: Any?) throws -> AnyValue {
    guard let value = value else { return .nil }
    switch value {
    case let val as String: return .string(val)
    case let val as Bool: return .bool(val)
    case let val as NSNumber:
      /// Use NSNumber's type identifier to determine exact numeric type because
      /// Swift's `as`, `is` and `type(of:)` all coerce numeric types into the
      /// requested type if they are compatible
      switch UnicodeScalar(Int(val.objCType.pointee)) {
      case "c": return .int8(val.int8Value)
      case "C": return .uint8(val.uint8Value)
      case "s": return .int16(val.int16Value)
      case "S": return .uint16(val.uint16Value)
      case "i": return .int32(val.int32Value)
      case "I": return .uint32(val.uint32Value)
      case "l": return MemoryLayout<Int>.size == 8 ? .int64(Int64(val.intValue)) : .int32(Int32(val.intValue))
      case "L": return MemoryLayout<Int>.size == 8 ? .uint64(UInt64(val.uintValue)) : .uint32(UInt32(val.intValue))
      case "q": return .int64(val.int64Value)
      case "Q": return .uint64(val.uint64Value)
      case "f": return .float(val.floatValue)
      case "d": return .double(val.doubleValue)
      default: fatalError("Invalid NSNumber type identifier")
      }
    case let val as Decimal: return .decimal(val)
    case let val as Data: return .data(val)
    case let val as URL: return .url(val)
    case let val as UUID: return .uuid(val)
    case let val as Date: return .date(val)
    case let val as [Any]: return .array(try val.map { try wrapped($0) })
    case let val as [String: Any]: return .dictionary(try val.mapValues { try wrapped($0) })
    default: throw Error.unsupportedValue(value)
    }
  }

}


extension AnyValue : Value {

  public var isNull: Bool {
    guard case .nil = self else { return false }
    return true
  }

  public var unwrapped: Any? {
    switch self {
    case .nil: return nil
    case .bool(let value): return value
    case .string(let value): return value
    case .int8(let value): return value
    case .int16(let value): return value
    case .int32(let value): return value
    case .int64(let value): return value
    case .uint8(let value): return value
    case .uint16(let value): return value
    case .uint32(let value): return value
    case .uint64(let value): return value
    case .float(let value): return value
    case .double(let value): return value
    case .decimal(let value): return value
    case .data(let value): return value
    case .url(let value): return value
    case .uuid(let value): return value
    case .date(let value): return value
    case .array(let value): return Array(value.map { $0.unwrapped })
    case .dictionary(let value): return Dictionary(uniqueKeysWithValues: value.map { key, value in (key, value.unwrapped) })
    }
  }

  /// Unwraps all the values in the tree, filtering nils present in `array` or `dictionary` values
  public var unwrappedValues: Any? {
    switch self {
    case .nil: return nil
    case .bool(let value): return value
    case .string(let value): return value
    case .int8(let value): return value
    case .int16(let value): return value
    case .int32(let value): return value
    case .int64(let value): return value
    case .uint8(let value): return value
    case .uint16(let value): return value
    case .uint32(let value): return value
    case .uint64(let value): return value
    case .float(let value): return value
    case .double(let value): return value
    case .decimal(let value): return value
    case .data(let value): return value
    case .url(let value): return value
    case .uuid(let value): return value
    case .date(let value): return value
    case .array(let value): return value.compactMap { $0.unwrappedValues }
    case .dictionary(let value): return value.compactMapValues { $0.unwrappedValues }
    }
  }

}


/**
 * Decodable support
 **/

extension AnyValue : Decodable {

  public init(from decoder: Decoder) throws {

    // Try keyed container
    if let container = try? decoder.container(keyedBy: AnyCodingKey.self) {

      var dictionary = [String: AnyValue]()
      for key in container.allKeys {
        dictionary[key.stringValue] = try container.decode(AnyValue.self, forKey: key)
      }

      self = .dictionary(dictionary)
      return
    }

    // Try unkeyed container
    if var container = try? decoder.unkeyedContainer() {

      var array = [AnyValue]()
      for _ in 0..<(container.count ?? 0) {
        array.append(try container.decode(AnyValue.self))
      }

      self = .array(array)
      return
    }

    // Treat as single value container
    guard let container = try? decoder.singleValueContainer() else {
      fatalError("Invalid decoder")
    }

    if let rawContainer = container as? RawValueDecodingContainer {
      self = try Self.wrapped(rawContainer.decodeRawValue())
      return
    }

    if container.decodeNil() {
      self = .nil
      return
    }

    if let value = try? container.decode(Bool.self) {
      self = .bool(value)
      return
    }

    if let value = try? container.decode(String.self) {
      self = .string(value)
      return
    }

    if let value = try? container.decode(Int8.self) {
      self = .int8(value)
      return
    }

    if let value = try? container.decode(Int16.self) {
      self = .int16(value)
      return
    }

    if let value = try? container.decode(Int32.self) {
      self = .int32(value)
      return
    }

    if let value = try? container.decode(Int64.self) {
      self = .int64(value)
      return
    }


    if let value = try? container.decode(UInt8.self) {
      self = .uint8(value)
      return
    }

    if let value = try? container.decode(UInt16.self) {
      self = .uint16(value)
      return
    }

    if let value = try? container.decode(UInt32.self) {
      self = .uint32(value)
      return
    }

    if let value = try? container.decode(UInt64.self) {
      self = .uint64(value)
      return
    }

    if let value = try? container.decode(Float.self) {
      self = .float(value)
      return
    }

    if let value = try? container.decode(Double.self) {
      self = .double(value)
      return
    }

    if let value = try? container.decode(Decimal.self) {
      self = .decimal(value)
      return
    }

    if let value = try? container.decode(Data.self) {
      self = .data(value)
      return
    }

    if let value = try? container.decode(URL.self) {
      self = .url(value)
      return
    }

    if let value = try? container.decode(UUID.self) {
      self = .uuid(value)
      return
    }

    if let value = try? container.decode(Date.self) {
      self = .date(value)
      return
    }

    if let value = try? container.decode([AnyValue].self) {
      self = .array(value)
      return
    }

    if let value = try? container.decode([String: AnyValue].self) {
      self = .dictionary(value)
      return
    }

    throw AnyValue.Error.unsupportedType
  }

}

/**
 * `Encodable` support
 **/

extension AnyValue : Encodable {

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .nil:
      try container.encodeNil()
    case .bool(let value):
      try container.encode(value)
    case .string(let value):
      try container.encode(value)
    case .int8(let value):
      try container.encode(value)
    case .int16(let value):
      try container.encode(value)
    case .int32(let value):
      try container.encode(value)
    case .int64(let value):
      try container.encode(value)
    case .uint8(let value):
      try container.encode(value)
    case .uint16(let value):
      try container.encode(value)
    case .uint32(let value):
      try container.encode(value)
    case .uint64(let value):
      try container.encode(value)
    case .float(let value):
      try container.encode(value)
    case .double(let value):
      try container.encode(value)
    case .decimal(let value):
      try container.encode(value)
    case .data(let value):
      try container.encode(value)
    case .url(let value):
      try container.encode(value)
    case .uuid(let value):
      try container.encode(value)
    case .date(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .dictionary(let value):
      try container.encode(value)
    }
  }

}

