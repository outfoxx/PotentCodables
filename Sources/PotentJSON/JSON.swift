//
//  JSON.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import OrderedCollections
import PotentCodables


/// General JSON value.
///
/// # Object Access
/// `JSON` supoprts Swift's "dnyamic member lookup" so JSON fields of `object` values can be accessed in Swift syntax:
///
///     jsonObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     jsonObject["@value"]
///
/// # Array Access
/// The elements of JSON `array` values can use index subscripting to access individual array values.
///
///     jsonArray[0]
///
@dynamicMemberLookup
public enum JSON {

  enum Error: Swift.Error {
    case unsupportedType
  }

  public struct Number: Equatable, Hashable, Codable {

    public let value: String
    public let isInteger: Bool
    public let isNegative: Bool

    public init(_ value: String, isInteger: Bool, isNegative: Bool) {
      self.value = value
      self.isInteger = isInteger
      self.isNegative = isNegative
    }

    public init(_ value: String) {
      self.value = value
      isInteger = value.allSatisfy(\.isNumber)
      isNegative = value.hasPrefix("-")
    }

    public init(_ value: Double) {
      self.value = value.description
      isInteger = false
      isNegative = value < 0
    }

    public init(_ value: Int) {
      self.value = value.description
      isInteger = true
      isNegative = value < 0
    }

    public var integerValue: Int? {
      guard isInteger else { return nil }
      return Int(value)
    }

    public var unsignedIntegerValue: UInt? {
      guard isInteger, !isNegative else { return nil }
      return UInt(value)
    }

    public var floatValue: Float? {
      return Float(value)
    }

    public var doubleValue: Double? {
      return Double(value)
    }

    public var numberValue: Any? {
      if isInteger {
        if isNegative {
          if MemoryLayout<Int>.size == 4 {
            return Int(value) ?? Int64(value) ?? Decimal(string: value)
          }
          return Int(value) ?? Decimal(string: value)
        }
        if MemoryLayout<Int>.size == 4 {
          return Int(value) ?? Int64(value) ?? UInt(value) ?? UInt64(value) ?? Decimal(string: value)
        }
        return Int(value) ?? UInt(value) ?? Decimal(string: value)
      }
      return Double(value) ?? Decimal(string: value)
    }

  }

  public typealias Array = [JSON]
  public typealias Object = OrderedDictionary<String, JSON>

  case null
  case string(String)
  case number(Number)
  case bool(Bool)
  case array(Array)
  case object(Object)

  public var isNull: Bool {
    if case .null = self {
      return true
    }
    return false
  }

  public var stringValue: String? {
    guard case .string(let value) = self else { return nil }
    return value
  }

  public var numberValue: Any? {
    guard case .number(let value) = self else { return nil }
    return value.numberValue
  }

  public var integerValue: Int? {
    guard case .number(let value) = self else { return nil }
    return value.integerValue
  }

  public var unsignedIntegerValue: UInt? {
    guard case .number(let value) = self else { return nil }
    return value.unsignedIntegerValue
  }

  public var floatValue: Float? {
    guard case .number(let value) = self else { return nil }
    return value.floatValue
  }

  public var doubleValue: Double? {
    guard case .number(let value) = self else { return nil }
    return value.doubleValue
  }

  public var boolValue: Bool? {
    guard case .bool(let value) = self else { return nil }
    return value
  }

  public var arrayValue: Array? {
    guard case .array(let value) = self else { return nil }
    return value
  }

  public var objectValue: Object? {
    guard case .object(let value) = self else { return nil }
    return value
  }

  public subscript(dynamicMember member: String) -> JSON? {
    if let object = objectValue {
      return object[member]
    }
    return nil
  }

  public subscript(index: Int) -> JSON? {
    if let array = arrayValue {
      return index < array.count ? array[index] : nil
    }
    return nil
  }

  public subscript(key: String) -> JSON? {
    if let object = objectValue {
      return object[key]
    }
    return nil
  }

}

extension JSON: CustomStringConvertible {

  public var description: String {
    var output = ""
    var writer = JSONWriter(pretty: true) { output += $0 ?? "" }

    do {
      try writer.serialize(self)
    }
    catch {
      output = "Invalid JSON: \(error)"
    }
    return output
  }

}

extension JSON: Equatable {}
extension JSON: Hashable {}
extension JSON: Value {

  public var unwrapped: Any? {
    switch self {
    case .null: return nil
    case .bool(let value): return value
    case .string(let value): return value
    case .number(let value): return value.numberValue
    case .array(let value): return Swift.Array(value.map(\.unwrapped))
    case .object(let value): return Dictionary(uniqueKeysWithValues: value.map { key, value in (key, value.unwrapped) })
    }
  }

}


/**
 * Literal support
 **/

extension JSON: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral,
  ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral,
  ExpressibleByDictionaryLiteral {

  public init(nilLiteral: ()) {
    self = .null
  }

  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }

  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }

  public init(integerLiteral value: IntegerLiteralType) {
    self = .number(Number(value.description))
  }

  public init(floatLiteral value: FloatLiteralType) {
    self = .number(Number(value.description))
  }

  public typealias ArrayLiteralElement = JSON

  public init(arrayLiteral elements: ArrayLiteralElement...) {
    self = .array(elements)
  }

  public typealias Key = String
  public typealias Value = JSON

  public init(dictionaryLiteral elements: (Key, Value)...) {
    self = .object(Object(uniqueKeysWithValues: elements))
  }

}

extension JSON.Number: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }

  public init(floatLiteral value: Double) {
    self.init(value)
  }

  public init(integerLiteral value: Int) {
    self.init(value)
  }

}

/// Make encoders/decoders available in JSON namespace
///
public extension JSON {

  typealias Encoder = JSONEncoder
  typealias Decoder = JSONDecoder

}
