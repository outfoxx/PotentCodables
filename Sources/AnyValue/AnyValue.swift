//
//  AnyValue.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/15/19.
//

import Foundation


public enum AnyValue : Hashable {
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

  /// Unwraps all the values in the tree, leaving nils in `array` or `dictionary` values
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


extension AnyValue : Value {

  public var isNull: Bool {
    guard case .nil = self else { return false }
    return true
  }

}


/**
 * Decodable support
 **/

extension AnyValue : Decodable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = .nil
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

    throw JSON.Error.unsupportedType
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

