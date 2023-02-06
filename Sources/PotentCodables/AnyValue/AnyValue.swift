//
//  AnyValue.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import BigInt
import OrderedCollections


/// A `Codable` value that allows encoding/decoding values of any type or structure.
///
/// # Dictionary Access
/// `AnyValue` supoprts Swift's "dnyamic member lookup" so fields of `dictionary` values can be accessed in Swift syntax
///
///     anyObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     anyObject["@value"]
///
/// # Array Access
/// The elements of `array` values can use index subscripting to access individual array values:
///
///     anyArray[0]
///
@dynamicMemberLookup
public enum AnyValue {

  public enum Error: Swift.Error {
    case unsupportedType
    case unsupportedValue(Any)
  }

  public typealias AnyArray = [AnyValue]
  public typealias AnyDictionary = OrderedDictionary<AnyValue, AnyValue>

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
  case integer(BigInt)
  case unsignedInteger(BigUInt)
  case float16(Float16)
  case float(Float)
  case double(Double)
  case decimal(Decimal)
  case data(Data)
  case url(URL)
  case uuid(UUID)
  case date(Date)
  case array(AnyArray)
  case dictionary(AnyDictionary)

  public static func int(_ value: Int) -> AnyValue {
    return MemoryLayout<Int>.size == 8 ? .int64(Int64(value)) : .int32(Int32(value))
  }

  public static func uint(_ value: UInt) -> AnyValue {
    return MemoryLayout<UInt>.size == 8 ? .uint64(UInt64(value)) : .uint32(UInt32(value))
  }

  public subscript(dynamicMember member: String) -> AnyValue? {
    if case .dictionary(let dict) = self {
      return dict[.string(member)]
    }
    return nil
  }

  public subscript(member: AnyValue) -> AnyValue? {
    if case .dictionary(let dict) = self {
      return dict[member]
    }
    return nil
  }

  public subscript(index: Int) -> AnyValue? {
    if case .array(let array) = self, index < array.count {
      return array[index]
    }
    return nil
  }

  public var boolValue: Bool? {
    guard case .bool(let value) = self else { return nil }
    return value
  }

  public var stringValue: String? {
    guard case .string(let value) = self else { return nil }
    return value
  }

  public var urlValue: URL? {
    guard case .url(let value) = self else { return nil }
    return value
  }

  public var uuidValue: UUID? {
    guard case .uuid(let value) = self else { return nil }
    return value
  }

  public var dataValue: Data? {
    guard case .data(let value) = self else { return nil }
    return value
  }

  public var dateValue: Date? {
    guard case .date(let value) = self else { return nil }
    return value
  }

  public var arrayValue: AnyArray? {
    guard case .array(let value) = self else { return nil }
    return value
  }

  public var dictionaryValue: AnyDictionary? {
    guard case .dictionary(let value) = self else { return nil }
    return value
  }

  public var intValue: Int? {
    if MemoryLayout<Int>.size == 8 {
      guard case .int64(let value) = self else {
        return nil
      }
      return Int(value)
    }
    else {
      guard case .int32(let value) = self else {
        return nil
      }
      return Int(value)
    }
  }

  public var uintValue: UInt? {
    if MemoryLayout<UInt>.size == 8 {
      guard case .uint64(let value) = self else {
        return nil
      }
      return UInt(value)
    }
    else {
      guard case .uint32(let value) = self else {
        return nil
      }
      return UInt(value)
    }
  }

  public var int8Value: Int8? {
    guard case .int8(let int) = self else {
      return nil
    }
    return int
  }

  public var uint8Value: UInt8? {
    guard case .uint8(let uint) = self else {
      return nil
    }
    return uint
  }

  public var int16Value: Int16? {
    guard case .int16(let int) = self else {
      return nil
    }
    return int
  }

  public var uint16Value: UInt16? {
    guard case .uint16(let uint) = self else {
      return nil
    }
    return uint
  }

  public var int32Value: Int32? {
    guard case .int32(let int) = self else {
      return nil
    }
    return int
  }

  public var uint32Value: UInt32? {
    guard case .uint32(let uint) = self else {
      return nil
    }
    return uint
  }

  public var int64Value: Int64? {
    guard case .int64(let int) = self else {
      return nil
    }
    return int
  }

  public var uint64Value: UInt64? {
    guard case .uint64(let uint) = self else {
      return nil
    }
    return uint
  }

  public func integerValue<I: FixedWidthInteger>(_ type: I.Type) -> I? {
    switch self {
    case .int8(let value): return I(value)
    case .int16(let value): return I(value)
    case .int32(let value): return I(value)
    case .int64(let value): return I(value)
    case .uint8(let value): return I(value)
    case .uint16(let value): return I(value)
    case .uint32(let value): return I(value)
    case .uint64(let value): return I(value)
    default:
      return nil
    }
  }

  public var float16Value: Float16? {
    guard case .float16(let float) = self else {
      return nil
    }
    return float
  }

  public var floatValue: Float? {
    guard case .float(let float) = self else {
      return nil
    }
    return float
  }

  public var doubleValue: Double? {
    guard case .double(let double) = self else {
      return nil
    }
    return double
  }

  public var decimalValue: Decimal? {
    guard case .decimal(let decimal) = self else {
      return nil
    }
    return decimal
  }

  public func floatingPointValue<F: BinaryFloatingPoint & LosslessStringConvertible>(_ type: F.Type) -> F? {
    switch self {
    case .int8(let value): return F(value)
    case .int16(let value): return F(value)
    case .int32(let value): return F(value)
    case .int64(let value): return F(value)
    case .uint8(let value): return F(value)
    case .uint16(let value): return F(value)
    case .uint32(let value): return F(value)
    case .uint64(let value): return F(value)
    case .float16(let value): return F(value)
    case .float(let value): return F(value)
    case .double(let value): return F(value)
    case .decimal(let value): return F(value.description)
    default:
      return nil
    }
  }
}


// MARK: Conformances

extension AnyValue: Equatable {}
extension AnyValue: Hashable {}
extension AnyValue: Value {

  public var isNull: Bool {
    guard case .nil = self else { return false }
    return true
  }

}

extension AnyValue: CustomStringConvertible {

  public var description: String {
    switch self {
    case .nil: return "nil"
    case .bool(let value): return value.description
    case .int8(let value): return value.description
    case .int16(let value): return value.description
    case .int32(let value): return value.description
    case .int64(let value): return value.description
    case .uint8(let value): return value.description
    case .uint16(let value): return value.description
    case .uint32(let value): return value.description
    case .uint64(let value): return value.description
    case .integer(let value): return value.description
    case .unsignedInteger(let value): return value.description
    case .float16(let value): return value.description
    case .float(let value): return value.description
    case .double(let value): return value.description
    case .decimal(let value): return value.description
    case .string(let value): return value
    case .date(let value): return ZonedDate(date: value, timeZone: .utc).iso8601EncodedString()
    case .data(let value): return value.description
    case .uuid(let value): return value.uuidString
    case .url(let value): return value.absoluteString
    case .array(let value): return value.description
    case .dictionary(let value): return value.description
    }
  }

}


// MARK: Wrapping

extension AnyValue {

  /// Wraps the value into an equivalent `AnyValue` tree
  public static func wrapped(_ value: Any?) throws -> AnyValue {
    guard let value = value else { return .nil }
    switch value {
    case let val as AnyValue: return val
    case let val as String: return .string(val)
    case let val as Int: return .int(val)
    case let val as UInt: return .uint(val)
    case let val as Bool: return .bool(val)
    case let val as Int8: return .int8(val)
    case let val as UInt8: return .uint8(val)
    case let val as Int16: return .int16(val)
    case let val as UInt16: return .uint16(val)
    case let val as Int32: return .int32(val)
    case let val as UInt32: return .uint32(val)
    case let val as Int64: return .int64(val)
    case let val as UInt64: return .uint64(val)
    case let val as Decimal: return .decimal(val) // Before other floats (Swift Decimal -> Double allowed)
    case let val as Float16: return .float16(val)
    case let val as Float: return .float(val)
    case let val as Double: return .double(val)
    case let val as BigInt: return .integer(val)
    case let val as BigUInt: return .unsignedInteger(val)
    case let val as Data: return .data(val)
    case let val as URL: return .url(val)
    case let val as UUID: return .uuid(val)
    case let val as Date: return .date(val)
    case let val as AnyArray: return .array(val)
    case let val as [Any]: return .array(try val.map { try wrapped($0) })
    case let val as AnyDictionary: return .dictionary(val)
    case let val as [String: Any]:
      return .dictionary(AnyDictionary(uniqueKeysWithValues: try val.map { (try wrapped($0), try wrapped($1)) }))
    case let val as [Int: Any]:
      return .dictionary(AnyDictionary(uniqueKeysWithValues: try val.map { (try wrapped($0), try wrapped($1)) }))
    case let val as OrderedDictionary<String, Any>:
      return .dictionary(AnyDictionary(uniqueKeysWithValues: try val.map { (try wrapped($0), try wrapped($1)) }))
    case let val as OrderedDictionary<Int, Any>:
      return .dictionary(AnyDictionary(uniqueKeysWithValues: try val.map { (try wrapped($0), try wrapped($1)) }))
    default: throw Error.unsupportedValue(value)
    }
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
    case .integer(let value): return value
    case .unsignedInteger(let value): return value
    case .float16(let value): return value
    case .float(let value): return value
    case .double(let value): return value
    case .decimal(let value): return value
    case .data(let value): return value
    case .url(let value): return value
    case .uuid(let value): return value
    case .date(let value): return value
    case .array(let value): return Array(value.map(\.unwrapped))
    case .dictionary(let value): return unwrap(dictionary: value)
    }

    func unwrap(dictionary: AnyDictionary) -> Any {
      return Dictionary(uniqueKeysWithValues: dictionary.compactMap {
        guard let value = $1.unwrapped else {
          return nil
        }
        if let key = $0.stringValue {
          return (AnyHashable(key), value)
        }
        else if let key = $0.integerValue(Int.self) {
          return (AnyHashable(key), value)
        }
        else {
          // It is an unsupported key type, but we are returning
          // nil(s) rather than throwing errors
          return nil
        }
      }) as [AnyHashable: Any]
    }
  }

}


// MARK: Literals

extension AnyValue: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral,
  ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral,
  ExpressibleByDictionaryLiteral {

  public init(nilLiteral: ()) {
    self = .nil
  }

  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }

  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }

  public init(integerLiteral value: IntegerLiteralType) {
    self = .int64(Int64(value))
  }

  public init(floatLiteral value: FloatLiteralType) {
    self = .double(value)
  }

  public typealias ArrayLiteralElement = AnyValue

  public init(arrayLiteral elements: ArrayLiteralElement...) {
    self = .array(elements)
  }

  public typealias Key = AnyValue
  public typealias Value = AnyValue

  public init(dictionaryLiteral elements: (Key, Value)...) {
    self = .dictionary(AnyDictionary(uniqueKeysWithValues: elements.map { ($0, $1) }))
  }

}


// MARK: Codable

extension AnyValue: Decodable {

  public init(from decoder: Swift.Decoder) throws {

    // Try as single value container
    if let container = try? decoder.singleValueContainer() {

      if container.decodeNil() {
        self = .nil
        return
      }

      if let value = try? container.decode(Bool.self) {
        self = .bool(value)
        return
      }

      if let value = try? container.decode(Int.self) {
        self = .int(value)
        return
      }

      if let value = try? container.decode(Int64.self) {
        self = .int64(value)
        return
      }

      if let value = try? container.decode(UInt64.self) {
        self = .uint64(value)
        return
      }

      if let value = try? container.decode(BigInt.self) {
        self = .integer(value)
        return
      }

      if let value = try? container.decode(Double.self) {
        self = .double(value)
        return
      }

      if let value = try? container.decode(String.self) {
        self = .string(value)
        return
      }

      if let value = try? container.decode([AnyValue].self) {
        self = .array(value)
        return
      }

    }

    // Try keyed container
    if let container = try? decoder.container(keyedBy: AnyCodingKey.self) {

      var dictionary = AnyDictionary()
      for key in container.allKeys {
        dictionary[.string(key.stringValue)] = try container.decode(AnyValue.self, forKey: key)
      }

      self = .dictionary(dictionary)
      return
    }

    throw AnyValue.Error.unsupportedType
  }

}

extension AnyValue: Encodable {

  public func encode(to encoder: Swift.Encoder) throws {
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
    case .integer(let value):
      try container.encode(value)
    case .unsignedInteger(let value):
      try container.encode(value)
    case .float16(let value):
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


// Make encoders/decoders available in AnyValue namespace

public extension AnyValue {

  typealias Encoder = AnyValueEncoder
  typealias Decoder = AnyValueDecoder

}
