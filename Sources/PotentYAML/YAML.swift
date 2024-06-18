//
//  YAML.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import OrderedCollections
import PotentCodables


/// General YAML value.
///
/// # Object Access
/// ``YAML`` supoprts Swift's "dnyamic member lookup" so YAML fields of ``YAML/mapping(_:style:tag:anchor:)`` values
/// can be accessed in Swift syntax:
///
///     yamlObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     yamlObject["@value"]
///
/// # Array Access
/// The elements of YAML ``YAML/sequence(_:style:tag:anchor:)`` values can use index subscripting to access individual
/// array values.
///
///     yamlArray[0]
///
@dynamicMemberLookup
public enum YAML {

  public struct Tag: RawRepresentable, Equatable, Hashable, CustomStringConvertible {

    public let rawValue: String

    public init?(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

    public init?(_ rawValue: String?) {
      guard let rawValue = rawValue else { return nil }
      self.rawValue = rawValue
    }

    public static let null = Tag("tag:yaml.org,2002:null")
    public static let bool = Tag("tag:yaml.org,2002:bool")
    public static let int = Tag("tag:yaml.org,2002:int")
    public static let float = Tag("tag:yaml.org,2002:float")
    public static let str = Tag("tag:yaml.org,2002:str")

    public static let seq = Tag("tag:yaml.org,2002:seq")
    public static let map = Tag("tag:yaml.org,2002:map")

    public var description: String { "!\(rawValue)" }
  }

  public typealias Anchor = String

  public struct Number: Equatable, Hashable, Codable {

    public var value: String
    public var isInteger: Bool
    public var isNegative: Bool

    public init(_ value: String, isInteger: Bool, isNegative: Bool) {
      self.value = value
      self.isInteger = isInteger
      self.isNegative = isNegative
    }

    public init(_ value: String, schema: YAMLSchema = .core) {
      self.init(value, isInteger: schema.isInt(value), isNegative: value.hasPrefix("-"))
    }

    public init<T: FloatingPoint>(_ value: T) {
      self.value = String(describing: value)
      isInteger = false
      isNegative = value < 0
    }

    public init<T: SignedInteger>(_ value: T) {
      self.value = String(value)
      isInteger = true
      isNegative = value < 0
    }

    public init<T: UnsignedInteger>(_ value: T) {
      self.value = String(value)
      isInteger = true
      isNegative = false
    }

    public var isNaN: Bool {
      return value == ".nan"
    }

    public var isInfinity: Bool {
      return value.hasSuffix(".inf")
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
          guard let int = BigInt(value) else {
            return nil
          }
          switch int.bitWidth {
          case 0 ... (MemoryLayout<Int>.size * 8):
            return Int(int)
          case 0 ... (MemoryLayout<Int64>.size * 8):
            return Int64(int)
          default:
            return BigInt(value)
          }
        }
        else {
          guard let int = BigUInt(value) else {
            return nil
          }
          switch int.bitWidth {
          case 0 ... (MemoryLayout<Int>.size * 8) - 1:
            return Int(int)
          case 0 ... (MemoryLayout<UInt>.size * 8):
            return UInt(int)
          case 0 ... (MemoryLayout<Int64>.size * 8) - 1:
            return Int64(int)
          case 0 ... (MemoryLayout<UInt64>.size * 8):
            return UInt64(int)
          default:
            return BigInt(value)
          }
        }
      }
      guard let double = Double(value) else {
        return nil
      }
      return double
    }

    public static func == (lhs: Number, rhs: Number) -> Bool {
      return lhs.value == rhs.value && lhs.isInteger == rhs.isInteger && lhs.isNegative == rhs.isNegative
    }
  }

  public typealias Sequence = [YAML]

  public struct MappingEntry: Equatable, Hashable {
    var key: YAML
    var value: YAML

    public init(key: YAML, value: YAML) {
      self.key = key
      self.value = value
    }

    public init(key: String, value: YAML) {
      self.key = .string(key, style: .any, tag: nil, anchor: nil)
      self.value = value
    }
  }

  public typealias Mapping = [MappingEntry]

  public enum StringStyle: Int32 {
    case any = -1
    case plain = 0
    case singleQuoted = 1
    case doubleQuoted = 2
    case literal = 3
    case folded = 4

    public var isQuoted: Bool {
      self == .singleQuoted || self == .doubleQuoted
    }
  }

  public enum CollectionStyle: Int32 {
    case any
    case flow
    case block
  }

  case null(anchor: Anchor? = nil)
  case string(String, style: StringStyle = .any, tag: Tag? = nil, anchor: Anchor? = nil)
  case integer(Number, anchor: Anchor? = nil)
  case float(Number, anchor: Anchor? = nil)
  case bool(Bool, anchor: Anchor? = nil)
  case sequence([YAML], style: CollectionStyle = .any, tag: Tag? = nil, anchor: Anchor? = nil)
  case mapping(Mapping, style: CollectionStyle = .any, tag: Tag? = nil, anchor: Anchor? = nil)
  case alias(String)

  public init(_ string: String) {
    self = .string(string)
  }

  public subscript(dynamicMember member: String) -> YAML? {
    if let mapping = mappingValue {
      return mapping.first { $0.key.stringValue == member }?.value
    }
    return nil
  }

  public subscript(index: Int) -> YAML? {
    if let sequence = sequenceValue, index < sequence.count {
      return sequence[index]
    }
    return nil
  }

  public subscript(key: String) -> YAML? {
    if let mapping = mappingValue {
      return mapping.first { $0.key.stringValue == key }?.value
    }
    return nil
  }

  public subscript(key: YAML) -> YAML? {
    if let mapping = mappingValue {
      return mapping.first { $0.key == key }?.value
    }
    return nil
  }

  public static func mapping(
    _ mapping: OrderedDictionary<YAML, YAML>,
    style: CollectionStyle = .any,
    tag: Tag? = nil,
    anchor: Anchor? = nil
  ) -> YAML {
    return .mapping(mapping.map { .init(key: $0.key, value: $0.value) }, style: style, tag: tag, anchor: anchor)
  }

  public var stringValue: String? {
    guard case .string(let value, _, _, _) = self else { return nil }
    return value
  }

  public var numberValue: Any? {
    switch self {
    case .integer(let value, _): return value.numberValue
    case .float(let value, _): return value.numberValue
    default: return nil
    }
  }

  public var integerValue: Int? {
    guard case .integer(let value, _) = self else { return nil }
    return value.integerValue
  }

  public var unsignedIntegerValue: UInt? {
    guard case .integer(let value, _) = self else { return nil }
    return value.unsignedIntegerValue
  }

  public var floatValue: Float? {
    guard case .float(let value, _) = self else { return nil }
    return value.floatValue
  }

  public var doubleValue: Double? {
    guard case .float(let value, _) = self else { return nil }
    return value.doubleValue
  }

  public var boolValue: Bool? {
    guard case .bool(let value, _) = self else { return nil }
    return value
  }

  public var sequenceValue: Sequence? {
    guard case .sequence(let value, _, _, _) = self else { return nil }
    return value
  }

  public var mappingValue: Mapping? {
    guard case .mapping(let value, _, _, _) = self else { return nil }
    return value
  }

}


// MARK: Conformances

extension YAML: Equatable {

  public static func == (lhs: YAML, rhs: YAML) -> Bool {
    switch (lhs, rhs) {
    case (.null(_), .null(_)):
      return true
    case (.string(let lstring, _, _, _), .string(let rstring, _, _, _)):
      return lstring == rstring
    case (.integer(let lnumber, _), .integer(let rnumber, _)):
      return lnumber == rnumber
    case (.float(let lnumber, _), .float(let rnumber, _)):
      return lnumber == rnumber
    case (.bool(let lbool, _), .bool(let rbool, _)):
      return lbool == rbool
    case (.sequence(let lsequence, _, _, _), .sequence(let rsequence, _, _, _)):
      return lsequence == rsequence
    case (.mapping(let lentries, _, _, _), .mapping(let rentries, _, _, _)):
      return lentries == rentries
    case (.alias(let lstring), .alias(let rstring)):
      return lstring == rstring
    default:
      return false
    }
  }

}

extension YAML: Hashable {}
extension YAML: Value {

  public var isNull: Bool {
    if case .null = self {
      return true
    }
    return false
  }

}

extension YAML: CustomStringConvertible {

  public var description: String {
    let schema: YAMLSchema = .core
    var output = ""

    func append<T: CustomStringConvertible>(_ anchor: String?, _ tag: Tag?, _ value: T) {
      if let anchor {
        output += "&\(anchor) "
      }
      if let tag {
        output += "\(tag) "
      }
      output += value.description
    }

    switch self {
    case .alias(let value):
      output += "*\(value)"
    case .string(let value, style: let style, tag: let tag, anchor: let anchor):
      switch style {
      case .doubleQuoted:
        append(anchor, tag, #""\#(value)""#)
      case .singleQuoted:
        append(anchor, tag, "'\(value)'")
      case .folded, .literal, .plain, .any:
        append(anchor, tag, schema.requiresQuotes(for: value) ? #""\#(value)""# : value)
      }
    case .bool(let value, anchor: let anchor):
      append(anchor, nil, value)
    case .null(anchor: let anchor):
      append(anchor, nil, "null")
    case .integer(let value, anchor: let anchor), .float(let value, anchor: let anchor):
      append(anchor, nil, value.value)
    case .mapping(let value, style: _, tag: let tag, anchor: let anchor):
      append(anchor, tag, "{\(value.map { "\($0.key.description): \($0.value.description)" }.joined(separator: ", "))}")
    case .sequence(let value, style: _, tag: let tag, anchor: let anchor):
      append(anchor, tag, "[\(value.map(\.description).joined(separator: ", "))]")
    }

    return output
  }

}


// MARK: Wrapping

extension YAML {

  public var unwrapped: Any? {
    switch self {
    case .null, .alias: return nil
    case .bool(let value, _): return value
    case .string(let value, _, _, _): return value
    case .integer(let value, _): return value.numberValue
    case .float(let value, _): return value.numberValue
    case .sequence(let value, _, _, _): return Swift.Array(value.map(\.unwrapped))
    case .mapping(let value, _, _, _): return Dictionary(uniqueKeysWithValues: value.map { entry in
        (entry.key.stringValue!, entry.value.unwrapped)
      })
    }
  }

}


// MARK: Literals

extension YAML: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByStringLiteral,
  ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral,
  ExpressibleByDictionaryLiteral {

  public init(nilLiteral: ()) {
    self = .null(anchor: nil)
  }

  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value, anchor: nil)
  }

  public init(integerLiteral value: IntegerLiteralType) {
    self = .integer(Number(value), anchor: nil)
  }

  public init(floatLiteral value: FloatLiteralType) {
    self = .float(Number(value), anchor: nil)
  }

  public init(stringLiteral value: StringLiteralType) {
    self = .string(value, style: .any, tag: nil, anchor: nil)
  }

  public init(arrayLiteral elements: YAML...) {
    self = .sequence(elements, style: .any, tag: nil, anchor: nil)
  }

  public init(dictionaryLiteral elements: (YAML, YAML)...) {
    self = .mapping(elements.map { MappingEntry(key: $0, value: $1) }, style: .any, tag: nil, anchor: nil)
  }

}


extension YAML.Number: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {

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


// Make encoders/decoders available in AnyValue namespace

public extension YAML {

  typealias Encoder = YAMLEncoder
  typealias Decoder = YAMLDecoder

}
