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


public enum DERReader {

  public enum Error: Swift.Error {
    case unexpectedEOF
    case invalidStringEncoding
    case invalidStringCharacters
    case nonConstructedCollection
    case invalidGeneralizedTime
  }

  public static func parse(data: Data) throws -> [ASN1] {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItems(&buffer)
    }
  }

  public static func parseTagged(data: Data) throws -> (tag: ASN1.AnyTag, data: Data) {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      let (tag, itemBuffer) = try parseTagged(&buffer)
      return (tag, Data(itemBuffer))
    }
  }

  public static func parseTagged(_ buffer: inout UnsafeBufferPointer<UInt8>) throws
    -> (tag: ASN1.AnyTag, data: UnsafeBufferPointer<UInt8>) {
    return (try buffer.pop(), try buffer.pop(count: parseLength(&buffer)))
  }

  public static func parseItems(_ data: Data) throws -> [ASN1] {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItems(&buffer)
    }
  }

  public static func parseItems(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> [ASN1] {

    var items = [ASN1]()
    while buffer.count > 0 {
      let item = try parseItem(&buffer)
      items.append(item)
    }

    return items
  }

  public static func parseItem(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> ASN1 {
    var (tagValue, itemBuffer) = try parseTagged(&buffer)
    defer {
      assert(itemBuffer.isEmpty)
    }

    return try parseItem(&itemBuffer, as: tagValue)
  }

  public static func parseItem(_ data: Data, as tagValue: ASN1.AnyTag) throws -> ASN1 {
    try data.withUnsafeBytes { ptr in
      var buffer = ptr.bindMemory(to: UInt8.self)
      return try parseItem(&buffer, as: tagValue)
    }
  }

  public static func parseItem(
    _ itemBuffer: inout UnsafeBufferPointer<UInt8>,
    as tagValue: ASN1.AnyTag
  ) throws -> ASN1 {
    defer {
      assert(itemBuffer.isEmpty)
    }

    guard let tag = ASN1.Tag(rawValue: tagValue) else {
      // Check required constructed types
      switch tagValue {
      case ASN1.Tag.sequence.constructed:
        return .sequence(try parseItems(&itemBuffer))
      case ASN1.Tag.set.constructed:
        return .set(try parseItems(&itemBuffer))
      default:
        // Default to saving tagged version
        return .tagged(tagValue, Data(itemBuffer.popAll()))
      }
    }

    switch tag {
    case .boolean:
      return .boolean(try itemBuffer.pop() != 0)

    case .integer:
      let data = Data(itemBuffer.popAll())
      return .integer(BigInt(serialized: data))

    case .bitString:
      let unusedBits = try itemBuffer.pop()
      let data = Data(itemBuffer.popAll())
      return .bitString((data.count * 8) - Int(unusedBits), data)

    case .octetString:
      return .octetString(Data(itemBuffer.popAll()))

    case .null:
      return .null

    case .objectIdentifier:
      return .objectIdentifier(try parseOID(&itemBuffer))

    case .real:
      return .real(try parseReal(&itemBuffer))

    case .utf8String:
      return .utf8String(try parseString(&itemBuffer, tag: tag, encoding: .utf8))

    case .numericString:
      return .numericString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .printableString:
      return .printableString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .teletexString:
      return .teletexString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .videotexString:
      return .videotexString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .ia5String:
      return .ia5String(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .utcTime:
      let string = try parseString(&itemBuffer, tag: tag, encoding: .ascii)
      return .utcTime(utcDateFormatter.date(from: string)!)

    case .generalizedTime:
      let string = try parseString(&itemBuffer, tag: tag, encoding: .ascii)
      guard let zonedDate = generalizedFormatter.date(from: string) else {
        throw Error.invalidGeneralizedTime
      }
      return .generalizedTime(zonedDate)

    case .graphicString:
      return .graphicString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .visibleString:
      return .visibleString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .generalString:
      return .generalString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .universalString:
      return .universalString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .characterString:
      return .characterString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .bmpString:
      return .bmpString(try parseString(&itemBuffer, tag: tag, encoding: .ascii))

    case .sequence, .set:
      throw Error.nonConstructedCollection

    case .objectDescriptor, .external, .enumerated, .embedded, .relativeOID:
      // Default to saving tagged version
      return .tagged(tag.rawValue, Data(itemBuffer.popAll()))
    }

  }

  private static func parseReal(_ buffer: inout UnsafeBufferPointer<UInt8>) throws -> Decimal {
    let lead = try buffer.pop()
    if lead & 0x40 == 0x40 {
      return lead & 0x1 == 0 ? Decimal(Double.infinity) : Decimal(-Double.infinity)
    }
    else if lead & 0x3F == 0 {
      // Choose ISO-6093 NR3
      let bytes = buffer.popAll()
      return Decimal(string: String(bytes: bytes, encoding: .ascii) ?? "") ?? .zero
    }
    else {
      fatalError("Only ISO-6903 supported")
    }
  }

  private static func parseString(
    _ buffer: inout UnsafeBufferPointer<UInt8>,
    tag: ASN1.Tag,
    encoding: String.Encoding,
    characterSet: CharacterSet? = nil
  ) throws -> String {

    guard let string = String(data: Data(buffer.popAll()), encoding: encoding) else {
      throw Error.invalidStringEncoding
    }

    if let characterSet = characterSet {
      if !string.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
        throw Error.invalidStringCharacters
      }
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
      length = (length * 0x100) + Int(try buffer.pop())
    }

    return length
  }

}


private extension UnsafeBufferPointer {

  func peek() throws -> Element {
    guard let byte = baseAddress?.pointee else {
      throw DERReader.Error.unexpectedEOF
    }
    return byte
  }

  mutating func popAll() -> UnsafeRawBufferPointer {
    let buffer = UnsafeRawBufferPointer(start: baseAddress, count: count)
    self = UnsafeBufferPointer(start: baseAddress?.advanced(by: count), count: 0)
    return buffer
  }

  mutating func pop(count: Int = 0) throws -> UnsafeBufferPointer {
    guard self.count >= count else {
      throw DERReader.Error.unexpectedEOF
    }
    let buffer = UnsafeBufferPointer(start: baseAddress, count: count)
    self = UnsafeBufferPointer(start: baseAddress?.advanced(by: count), count: self.count - count)
    return buffer
  }

  mutating func pop() throws -> Element {
    defer {
      self = UnsafeBufferPointer(start: baseAddress?.advanced(by: 1), count: self.count - 1)
    }
    return baseAddress!.pointee
  }

}


private let utcDateFormatter: DateFormatter = {
  let fmt = DateFormatter()
  fmt.timeZone = TimeZone(abbreviation: "UTC")
  fmt.dateFormat = "yyMMddHHmmss'Z'"
  return fmt
}()


private extension String {
  var hasFractionalSeconds: Bool { contains(".") }
  var hasZone: Bool { contains("+") || contains("-") || contains("Z") }
}

private let generalizedFormatter = ISO8601SuffixedDateFormatter(basePattern: "yyyyMMddHHmmss")
