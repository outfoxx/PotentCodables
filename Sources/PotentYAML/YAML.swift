//
//  YAML.swift
//  
//
//  Created by Kevin Wooten on 4/11/20.
//

import Foundation
import PotentCodables
import CoreServices

/// General YAML value.
///
/// # Object Access
/// `YAML` supoprts Swift's "dnyamic member lookup" so YAML fields of `mapping` values can be accessed in Swift syntax:
///
///     yamlObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     yamlObject["@value"]
///
/// # Array Access
/// The elements of YAML `sequence` values can use index subscripting to access individual array values.
///
///     yamlArray[0]
///
@dynamicMemberLookup
public enum YAML {
  
  public struct Tag: RawRepresentable, Equatable, Hashable {
    
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
    
    public static let null = Tag("!!null")
    public static let bool = Tag("!!bool")
    public static let int = Tag("!!int")
    public static let float = Tag("!!float")
    public static let str = Tag("!!str")
    
    public static let seq = Tag("!!seq")
    public static let map = Tag("!!map")
  }
  
  public typealias Anchor = String
  
  public enum Error : Swift.Error {
    case unexpectedEOF
    case unexpectedEvent
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
      isInteger = value.allSatisfy { $0.isNumber }
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
    
    public static func ==(lhs: Number, rhs: Number) -> Bool {
      return lhs.value == rhs.value && lhs.isInteger == rhs.isInteger && lhs.isNegative == rhs.isNegative
    }
  }
  
  public enum StringStyle : Int32 {
    case plain = 0
    case singleQuoted = 1
    case doubleQuoted = 2
    case literal = 3
    case folded = 4
  }
  
  public enum CollectionStyle : Int32 {
    case flow
    case block
  }
  
  public struct MapEntry : Equatable, Hashable {
    let key: YAML
    let value: YAML
  }

  case null(anchor: Anchor?)
  case string(String, style: StringStyle, tag: Tag?, anchor: Anchor?)
  case integer(Number, anchor: Anchor?)
  case float(Number, anchor: Anchor?)
  case bool(Bool, anchor: Anchor?)
  case sequence([YAML], style: CollectionStyle, tag: Tag?, anchor: Anchor?)
  case mapping([MapEntry], style: CollectionStyle, tag: Tag?, anchor: Anchor?)
  case alias(String)

  public var isNull: Bool {
    if case .null = self {
      return true
    }
    return false
  }
  
  public var stringValue: String? {
    guard case .string(let value, _, _, _) = self else { return nil }
    return value
  }
  
  public var integerValue: Int? {
    switch self {
    case .integer(let value, _):
      return value.integerValue
    case .float(let value, _):
      return value.integerValue
    default:
      return nil
    }
  }
  
  public var unsignedIntegerValue: UInt? {
    switch self {
    case .integer(let value, _):
      return value.unsignedIntegerValue
    case .float(let value, _):
      return value.unsignedIntegerValue
    default:
      return nil
    }
  }
  
  public var floatValue: Float? {
    switch self {
    case .integer(let value, _):
      return value.floatValue
    case .float(let value, _):
      return value.floatValue
    default:
      return nil
    }
  }
  
  public var doubleValue: Double? {
    switch self {
    case .integer(let value, _):
      return value.doubleValue
    case .float(let value, _):
      return value.doubleValue
    default:
      return nil
    }
  }
  
  public var boolValue: Bool? {
    guard case .bool(let value, _) = self else { return nil }
    return value
  }
  
  public var sequenceValue: [YAML]? {
    guard case .sequence(let value, _, _, _) = self else { return nil }
    return value
  }
  
  public var mappingValue: [YAML.MapEntry]? {
    guard case .mapping(let value, _, _, _) = self else { return nil }
    return value
  }
  
  public subscript(dynamicMember member: String) -> YAML? {
    if let mapping = mappingValue {
      return mapping.first { $0.key.stringValue == member }?.value
    }
    return nil
  }
  
  public subscript(index: Int) -> YAML? {
    if let sequence = sequenceValue {
      return index < sequence.count ? sequence[index] : nil
    }
    return nil
  }
  
  public subscript(key: String) -> YAML? {
    if let mapping = mappingValue {
      return mapping.first { $0.key.stringValue == key }?.value
    }
    return nil
  }
  
}

extension YAML : CustomStringConvertible {
  
  public var description: String {

    do {
      
      var output = ""
      
      try YAMLWriter.write([self], sortedKeys: true) { output += $0 ?? "" }
      
      return output
    }
    catch {
      return "Invalid YAML: \(error)"
    }
    
  }
  
}

extension YAML : Equatable {
  
  public static func ==(lhs: YAML, rhs: YAML) -> Bool {
    switch lhs {
    case .null(let lanchor):
      guard case .null(let ranchor) = rhs else { return false }
      return lanchor == ranchor
    case .string(let lstring, _, let ltag, let lanchor):
      guard case .string(let rstring, _, let rtag, let ranchor) = rhs else { return false }      
      return lstring == rstring && ltag == rtag && lanchor == ranchor
    case .integer(let lnumber, let lanchor):
      guard case .integer(let rnumber, let ranchor) = rhs else { return false }      
      return lnumber == rnumber && lanchor == ranchor
    case .float(let lnumber, let lanchor):
      guard case .float(let rnumber, let ranchor) = rhs else { return false }      
      return lnumber == rnumber && lanchor == ranchor
    case .bool(let lbool, let lanchor):
      guard case .bool(let rbool, let ranchor) = rhs else { return false }      
      return lbool == rbool && lanchor == ranchor
    case .sequence(let lsequence, _, let ltag, let lanchor):
      guard case .sequence(let rsequence, _, let rtag, let ranchor) = rhs else { return false }      
      return lsequence == rsequence && ltag == rtag && lanchor == ranchor
    case .mapping(let lentries, _, let ltag, let lanchor):
      guard case .mapping(let rentries, _, let rtag, let ranchor) = rhs else { return false }      
      return lentries == rentries && ltag == rtag && lanchor == ranchor
    case .alias(let lstring):
      guard case .alias(let rstring) = rhs else { return false }
      return lstring == rstring
    }
  }
  
}

extension YAML: Hashable {}
extension YAML: Value {
  
  public var unwrapped: Any? {
    switch self {
    case .null: return nil
    case .bool(let value, _): return value
    case .string(let value, _, _, _): return value
    case .integer(let value, _): return value.numberValue
    case .float(let value, _): return value.numberValue
    case .sequence(let value, _, _, _): return Array(value.map { $0.unwrapped })
    case .mapping(let value, _, _, _): return Dictionary(uniqueKeysWithValues: value.map { entry in (entry.key.stringValue!, entry.value.unwrapped) })
    case .alias(_): fatalError("Aliases not supported during unwrapping")
    }
  }
  
}

extension YAML : ExpressibleByNilLiteral {
  
  public init(nilLiteral: ()) {
    self = .null(anchor: nil)
  }
  
}

extension YAML : ExpressibleByBooleanLiteral {
  
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value, anchor: nil)
  }
  
}

extension YAML : ExpressibleByIntegerLiteral {
  
  public init(integerLiteral value: IntegerLiteralType) {
    self = .integer(Number(value), anchor: nil)
  }
  
}

extension YAML : ExpressibleByFloatLiteral {
  
  public init(floatLiteral value: FloatLiteralType) {
    self = .float(Number(value), anchor: nil)
  }
  
}

extension YAML : ExpressibleByStringLiteral {
  
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value, style: .doubleQuoted, tag: nil, anchor: nil)
  }
  
}

extension YAML : ExpressibleByArrayLiteral {
  
  public init(arrayLiteral elements: YAML...) {
    self = .sequence(elements, style: .block, tag: nil, anchor: nil)    
  }
  
}


extension YAML : ExpressibleByDictionaryLiteral {
  
  public init(dictionaryLiteral elements: (YAML, YAML)...) {
    self = .mapping(elements.map { MapEntry(key: $0, value: $1) }, style: .block, tag: nil, anchor: nil)    
  }
  
}

