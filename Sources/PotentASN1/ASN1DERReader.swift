//
//  ASN1Reader.swift
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


/// Read ASN.1/DER encoded data.
///
internal enum ASN1DERReader {

  /// Parse data into a collection of ``ASN1`` values.
  ///
  /// - Parameter data: Data to be parsed.
  /// - Returns: Collection of parsed ``ASN1`` values.
  /// - Throws: ``ASN1DERReader/Error`` if `data` is unparsable or corrupted.
  public static func parse(data: Data) throws -> [ASN1] {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItems(&buffer)
    }
  }

  /// Parse explicitly tagged data into its tag and data.
  ///
  /// - Parameter data: Data to be parsed.
  /// - Returns: Parsed tag and data.
  /// - Throws: ``ASN1DERReader/Error`` if `data` is unparsable or corrupted.
  public static func parseTagged(data: Data) throws -> TaggedValue? {
    if data.isEmpty {
      return nil
    }
    return try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      let (tag, itemBuffer) = try parseTagged(&buffer)
      return TaggedValue(tag: tag, data: Data(itemBuffer))
    }
  }

  /// Parse data using specified tag.
  ///
  /// - Parameters:
  ///   - data: Data to be parsed.
  ///   - as: Tag specifying format of `data`.
  public static func parseItem(_ data: Data, as tagValue: ASN1.AnyTag) throws -> ASN1 {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItem(&buffer, as: tagValue)
    }
  }

  private static func parseTagged(_ buffer: inout UnsafeBufferPointer<UInt8>) throws
    -> (tag: ASN1.AnyTag, data: UnsafeBufferPointer<UInt8>) {
    return (try buffer.pop(), try buffer.pop(count: parseLength(&buffer)))
  }

  private static func parseItems(_ data: Data) throws -> [ASN1] {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItems(&buffer)
    }
  }

  private static func parseItems(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> [ASN1] {

    var items = [ASN1]()
    while buffer.count > 0 {
      let item = try parseItem(&buffer)
      items.append(item)
    }

    return items
  }

  private static func parseItem(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> ASN1 {
    var (tagValue, itemBuffer) = try parseTagged(&buffer)

    let item = try parseItem(&itemBuffer, as: tagValue)

    if !itemBuffer.isEmpty {
      throw ASN1Serialization.Error.invalidTaggedItem
    }

    return item
  }

  private static func parseItem(
    _ itemBuffer: inout UnsafeBufferPointer<UInt8>,
    as tagValue: ASN1.AnyTag
  ) throws -> ASN1 {

    guard let tag = ASN1.Tag(rawValue: tagValue) else {
      // Check required constructed types
      switch tagValue {
      case ASN1.Tag.sequence.constructed:
        return .sequence(try parseItems(&itemBuffer))
      case ASN1.Tag.set.constructed:
        return .set(try parseItems(&itemBuffer))
      default:
        // Default to saving tagged version
        return .tagged(tagValue, Data(try itemBuffer.popAll()))
      }
    }

    let item: ASN1

    switch tag {
    case .boolean:
      item = .boolean(try itemBuffer.pop() != 0)

    case .integer:
      item = .integer(try parseInt(&itemBuffer))

    case .bitString:
      let unusedBits = try itemBuffer.pop()
      let data = Data(try itemBuffer.popAll())
      item = .bitString((data.count * 8) - Int(unusedBits), data)

    case .octetString:
      item = .octetString(Data(try itemBuffer.popAll()))

    case .null:
      item = .null

    case .objectIdentifier:
      item = .objectIdentifier(try parseOID(&itemBuffer))

    case .real:
      item = .real(try parseReal(&itemBuffer))

    case .utf8String:
      item = .utf8String(try parseString(&itemBuffer, encoding: .utf8))

    case .numericString:
      item = .numericString(try parseString(&itemBuffer, encoding: .ascii))

    case .printableString:
      item = .printableString(try parseString(&itemBuffer, encoding: .ascii))

    case .teletexString:
      item = .teletexString(try parseString(&itemBuffer, encoding: .ascii))

    case .videotexString:
      item = .videotexString(try parseString(&itemBuffer, encoding: .ascii))

    case .ia5String:
      item = .ia5String(try parseString(&itemBuffer, encoding: .ascii))

    case .utcTime:
      item = .utcTime(try parseTime(&itemBuffer, formatter: utcFormatter))

    case .generalizedTime:
      item = .generalizedTime(try parseTime(&itemBuffer, formatter: generalizedFormatter))

    case .graphicString:
      item = .graphicString(try parseString(&itemBuffer, encoding: .ascii))

    case .visibleString:
      item = .visibleString(try parseString(&itemBuffer, encoding: .ascii))

    case .generalString:
      item = .generalString(try parseString(&itemBuffer, encoding: .ascii))

    case .universalString:
      item = .universalString(try parseString(&itemBuffer, encoding: .ascii))

    case .characterString:
      item = .characterString(try parseString(&itemBuffer, encoding: .ascii))

    case .bmpString:
      item = .bmpString(try parseString(&itemBuffer, encoding: .ascii))

    case .sequence, .set:
      throw ASN1Serialization.Error.nonConstructedCollection

    case .objectDescriptor, .external, .enumerated, .embedded, .relativeOID:
      // Default to saving tagged version
      item = .tagged(tag.rawValue, Data(try itemBuffer.popAll()))
    }

    if !itemBuffer.isEmpty {
      throw ASN1Serialization.Error.invalidTaggedItem
    }

    return item
  }

  private static func parseTime(
    _ buffer: inout UnsafeBufferPointer<UInt8>,
    formatter: SuffixedDateFormatter
  ) throws -> ZonedDate {

    guard let string = String(data: Data(try buffer.popAll()), encoding: .ascii) else {
      throw ASN1Serialization.Error.invalidStringEncoding
    }

    guard let zonedDate = formatter.date(from: string) else {
      throw ASN1Serialization.Error.invalidUTCTime
    }

    return zonedDate
  }

  private static func parseInt(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> BigInt {
    if buffer.isEmpty {
      return BigInt.zero
    }
    let data = Data(try buffer.popAll())
    return BigInt(derEncoded: data)
  }

  private static func parseReal(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> Decimal {
    let lead = try buffer.pop()
    if lead & 0x40 == 0x40 {
      throw ASN1Serialization.Error.unsupportedReal
    }
    else if lead & 0xC0 == 0 {
      let bytes = try buffer.popAll()
      return Decimal(string: String(bytes: bytes, encoding: .ascii) ?? "") ?? .zero
    }
    else {
      throw ASN1Serialization.Error.unsupportedReal
    }
  }

  private static func parseString(
    _ buffer: inout UnsafeBufferPointer<UInt8>,
    encoding: String.Encoding,
    characterSet: CharacterSet? = nil
  ) throws -> String {

    guard let string = String(data: Data(try buffer.popAll()), encoding: encoding) else {
      throw ASN1Serialization.Error.invalidStringEncoding
    }

    if let characterSet = characterSet, !string.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
      throw ASN1Serialization.Error.invalidStringCharacters
    }

    return string
  }

  private static let oidLeadingMultiplier = UInt64(40)
  private static let oidLeadingMultiplierDouble = oidLeadingMultiplier * 2

  private static func parseOID(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> [UInt64] {

    var ids = [UInt64]()
    while buffer.count > 0 {

      var val = try parseBase128(&buffer)
      if ids.isEmpty {
        if val < oidLeadingMultiplier {
          ids.append(0)
        }
        else if val < oidLeadingMultiplierDouble {
          ids.append(1)
          val -= oidLeadingMultiplier
        }
        else {
          ids.append(2)
          val -= oidLeadingMultiplierDouble
        }

      }

      ids.append(val)
    }

    return ids
  }

  private static func parseBase128(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> UInt64 {

    var val = UInt64(0)

    while true {
      let byte = try buffer.pop()
      val = val << 7
      val += UInt64(byte & 0x7F)
      if byte & 0x80 == 0 {
        break
      }
    }

    return val
  }

  private static func parseLength(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> Int {

    var length: Int = 0

    let numBytes: Int

    let lead = try buffer.pop()
    if lead > 0x80 {
      numBytes = Int(lead - 0x80)
    }
    else {
      length = Int(lead)
      numBytes = 0
    }

    for _ in 0 ..< numBytes {

      let newLength = (length &* 0x100) &+ Int(try buffer.pop())

      // Check for overflow
      if newLength < length {
        throw ASN1Serialization.Error.lengthOverflow
      }

      // Check avaiable data
      if newLength > buffer.count {
        throw ASN1Serialization.Error.unexpectedEOF
      }

      length = newLength
    }

    return length
  }

}


private extension UnsafeBufferPointer {

  mutating func popAll() throws -> UnsafeRawBufferPointer {
    guard let baseAddress = baseAddress else {
      throw ASN1Serialization.Error.unexpectedEOF
    }
    let buffer = UnsafeRawBufferPointer(start: baseAddress, count: count)
    self = UnsafeBufferPointer(start: baseAddress.advanced(by: count), count: 0)
    return buffer
  }

  mutating func pop(count: Int = 0) throws -> UnsafeBufferPointer {
    guard let baseAddress = baseAddress, self.count >= count else {
      throw ASN1Serialization.Error.unexpectedEOF
    }
    let buffer = UnsafeBufferPointer(start: baseAddress, count: count)
    self = UnsafeBufferPointer(start: baseAddress.advanced(by: count), count: self.count - count)
    return buffer
  }

  mutating func pop() throws -> Element {
    guard let baseAddress = baseAddress, self.count >= 1 else {
      throw ASN1Serialization.Error.unexpectedEOF
    }
    defer {
      self = UnsafeBufferPointer(start: baseAddress.advanced(by: 1), count: self.count - 1)
    }
    return baseAddress.pointee
  }

}

private let utcFormatter =
  SuffixedDateFormatter(basePattern: "yyMMddHHmm", secondsPattern: "ss") { $0.count > 10 }

private let generalizedFormatter =
  SuffixedDateFormatter(basePattern: "yyyyMMddHHmmss", secondsPattern: ".S") { $0.contains(".") }
