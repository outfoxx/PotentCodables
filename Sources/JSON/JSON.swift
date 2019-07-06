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

  public typealias Number = Float80

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

  public var numberValue: Number? {
    guard case .number(let value) = self else { return nil }
    return value
  }

  public var doubleValue: Double? {
    guard case .number(let value) = self, let double = Double(exactly: value) else { return nil }
    return double
  }

  public var integerValue: Int64? {
    guard case .number(let value) = self, let int = Int64(exactly: value) else { return nil }
    return int
  }

  public var unsignedIntegerValue: UInt64? {
    guard case .number(let value) = self, let int = UInt64(exactly: value) else { return nil }
    return int
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

  public func describe(indent: String = "") -> String {
    let nextIndent = indent + "  "
    let newlineIndent = "\n\(nextIndent)"
    switch self {
    case .null: return "null"
    case .bool(let value): return "\(value)"
    case .string(let value): return "\"\(value)\""
    case .number(let value): return "\(value)"
    case .array(let value): return "[\(newlineIndent)\(value.map { $0.describe(indent: nextIndent) }.joined(separator: ",\(newlineIndent)"))\n\(indent)]"
    case .object(let value): return "{\(newlineIndent)\(value.map { "\"\($0.key)\": \($0.value.describe(indent: nextIndent))" }.joined(separator: ",\(newlineIndent)"))\n\(indent)}"
    }
  }

  public var description: String {
    return self.describe()
  }

}

extension JSON : Equatable {}
extension JSON : Hashable {}
extension JSON : Value {}


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
    self = .number(Float80(exactly: value)!)
  }

  public init(floatLiteral value: FloatLiteralType) {
    self = .number(Float80(exactly: value)!)
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

/**
 * Decodable support
 **/

extension JSON : Decodable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = JSON.null
    }

    if let value = try? container.decode(Int64.self) {
      self = .number(Number(exactly: value)!)
      return
    }

    if let value = try? container.decode(UInt64.self) {
      self = .number(Number(exactly: value)!)
      return
    }

    if let value = try? container.decode(Double.self) {
      self = .number(Number(exactly: value)!)
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

    if let value = try? container.decode([JSON].self) {
      self = .array(value)
      return
    }

    if let value = try? container.decode([String: JSON].self) {
      self = .object(value)
      return
    }

    throw JSON.Error.unsupportedType
  }

}

/**
 * `Encodable` support
 **/

extension JSON : Encodable {

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null:
      try container.encodeNil()
    case .string(let value):
      try container.encode(value)
    case .number(let value):
      if let int = Int64(exactly: value) {
        try container.encode(int)
      }
      else if let uint = UInt64(exactly: value) {
        try container.encode(uint)
      }
      else {
        try container.encode(Double(value))
      }
    case .bool(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .object(let value):
      try container.encode(value)
    }
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

