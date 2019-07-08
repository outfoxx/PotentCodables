//
//  JSON.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/18/18.
//  Copyright © 2018 Outfox, Inc. All rights reserved.
//

import Foundation


/**
 * General JSON value.
 *
 * * Supports `Encodable` & `Decodable` for decoding "any" value
 * * Supoprts dnyamic member lookup so JSON objects can be accessed in natural Swift syntax (e.g. `jsonObject.someValue`)
 **/
@dynamicMemberLookup
public enum JSON {

  enum Error : Swift.Error {
    case unsupportedType
  }

  public struct Number : Equatable, Hashable, Codable {

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
      self.isInteger = value.allSatisfy { $0.isNumber }
      self.isNegative = value.hasPrefix("-")
    }

    public init(_ value: Double) {
      self.value = value.description
      self.isInteger = false
      self.isNegative = value < 0
    }

    public init(_ value: Int) {
      self.value = value.description
      self.isInteger = true
      self.isNegative = value < 0
    }

    public var integerValue: Int? {
      guard isInteger else { return nil }
      return Int(value)
    }

    public var unsignedIntegerValue: UInt? {
      guard isInteger && !isNegative else { return nil }
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

  case null
  case string(String)
  case number(Number)
  case bool(Bool)
  case array([JSON])
  case object([String: JSON])

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

  public var arrayValue: Array<JSON>? {
    guard case .array(let value) = self else { return nil }
    return value
  }

  public var objectValue: Dictionary<String, JSON>? {
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

  public var description: String {
    var output = ""
    var writer = JSONWriter(pretty: true, sortedKeys: true) { output += $0 ?? "" }

    do {
      try writer.serialize(self)
    }
    catch {
      output = "Invalid JSON: \(error)"
    }
    return output
  }

}

extension JSON : Equatable {}
extension JSON : Hashable {}
extension JSON : Value {

  public var unwrapped: Any? {
    switch self {
    case .null: return nil
    case .bool(let value): return value
    case .string(let value): return value
    case .number(let value): return value.numberValue
    case .array(let value): return Array(value.map { $0.unwrapped })
    case .object(let value): return Dictionary(uniqueKeysWithValues: value.map { key, value in (key, value.unwrapped) })
    }
  }

}


/**
 * Literal support
 **/

extension JSON : ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral,
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
    self = .object(Dictionary(elements, uniquingKeysWith: { _, last in last }))
  }

}

extension JSON.Number : ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {

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

/**
 * "Stable" encoding of JSON to text
 *
 * Encodes values in a stable (aka repeatable) manner making it
 * easy to compare different complex values that have been encoded
 * to text
 **/
extension JSON {

  public var stableText : String {
    var output = ""
    var writer = JSONWriter(pretty: false, sortedKeys: true) { output += $0 ?? "" }
    do {
      try writer.serialize(self)
    }
    catch {
      output = "Invalid JSON: \(error)"
    }
    return output
  }

}
