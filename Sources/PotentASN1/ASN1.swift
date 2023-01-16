//
//  ASN1.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables


/// General ASN.1 Value.
///
public indirect enum ASN1: Value {

  /// ASN.1 Tag Code
  public typealias AnyTag = UInt8

  /// ASN.1 Tag
  public enum Tag: UInt8, CaseIterable, Codable {

    /// Class of ASN.1 Tag
    public enum Class: UInt8 {
      case universal = 0x00
      case application = 0x40
      case contextSpecific = 0x80
      case `private` = 0xC0
    }

    case boolean = 1
    case integer = 2
    case bitString = 3
    case octetString = 4
    case null = 5
    case objectIdentifier = 6
    case objectDescriptor = 7
    case external = 8
    case real = 9
    case enumerated = 10
    case embedded = 11
    case utf8String = 12
    case relativeOID = 13
    case sequence = 16
    case set = 17
    case numericString = 18
    case printableString = 19
    case teletexString = 20
    case videotexString = 21
    case ia5String = 22
    case utcTime = 23
    case generalizedTime = 24
    case graphicString = 25
    case visibleString = 26
    case generalString = 27
    case universalString = 28
    case characterString = 29
    case bmpString = 30

    /// Creates an ASN.1 tag from the tag code (``AnyTag``), ``Class``, and if the tag is constructed.
    public static func tag(from value: UInt8, in tagClass: Class, constructed: Bool) -> AnyTag {
      return (value & ~0xE0) | tagClass.rawValue | (constructed ? 0x20 : 0x00)
    }

    /// Creates an ASN.1 tag code (``AnyTag``), from an existing tag code and ``Class``.
    public static func value(from tag: AnyTag, in tagClass: Class) -> AnyTag {
      return (tag & ~0xE0) & ~tagClass.rawValue
    }

    /// Universal version of this tag.
    public var universal: AnyTag {
      return rawValue
    }

    /// Primitive version of this tag.
    public var primitive: AnyTag {
      return Self.tag(from: rawValue, in: .universal, constructed: false)
    }

    /// Constructed version of this tag.
    public var constructed: AnyTag {
      return Self.tag(from: rawValue, in: .universal, constructed: true)
    }

  }

  public typealias Integer = BigInt

  case boolean(Bool)
  case integer(BigInt)
  case bitString(Int, Data)
  case octetString(Data)
  case null
  case objectIdentifier([UInt64])
  case real(Decimal)
  case utf8String(String)
  case sequence([ASN1])
  case set([ASN1])
  case numericString(String)
  case printableString(String)
  case teletexString(String)
  case videotexString(String)
  case ia5String(String)
  case utcTime(ZonedDate)
  case generalizedTime(ZonedDate)
  case graphicString(String)
  case visibleString(String)
  case generalString(String)
  case universalString(String)
  case characterString(String)
  case bmpString(String)
  case tagged(UInt8, Data)
  case `default`(ASN1)

  /// Check if this value is an ASN.1 ``null``.
  public var isNull: Bool { return self == .null }

  /// Known tag for this ASN.1 value, if available.
  ///
  /// If the tag is not an explicitly known tag, the value will be `nil`.
  ///
  public var knownTag: Tag? {
    switch self {
    case .boolean: return Tag.boolean
    case .integer: return Tag.integer
    case .bitString: return Tag.bitString
    case .octetString: return Tag.octetString
    case .null: return Tag.null
    case .objectIdentifier: return Tag.objectIdentifier
    case .real: return Tag.real
    case .utf8String: return Tag.utf8String
    case .sequence: return Tag.sequence
    case .set: return Tag.set
    case .numericString: return Tag.numericString
    case .printableString: return Tag.printableString
    case .teletexString: return Tag.teletexString
    case .videotexString: return Tag.videotexString
    case .ia5String: return Tag.ia5String
    case .utcTime: return Tag.utcTime
    case .generalizedTime: return Tag.generalizedTime
    case .graphicString: return Tag.graphicString
    case .visibleString: return Tag.visibleString
    case .generalString: return Tag.generalString
    case .universalString: return Tag.universalString
    case .characterString: return Tag.characterString
    case .bmpString: return Tag.bmpString
    case .default(let value): return value.knownTag
    default: return nil
    }
  }

  /// Tag code for this ASN.1 value.
  ///
  public var anyTag: AnyTag {
    guard case .tagged(let tag, _) = self else {
      return knownTag!.universal
    }
    return tag
  }

  /// Name of the tag for this value in ASN.1 notation.
  public var tagName: String {
    guard let knownTag = knownTag else {
      return "IMPLICIT TAGGED (\(String(anyTag, radix: 16)))"
    }
    return String(describing: knownTag)
  }

  public var unwrapped: Any? {
    switch absolute {
    case .boolean(let value): return value
    case .integer(let value): return value
    case .bitString(let length, let bytes): return BitString(length: length, bytes: bytes).bitFlags
    case .octetString(let value): return value
    case .null: return nil
    case .objectIdentifier(let fields): return fields
    case .real(let value): return value
    case .utf8String(let value): return value
    case .sequence(let values): return Array(values.map(\.unwrapped))
    case .set(let values): return Array(values.map(\.unwrapped))
    case .numericString(let value): return value
    case .printableString(let value): return value
    case .teletexString(let value): return value
    case .videotexString(let value): return value
    case .ia5String(let value): return value
    case .utcTime(let value): return value.utcDate
    case .generalizedTime(let value): return value.utcDate
    case .graphicString(let value): return value
    case .visibleString(let value): return value
    case .generalString(let value): return value
    case .universalString(let value): return value
    case .characterString(let value): return value
    case .bmpString(let value): return value
    case .tagged(_, let data): return data
    case .default(let value): return value.unwrapped
    }
  }

  /// Current value as ASN1 type.
  ///
  /// Returns equivalent types as the value accessors (e.g. ``booleanValue``).
  ///
  public var currentValue: Any? {
    switch absolute {
    case .boolean(let value): return value
    case .integer(let value): return value
    case .bitString(let length, let bytes): return BitString(length: length, bytes: bytes)
    case .octetString(let value): return value
    case .null: return nil
    case .objectIdentifier(let fields): return ObjectIdentifier(fields)
    case .real(let value): return value
    case .utf8String(let value): return AnyString(value, kind: .utf8)
    case .sequence(let values): return values
    case .set(let values): return values
    case .numericString(let value): return AnyString(value, kind: .numeric)
    case .printableString(let value): return AnyString(value, kind: .printable)
    case .teletexString(let value): return AnyString(value, kind: .teletex)
    case .videotexString(let value): return AnyString(value, kind: .videotex)
    case .ia5String(let value): return AnyString(value, kind: .ia5)
    case .utcTime(let value): return AnyTime(value, kind: .utc)
    case .generalizedTime(let value): return AnyTime(value, kind: .generalized)
    case .graphicString(let value): return AnyString(value, kind: .graphic)
    case .visibleString(let value): return AnyString(value, kind: .visible)
    case .generalString(let value): return AnyString(value, kind: .general)
    case .universalString(let value): return AnyString(value, kind: .universal)
    case .characterString(let value): return AnyString(value, kind: .character)
    case .bmpString(let value): return AnyString(value, kind: .bmp)
    case .tagged: return self
    case .default(let value): return value.currentValue
    }
  }

}


public func == (lhs: ASN1.Tag, rhs: ASN1.AnyTag) -> Bool {
  return lhs.rawValue == rhs
}

public func == (lhs: ASN1.AnyTag, rhs: ASN1.Tag) -> Bool {
  return lhs == rhs.rawValue
}


extension ASN1.Tag: CustomStringConvertible {

  /// Name of the tag in ASN.1 notation.
  public var description: String {
    switch self {
    case .boolean: return "BOOLEAN"
    case .integer: return "INTEGER"
    case .bitString: return "BIT STRING"
    case .octetString: return "OCTET STRING"
    case .null: return "NULL"
    case .objectIdentifier: return "OBJECT IDENTIFIER"
    case .objectDescriptor: return "OBJECT DESCRIPTOR"
    case .external: return "EXTERNAL"
    case .real: return "REAL"
    case .enumerated: return "ENUMERATED"
    case .embedded: return "EMBEDDED"
    case .utf8String: return "UTF8String"
    case .relativeOID: return "RELATIVE OID"
    case .sequence: return "SEQUENCE"
    case .set: return "SET"
    case .numericString: return "NumericString"
    case .printableString: return "PrintableString"
    case .teletexString: return "TeletexString"
    case .videotexString: return "VideotexString"
    case .ia5String: return "IA5String"
    case .utcTime: return "UTCTime"
    case .generalizedTime: return "GeneralizedTime"
    case .graphicString: return "GraphicString"
    case .visibleString: return "VisibleString"
    case .generalString: return "GeneralString"
    case .universalString: return "UniversalString"
    case .characterString: return "CharacterString"
    case .bmpString: return "BMPString"
    }
  }

}


public extension ASN1 {

  /// Unwrap the ``default(_:)`` modifier, if present.
  var absolute: ASN1 {
    switch self {
    case .default(let value): return value
    default: return self
    }
  }

  /// Values as boolean or `nil` if this is not a ``boolean(_:)``.
  var booleanValue: Bool? {
    guard case .boolean(let value) = absolute else { return nil }
    return value
  }

  /// Values as ``BigInt`` or `nil` if this is not an ``integer(_:)``.
  var integerValue: BigInt? {
    guard case .integer(let value) = absolute else { return nil }
    return value
  }

  /// Values as ``BitString`` or `nil` if this is not a ``bitString(_:)``.
  var bitStringValue: BitString? {
    guard case .bitString(let length, let bytes) = absolute else { return nil }
    return BitString(length: length, bytes: bytes)
  }

  /// Values as `Data` or `nil` if this is not an ``octetString(_:)``.
  var octetStringValue: Data? {
    guard case .octetString(let value) = absolute else { return nil }
    return value
  }

  /// Values as ``[UInt64]`` or `nil` if this is not an ``objectIdentifier(_:)``.
  var objectIdentifierValue: ObjectIdentifier? {
    guard case .objectIdentifier(let value) = absolute else { return nil }
    return ObjectIdentifier(value)
  }

  /// Values as decimal or `nil` if this is not a ``real(_:)``.
  var realValue: Decimal? {
    guard case .real(let value) = absolute else { return nil }
    return value
  }

  /// Values as ``AnyString`` or `nil` if this is not a ``utf8String(_:)``.
  var utf8StringValue: AnyString? {
    guard case .utf8String(let value) = absolute else { return nil }
    return AnyString(value, kind: .utf8)
  }

  /// Value as array of ``ASN1`` or `nil` if this is not a ``sequence(_:)``.
  var sequenceValue: [ASN1]? {
    guard case .sequence(let value) = absolute else { return nil }
    return value
  }

  /// Value as array of ``ASN1`` or `nil` if this is not a ``set(_:)``.
  var setValue: [ASN1]? {
    guard case .set(let value) = absolute else { return nil }
    return value
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``numericString(_:)``.
  var numericStringValue: AnyString? {
    guard case .numericString(let value) = absolute else { return nil }
    return AnyString(value, kind: .numeric)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``printableString(_:)``.
  var printableStringValue: AnyString? {
    guard case .printableString(let value) = absolute else { return nil }
    return AnyString(value, kind: .printable)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``teletexString(_:)``.
  var teletexStringValue: AnyString? {
    guard case .teletexString(let value) = absolute else { return nil }
    return AnyString(value, kind: .teletex)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``videotexString(_:)``.
  var videotexStringValue: AnyString? {
    guard case .videotexString(let value) = absolute else { return nil }
    return AnyString(value, kind: .videotex)
  }

  /// Value as ``AnyString`` or `nil` if this is not an ``ia5String(_:)``.
  var ia5StringValue: AnyString? {
    guard case .ia5String(let value) = absolute else { return nil }
    return AnyString(value, kind: .ia5)
  }

  /// Value as ``AnyTime `` or `nil` if this is not a ``utcTime(_:)``.
  var utcTimeValue: AnyTime? {
    guard case .utcTime(let value) = absolute else { return nil }
    return AnyTime(value, kind: .utc)
  }

  /// Value as ``AnyTime `` or `nil` if this is not a ``generalizedTime(_:)``.
  var generalizedTimeValue: AnyTime? {
    guard case .generalizedTime(let value) = absolute else { return nil }
    return AnyTime(value, kind: .generalized)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``graphicString(_:)``.
  var graphicStringValue: AnyString? {
    guard case .graphicString(let value) = absolute else { return nil }
    return AnyString(value, kind: .graphic)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``visibleString(_:)``.
  var visibleStringValue: AnyString? {
    guard case .visibleString(let value) = absolute else { return nil }
    return AnyString(value, kind: .visible)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``generalString(_:)``.
  var generalStringValue: AnyString? {
    guard case .generalString(let value) = absolute else { return nil }
    return AnyString(value, kind: .general)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``universalString(_:)``.
  var universalStringValue: AnyString? {
    guard case .universalString(let value) = absolute else { return nil }
    return AnyString(value, kind: .universal)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``characterString(_:)``.
  var characterStringValue: AnyString? {
    guard case .characterString(let value) = absolute else { return nil }
    return AnyString(value, kind: .character)
  }

  /// Value as ``AnyString`` or `nil` if this is not a ``bmpString(_:)``.
  var bmpStringValue: AnyString? {
    guard case .bmpString(let value) = absolute else { return nil }
    return AnyString(value, kind: .bmp)
  }

  /// Value as ``AnyString`` or `nil` if this is not one of the string values.
  var stringValue: AnyString? {
    switch absolute {
    case .utf8String(let value): return AnyString(value, kind: .utf8)
    case .numericString(let value): return AnyString(value, kind: .numeric)
    case .printableString(let value): return AnyString(value, kind: .printable)
    case .teletexString(let value): return AnyString(value, kind: .teletex)
    case .videotexString(let value): return AnyString(value, kind: .videotex)
    case .ia5String(let value): return AnyString(value, kind: .ia5)
    case .graphicString(let value): return AnyString(value, kind: .graphic)
    case .visibleString(let value): return AnyString(value, kind: .visible)
    case .generalString(let value): return AnyString(value, kind: .general)
    case .universalString(let value): return AnyString(value, kind: .universal)
    case .characterString(let value): return AnyString(value, kind: .character)
    case .bmpString(let value): return AnyString(value, kind: .bmp)
    default: return nil
    }
  }

  /// Value as ``AnyTime`` or `nil` if this is not one of the time values.
  var timeValue: AnyTime? {
    switch absolute {
    case .utcTime(let date): return AnyTime(date, kind: .utc)
    case .generalizedTime(let date): return AnyTime(date, kind: .generalized)
    default: return nil
    }
  }

  /// Value as array of ``ASN`` or `nil` if this is not a ``sequence(_:)`` or ``set(_:)``.
  var collectionValue: [ASN1]? {
    switch absolute {
    case .set(let value): return value
    case .sequence(let value): return value
    default: return nil
    }
  }

  /// Value as ``TaggedValue`` or `nil` if this is not a ``tagged(_:_:)``.
  var taggedValue: TaggedValue? {
    guard case .tagged(let tag, let data) = absolute else { return nil }
    return TaggedValue(tag: tag, data: data)
  }

}


extension ASN1: Codable {

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let tagValue = try container.decode(UInt8.self)

    guard let tag = Tag(rawValue: tagValue) else {
      let taggedValue = try container.decode(TaggedValue.self)
      self = .tagged(taggedValue.tag, taggedValue.data)
      return
    }

    switch tag {
    case .boolean:
      self = .boolean(try container.decode(Bool.self))
    case .integer:
      self = .integer(try container.decode(BigInt.self))
    case .bitString:
      let bitString = try container.decode(BitString.self)
      self = .bitString(bitString.length, bitString.bytes)
    case .octetString:
      self = .octetString(try container.decode(Data.self))
    case .null:
      self = .null
    case .objectIdentifier:
      self = .objectIdentifier(try container.decode([UInt64].self))
    case .real:
      self = .real(try container.decode(Decimal.self))
    case .utf8String:
      self = .utf8String(try container.decode(String.self))
    case .sequence:
      self = .sequence(try container.decode([ASN1].self))
    case .set:
      self = .set(try container.decode([ASN1].self))
    case .numericString:
      self = .numericString(try container.decode(String.self))
    case .printableString:
      self = .printableString(try container.decode(String.self))
    case .teletexString:
      self = .teletexString(try container.decode(String.self))
    case .videotexString:
      self = .videotexString(try container.decode(String.self))
    case .ia5String:
      self = .ia5String(try container.decode(String.self))
    case .utcTime:
      self = .utcTime(try container.decode(ZonedDate.self))
    case .generalizedTime:
      self = .generalizedTime(try container.decode(ZonedDate.self))
    case .graphicString:
      self = .graphicString(try container.decode(String.self))
    case .visibleString:
      self = .visibleString(try container.decode(String.self))
    case .generalString:
      self = .generalString(try container.decode(String.self))
    case .universalString:
      self = .universalString(try container.decode(String.self))
    case .characterString:
      self = .characterString(try container.decode(String.self))
    case .bmpString:
      self = .bmpString(try container.decode(String.self))
    case .objectDescriptor, .external, .enumerated, .embedded, .relativeOID:
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "ASN.1 tag not supported"
      ))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(anyTag)
    switch absolute {
    case .boolean(let value):
      try container.encode(value)
    case .integer(let value):
      try container.encode(value)
    case .bitString(let length, let bytes):
      try container.encode(BitString(length: length, bytes: bytes))
    case .octetString(let data):
      try container.encode(data)
    case .null:
      try container.encodeNil()
    case .objectIdentifier(let fields):
      try container.encode(fields)
    case .real(let value):
      try container.encode(value)
    case .utf8String(let value):
      try container.encode(value)
    case .sequence(let elements):
      try container.encode(elements)
    case .set(let elements):
      try container.encode(elements)
    case .numericString(let value):
      try container.encode(value)
    case .printableString(let value):
      try container.encode(value)
    case .teletexString(let value):
      try container.encode(value)
    case .videotexString(let value):
      try container.encode(value)
    case .ia5String(let value):
      try container.encode(value)
    case .utcTime(let value):
      try container.encode(value)
    case .generalizedTime(let value):
      try container.encode(value)
    case .graphicString(let value):
      try container.encode(value)
    case .visibleString(let value):
      try container.encode(value)
    case .generalString(let value):
      try container.encode(value)
    case .universalString(let value):
      try container.encode(value)
    case .characterString(let value):
      try container.encode(value)
    case .bmpString(let value):
      try container.encode(value)
    case .tagged(let tag, let data):
      try container.encode(TaggedValue(tag: tag, data: data))
    case .default:
      fatalError()
    }
  }

}
