//
//  ASN1.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables


public typealias Integer = BigInt


public indirect enum ASN1: Value {

  public typealias AnyTag = UInt8

  public enum Tag: UInt8, CaseIterable, Codable {

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

    public static func tag(from value: UInt8, in tagClass: Class) -> AnyTag {
      return (value & ~0xE0) | tagClass.rawValue
    }

    public static func structuredTag(from value: AnyTag, in tagClass: Class) -> AnyTag {
      return tag(from: value, in: tagClass) | 0x20
    }

    public static func value(from tag: AnyTag, in tagClass: Class) -> AnyTag {
      return (tag & ~0xE0) & ~tagClass.rawValue
    }

    public var universal: AnyTag {
      return rawValue
    }

    public var primitive: AnyTag {
      return Self.tag(from: rawValue, in: .universal)
    }

    public var constructed: AnyTag {
      return Self.structuredTag(from: rawValue, in: .universal)
    }

  }

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
  case utcTime(Date)
  case generalizedTime(Date)
  case graphicString(String)
  case visibleString(String)
  case generalString(String)
  case universalString(String)
  case characterString(String)
  case bmpString(String)
  case tagged(UInt8, Data)
  case `default`(ASN1)


  public var isNull: Bool { return self == .null }

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

  public var anyTag: UInt8 {
    guard case .tagged(let tag, _) = self else {
      return knownTag!.universal
    }
    return tag
  }

  public var tagName: String {
    guard let knownTag = knownTag else {
      return "iMPLICIT TAGGED (\(String(anyTag, radix: 16)))"
    }
    return String(describing: knownTag)
  }

  public var unwrapped: Any? {
    switch absolute {
    case .boolean(let value): return value
    case .integer(let value): return value
    case .bitString(let value): return value
    case .octetString(let value): return value
    case .null: return nil
    case .objectIdentifier(let value): return value
    case .real(let value): return value
    case .utf8String(let value): return value
    case .sequence(let value): return value
    case .set(let value): return value
    case .numericString(let value): return value
    case .printableString(let value): return value
    case .teletexString(let value): return value
    case .videotexString(let value): return value
    case .ia5String(let value): return value
    case .utcTime(let value): return value
    case .generalizedTime(let value): return value
    case .graphicString(let value): return value
    case .visibleString(let value): return value
    case .generalString(let value): return value
    case .universalString(let value): return value
    case .characterString(let value): return value
    case .bmpString(let value): return value
    case .tagged(_, let value): return value
    case .default(let value): return value
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

  var absolute: ASN1 {
    switch self {
    case .default(let value): return value
    default: return self
    }
  }

  var booleanValue: Bool? {
    guard case .boolean(let value) = absolute else { return nil }
    return value
  }

  var integerValue: BigInt? {
    guard case .integer(let value) = absolute else { return nil }
    return value
  }

  var bitStringValue: (length: Int, bytes: Data)? {
    guard case .bitString(let value) = absolute else { return nil }
    return value
  }

  var octetStringValue: Data? {
    guard case .octetString(let value) = absolute else { return nil }
    return value
  }

  var objectIdentifierValue: [UInt64]? {
    guard case .objectIdentifier(let value) = absolute else { return nil }
    return value
  }

  var realValue: Decimal? {
    guard case .real(let value) = absolute else { return nil }
    return value
  }

  var utf8StringValue: String? {
    guard case .utf8String(let value) = absolute else { return nil }
    return value
  }

  var sequenceValue: [ASN1]? {
    guard case .sequence(let value) = absolute else { return nil }
    return value
  }

  var setValue: [ASN1]? {
    guard case .set(let value) = absolute else { return nil }
    return value
  }

  var numericStringValue: String? {
    guard case .numericString(let value) = absolute else { return nil }
    return value
  }

  var printableStringValue: String? {
    guard case .printableString(let value) = absolute else { return nil }
    return value
  }

  var teletexStringValue: String? {
    guard case .teletexString(let value) = absolute else { return nil }
    return value
  }

  var videotexStringValue: String? {
    guard case .videotexString(let value) = absolute else { return nil }
    return value
  }

  var ia5StringValue: String? {
    guard case .ia5String(let value) = absolute else { return nil }
    return value
  }

  var utcTimeValue: Date? {
    guard case .utcTime(let value) = absolute else { return nil }
    return value
  }

  var generalizedTimeValue: Date? {
    guard case .generalizedTime(let value) = absolute else { return nil }
    return value
  }

  var graphicStringValue: String? {
    guard case .graphicString(let value) = absolute else { return nil }
    return value
  }

  var visibleStringValue: String? {
    guard case .visibleString(let value) = absolute else { return nil }
    return value
  }

  var generalStringValue: String? {
    guard case .generalString(let value) = absolute else { return nil }
    return value
  }

  var universalStringValue: String? {
    guard case .universalString(let value) = absolute else { return nil }
    return value
  }

  var characterStringValue: String? {
    guard case .characterString(let value) = absolute else { return nil }
    return value
  }

  var bmpStringValue: String? {
    guard case .bmpString(let value) = absolute else { return nil }
    return value
  }

  var stringValue: (String, AnyString.Kind)? {
    switch absolute {
    case .utf8String(let value): return (value, .utf8)
    case .numericString(let value): return (value, .numeric)
    case .printableString(let value): return (value, .printable)
    case .teletexString(let value): return (value, .teletex)
    case .videotexString(let value): return (value, .videotex)
    case .ia5String(let value): return (value, .ia5)
    case .graphicString(let value): return (value, .graphic)
    case .visibleString(let value): return (value, .visible)
    case .generalString(let value): return (value, .general)
    case .universalString(let value): return (value, .universal)
    case .characterString(let value): return (value, .character)
    case .bmpString(let value): return (value, .bmp)
    default: return nil
    }
  }

  var timeValue: (Date, AnyTime.Kind)? {
    switch absolute {
    case .utcTime(let value): return (value, .utc)
    case .generalizedTime(let value): return (value, .generalized)
    default: return nil
    }
  }

  var collectionValue: [ASN1]? {
    switch absolute {
    case .set(let value): return value
    case .sequence(let value): return value
    default: return nil
    }
  }

  var octetsValue: (length: Int, bytes: Data)? {
    switch absolute {
    case .octetString(let data): return (data.count * 8, data)
    case .bitString(let length, let data): return (length, data)
    default: return nil
    }
  }

  var taggedValue: (tag: AnyTag, bytes: Data)? {
    guard case .tagged(let tag, let bytes) = absolute else { return nil }
    return (tag, bytes)
  }

}


extension ASN1: Codable {

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let tagValue = try container.decode(UInt8.self)

    guard let tag = Tag(rawValue: tagValue) else {
      let tagged = try container.decode(Tagged.self)
      self = .tagged(tagged.tag, tagged.data)
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
      self = .utcTime(try container.decode(Date.self))
    case .generalizedTime:
      self = .generalizedTime(try container.decode(Date.self))
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
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                              debugDescription: "ASN.1 tag not supported"))
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
      try container.encode(Tagged(tag: tag, data: data))
    case .default:
      fatalError()
    }
  }

}

// used to simplify codable
private struct Tagged: Codable {
  let tag: UInt8
  let data: Data
}
