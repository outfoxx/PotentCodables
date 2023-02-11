//
//  ASN1Writer.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation


/// Write ASN.1/DER encoded data.
///
 internal class ASN1DERWriter {

  /// Write a collection of ``ASN1`` values in ASN.1/DER format.
  ///
  /// - Parameter values: Values to write.
  /// - Throws: `Error` when unable to write data.
  static func write(_ values: [ASN1]) throws -> Data {
    let writer = ASN1DERWriter()
    for value in values {
      try writer.write(value)
    }
    return writer.data
  }

  /// Write an ``ASN1`` value in ASN.1/DER format.
  ///
  /// - Parameter value: Value to write.
  /// - Throws: `Error` when unable to write data.
  static func write(_ value: ASN1) throws -> Data {
    let writer = ASN1DERWriter()
    try writer.write(value)
    return writer.data
  }

  internal private(set) var data: Data

  required init() {
    data = Data(capacity: 256)
  }

  private func append(byte: UInt8) {
    data.append(byte)
  }

  private func append(length: Int) throws {
    let value = UInt(length)

    switch value {
    case 0x0000 ..< 0x0080:
      append(byte: UInt8(value & 0x007F))

    case 0x0080 ..< 0x0100:
      append(byte: 0x81)
      append(byte: UInt8(value & 0x00FF))

    case 0x0000 ..< 0x010000:
      append(byte: 0x82)
      append(byte: UInt8((value & 0xFF00) >> 8))
      append(byte: UInt8(value & 0xFF))

    default:
      // Use big to ensure compact representation
      try append(length: BigUInt(value))
    }
  }

  private func append(length: BigUInt) throws {
    let bytes = length.derEncoded()
    guard let byteCount = Int8(exactly: bytes.count) else {
      throw ASN1Serialization.Error.lengthOverflow
    }
    append(byte: 0x80 | UInt8(byteCount))
    append(data: bytes)
  }

  private func append(data: Data) {
    self.data.append(data)
  }

  func append(tag: UInt8, length: Int) throws {
    append(byte: tag)
    try append(length: length)
  }

  private func append(tag: ASN1.Tag, length: Int) throws {
    append(byte: tag.rawValue)
    try append(length: length)
  }

  private static let zero = Data(repeating: 0, count: 1)

  private func write(_ value: ASN1) throws {
    switch value {
    case .boolean(let value):
      try append(tag: .boolean, length: 1)
      append(byte: value ? 0xFF : 0x00)

    case .integer(let value):
      let bytes = value.derEncoded()
      try append(tag: .integer, length: max(1, bytes.count))
      append(data: bytes.isEmpty ? Self.zero : bytes)

    case .bitString(let length, let data):
      try writeBitString(length: length, data: data)

    case .octetString(let value):
      try append(tag: .octetString, length: value.count)
      append(data: value)

    case .null:
      try append(tag: .null, length: 0)

    case .objectIdentifier(let fields):
      try writeObjectIdentifier(fields: fields)

    case .real(let value):
      try writeReal(value)

    case .utf8String(let value):
      let utf8 = try data(forString: value, encoding: .utf8)
      try append(tag: .utf8String, length: utf8.count)
      append(data: utf8)

    case .sequence(let values):
      let data = try Self.write(values)
      try append(tag: ASN1.Tag.sequence.constructed, length: data.count)
      append(data: data)

    case .set(let values):
      let data = try Self.write(values)
      try append(tag: ASN1.Tag.set.constructed, length: data.count)
      append(data: data)

    case .numericString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .numericString, length: ascii.count)
      append(data: ascii)

    case .printableString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .printableString, length: ascii.count)
      append(data: ascii)

    case .teletexString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .teletexString, length: ascii.count)
      append(data: ascii)

    case .videotexString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .videotexString, length: ascii.count)
      append(data: ascii)

    case .ia5String(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .ia5String, length: ascii.count)
      append(data: ascii)

    case .utcTime(let value):
      let formatter = UTCFormatters.for(timeZone: value.timeZone)
      let ascii = try data(forString: formatter.string(from: value.date), encoding: .ascii)
      try append(tag: .utcTime, length: ascii.count)
      append(data: ascii)

    case .generalizedTime(let value):
      let formatter = GeneralizedFormatters.for(timeZone: value.timeZone)
      let ascii = try data(forString: formatter.string(from: value.date), encoding: .ascii)
      try append(tag: .generalizedTime, length: ascii.count)
      append(data: ascii)

    case .graphicString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .graphicString, length: ascii.count)
      append(data: ascii)

    case .visibleString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .visibleString, length: ascii.count)
      append(data: ascii)

    case .generalString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .generalString, length: ascii.count)
      append(data: ascii)

    case .universalString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .universalString, length: ascii.count)
      append(data: ascii)

    case .characterString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .characterString, length: ascii.count)
      append(data: ascii)

    case .bmpString(let value):
      let ascii = try data(forString: value, encoding: .ascii)
      try append(tag: .bmpString, length: ascii.count)
      append(data: ascii)

    case .tagged(let tag, let data):
      try append(tag: tag, length: data.count)
      append(data: data)

    case .default:
      // DER not allowed to include default values
      break
    }
  }

  private func writeBitString(length: Int, data: Data) throws {
    let usedBits = UInt8(length % 8)
    let unusedBits = usedBits == 0 ? 0 : 8 - usedBits

    try append(tag: .bitString, length: data.count + 1)
    append(byte: unusedBits)
    append(data: data)
  }

  private func writeObjectIdentifier(fields: ([UInt64])) throws {

    func field(val: UInt64) -> Data {
      var val = val
      var result = Data(count: 9)
      var pos = 8
      result[pos] = UInt8(val & 0x7F)
      while val >= (UInt64(1) << 7) {
        val >>= 7
        pos -= 1
        result[pos] = UInt8((val & 0x7F) | 0x80)
      }
      return Data(result.dropFirst(pos))
    }

    var iter = fields.makeIterator()

    guard let first = iter.next(), let second = iter.next() else {
      throw ASN1Serialization.Error.invalidObjectIdentifierLength
    }

    var bytes = field(val: first * 40 + second)

    while let val = iter.next() {
      bytes.append(field(val: val))
    }

    try append(tag: .objectIdentifier, length: bytes.count)
    append(data: bytes)
  }

  private func writeReal(_ value: Decimal) throws {
    guard !value.isZero else {
      try append(tag: .real, length: 0)
      return
    }

    guard !value.isInfinite else {
      try append(tag: .real, length: 1)
      append(byte: 0x40 | (value.sign == .plus ? 0x0 : 0x1))
      return
    }

    // Choose ISO-6093 NR3
    var data = String(describing: value).data(using: .ascii) ?? Data()
    data.insert(0x00, at: 0)
    try append(tag: .real, length: data.count)
    append(data: data)
  }

  private func data(forString string: String, encoding: String.Encoding) throws -> Data {
    guard let data = string.data(using: encoding) else {
      throw ASN1Serialization.Error.invalidStringCharacters
    }
    return data
  }

}

private enum UTCFormatters {

  private static var utcFormatters: [TimeZone: DateFormatter] = [:]
  private static let utcFormattersLock = NSLock()

  static func `for`(timeZone: TimeZone) -> DateFormatter {
    utcFormattersLock.lock()
    defer { utcFormattersLock.unlock() }

    if let found = utcFormatters[timeZone] {
      return found
    }

    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.dateFormat = timeZone == .utc ? "yyMMddHHmmss'Z'" : "yyMMddHHmmssXX"

    utcFormatters[timeZone] = formatter

    return formatter
  }

}

private enum GeneralizedFormatters {

  private static var generalizedFormatters: [TimeZone: DateFormatter] = [:]
  private static let generalizedFormattersLock = NSLock()

  static func `for`(timeZone: TimeZone) -> DateFormatter {
    generalizedFormattersLock.lock()
    defer { generalizedFormattersLock.unlock() }

    if let found = generalizedFormatters[timeZone] {
      return found
    }

    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyyMMddHHmmss.SSSXXXX"

    generalizedFormatters[timeZone] = formatter

    return formatter
  }

}
