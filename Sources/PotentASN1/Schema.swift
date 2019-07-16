//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/16/19.
//

import Foundation
import PotentCodables
import BigInt
import OrderedDictionary


public protocol SchemaSpecified {

  static var asn1Schema: Schema { get }

}


public indirect enum Schema {

  public typealias DynamicMap = [ASN1: Schema]
  public typealias StructureSequenceMap = OrderedDictionary<String, Schema>

  public enum Size: CustomStringConvertible {
    case min(Int)
    case max(Int)
    case `is`(Int)
    case range(Int, Int)

    public func contains(_ value: Int) -> Bool {
      switch self {
      case .min(let min): return value >= min
      case .max(let max): return value <= max
      case .is(let size): return value == size
      case .range(let min, let max): return value >= min && value <= max
      }
    }

    public func `in`(_ range: ClosedRange<Int>) -> Size {
      return .range(range.lowerBound, range.upperBound)
    }

    public var description: String {
      switch self {
      case .min(let min): return "\(min)..MAX"
      case .max(let max): return "0..\(max)"
      case .is(let size): return "\(size)..\(size)"
      case .range(let min, let max): return "\(min)..\(max)"
      }
    }

  }

  case sequence(StructureSequenceMap = [:])

  case sequenceOf(Schema, size: Size? = nil)
  case setOf(Schema, size: Size? = nil)
  case choiceOf([Schema])

  case any
  case type(Schema)
  case dynamic(allowUnknownTypes: Bool = false, DynamicMap)

  case version(Schema)
  case versioned(range: ClosedRange<UInt>, Schema)

  case optional(Schema)

  case implicit(UInt8, in: ASN1.Tag.Class = .contextSpecific, Schema)
  case explicit(UInt8, in: ASN1.Tag.Class = .contextSpecific, Schema)

  case boolean(default: Bool? = nil)
  case integer(allowed: Swift.Range<Int>? = nil, default: Int? = nil)
  case real
  case bitString(size: Size? = nil)
  case octetString(size: Size? = nil)
  case objectIdentifier(allowed: Set<OID>? = nil)
  case string(kind: AnyString.Kind, size: Size? = nil)
  case time(kind: AnyTime.Kind)
  case null

  public var possibleTags: [ASN1.AnyTag]? {
    switch self {
    case .sequence, .sequenceOf: return [ASN1.Tag.sequence.universal]
    case .setOf: return [ASN1.Tag.set.universal]
    case .choiceOf(let schemas): return schemas.flatMap { $0.possibleTags ?? [] }
    case .type(let schema): return schema.possibleTags
    case .version(let schema): return schema.possibleTags
    case .versioned(_, let schema): return schema.possibleTags
    case .optional(let schema): return schema.possibleTags
    case .implicit(let tag, let tagClass, _): return [ASN1.Tag.tag(from: tag, in: tagClass)]
    case .explicit(let tag, let tagClass, _): return [ASN1.Tag.tag(from: tag, in: tagClass)]
    case .boolean: return [ASN1.Tag.boolean.universal]
    case .integer: return [ASN1.Tag.integer.universal]
    case .real: return [ASN1.Tag.real.universal]
    case .bitString: return [ASN1.Tag.bitString.universal]
    case .octetString: return [ASN1.Tag.octetString.universal]
    case .objectIdentifier: return [ASN1.Tag.objectIdentifier.universal]
    case .string(let kind, _):
      switch kind {
      case .utf8: return [ASN1.Tag.utf8String.universal]
      case .numeric: return [ASN1.Tag.numericString.universal]
      case .printable: return [ASN1.Tag.printableString.universal]
      case .teletex: return [ASN1.Tag.teletexString.universal]
      case .videotex: return [ASN1.Tag.videotexString.universal]
      case .ia5: return [ASN1.Tag.ia5String.universal]
      case .graphic: return [ASN1.Tag.graphicString.universal]
      case .visible: return [ASN1.Tag.visibleString.universal]
      case .general: return [ASN1.Tag.generalString.universal]
      case .universal: return [ASN1.Tag.universalString.universal]
      case .character: return [ASN1.Tag.characterString.universal]
      case .bmp: return [ASN1.Tag.bmpString.universal]
      }
    case .time(let kind):
      switch kind {
      case .utc: return [ASN1.Tag.utcTime.universal]
      case .generalized: return [ASN1.Tag.generalizedTime.universal]
      }
    case .null: return [ASN1.Tag.null.universal]
    case .any, .dynamic: return nil
    }
  }

  public var defaultValue: ASN1? {
    switch self {
    case .type(let schema): return schema.defaultValue
    case .version(let schema): return schema.defaultValue
    case .versioned(_, let schema): return schema.defaultValue
    case .optional(let schema): return schema.defaultValue
    case .implicit(_, _, let schema): return schema.defaultValue
    case .explicit(_, _, let schema): return schema.defaultValue
    case .boolean(let defaultValue): return defaultValue.map { .boolean($0) }
    case .integer(_, let defaultValue): return defaultValue.map { .integer(BigInt($0)) }
    default: return nil
    }
  }

  public var isVersioned: Bool {
    guard case .versioned = self else { return false }
    return true
  }

  public var isDynamic: Bool {
    guard case .dynamic = self else { return false }
    return true
  }

  public var isOptional: Bool {
    switch self {
    case .type(let schema): return schema.isOptional
    case .version(let schema): return schema.isOptional
    case .versioned(_, let schema): return schema.isOptional
    case .optional: return true
    case .implicit(_, _, let schema): return schema.isOptional
    case .explicit(_, _, let schema): return schema.isOptional
    default: return false
    }
  }

  public var isBoolean: Bool {
    guard case .boolean = self else { return false }
    return true
  }

  public var isInteger: Bool {
    guard case .integer = self else { return false }
    return true
  }

  public var isReal: Bool {
    guard case .real = self else { return false }
    return true
  }

  public var isBitString: Bool {
    guard case .bitString = self else { return false }
    return true
  }

  public var isOctetString: Bool {
    guard case .octetString = self else { return false }
    return true
  }

  public var isObjectIdentifier: Bool {
    guard case .objectIdentifier = self else { return false }
    return true
  }

  public var isString: Bool {
    guard case .string = self else { return false }
    return true
  }

  public var isTime: Bool {
    guard case .time = self else { return false }
    return true
  }

  public var isNull: Bool {
    guard case .null = self else { return false }
    return true
  }

  public var isSequence: Bool {
    guard case .sequence = self else { return false }
    return true
  }

  public var isSequenceOf: Bool {
    guard case .sequenceOf = self else { return false }
    return true
  }

  public var isSetOf: Bool {
    guard case .setOf = self else { return false }
    return true
  }

}

extension Schema: CustomDebugStringConvertible {

  public var debugDescription: String {
    var result = ""
    var indent = ""

    func append(_ value: String) {
      result.append(value.replacingOccurrences(of: "\n", with: "\n\(indent)"))
    }

    switch self {
    case .sequence(let fields):
      indent += "  "
      defer {
        indent.removeLast(2)
        append("\n}")
      }

      append("SEQUENCE ::= {")

      for (field, fieldSchema) in fields {
        append("\n\(field) \(fieldSchema.debugDescription)")
      }

    case .sequenceOf(let schema, size: let size):
      indent += "  "
      defer {
        indent.removeLast(2)
      }

      append("SEQUENCE ")

      if let size = size {
        append("SIZE (\(size)) ")
      }

      append("OF\n\(schema.debugDescription)")

    case .setOf(let schema, size: let size):
      indent += "  "
      defer {
        indent.removeLast(2)
      }

      append("SET ")

      if let size = size {
        append("SIZE (\(size)) ")
      }

      append("OF\n\(schema.debugDescription)")

    case .choiceOf(let schemas):
      indent += "  "
      defer {
        indent.removeLast(2)
        append("\n}")
      }
      append("CHOICE ::= {")

      for schema in schemas {
        append("\n\(schema.debugDescription)")
      }

    case .optional(let schema):
      append("\(schema.debugDescription) OPTIONAL")

    case .implicit(let tag, let inClass, let schema):
      let tagPrefix = inClass != .contextSpecific ? String(describing: inClass).uppercased() : ""
      append("[\(tagPrefix)\(tag)] \(schema.debugDescription) ")

    case .explicit(let tag, let inClass, let schema):
      let tagPrefix = inClass != .contextSpecific ? String(describing: inClass).uppercased() : ""
      append("[\(tagPrefix)\(tag)] EXPLICIT \(schema.debugDescription) ")

    case .boolean(let def):
      append("BOOLEAN")
      if let def = def {
        append(" DEFAULT \(String(def).uppercased())")
      }

    case .integer(let allowed, let def):
      append("INTEGER")
      if let allowed = allowed {
        append(" { \(allowed.map { String($0) }.joined()) }")
      }
      if let def = def {
        append(" DEFAULT \(String(def).uppercased())")
      }

    case .bitString(let size):
      append("BIT STRING")
      if let size = size {
        append(" (\(size))")
      }

    case .octetString(let size):
      append("OCTET STRING")
      if let size = size {
        append(" (\(size))")
      }

    case .objectIdentifier:
      append("OBJECT IDENTIFIER")

    case .real:
      append("REAL")

    case .string(let type, let size):
      append("\(String(describing: type).uppercased())String")
      if let size = size {
        append(" (\(size))")
      }

    case .time(kind: let kind):
      switch kind {
      case .utc:
        append("UTCTime")
      case .generalized:
        append("GeneralizedTime")
      }

    case .null:
      append("NULL")

    case .dynamic, .any:
      append("ANY")

    case .versioned(let versionRange, let versionedSchema):
      append("\n\(versionedSchema.debugDescription) -- for version (\(versionRange.lowerBound)..\(versionRange.upperBound))")

    case .type(let schema), .version(let schema):
      append(schema.debugDescription)
    }

    return result
  }

}
