/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import BigInt
import Foundation


public class DERWriter {

  public private(set) var data: Data

  public required init() {
    data = Data(capacity: 256)
  }

  public init(data: Data) {
    self.data = data
  }

  public static func write(_ values: [ASN1]) throws -> Data {
    let writer = DERWriter()
    for value in values {
      try writer.write(value)
    }
    return writer.data
  }

  public static func write(_ value: ASN1) throws -> Data {
    let writer = DERWriter()
    try writer.write(value)
    return writer.data
  }

  private func append(byte: UInt8) {
    data.append(byte)
  }

  private func append(length value: Int) {

    switch value {
    case 0x0000 ..< 0x0080:
      append(byte: UInt8(value & 0x007F))

    case 0x0080 ..< 0x0100:
      append(byte: 0x81)
      append(byte: UInt8(value & 0x00FF))

    case 0x0100 ..< 0x8000:
      append(byte: 0x82)
      append(byte: UInt8((value & 0xFF00) >> 8))
      append(byte: UInt8(value & 0xFF))

    default:
      let bytes = BigUInt(value).serialized()
      guard let byteCount = UInt8(exactly: bytes.count), byteCount <= 127 else {
        fatalError("Invalid DER length")
      }
      append(byte: 0x80 & byteCount)
      append(data: bytes)
    }
  }

  public func append(data: Data) {
    self.data.append(data)
  }

  public func append(tag: UInt8, length: Int) {
    append(byte: tag)
    append(length: length)
  }

  public func append(tag: ASN1.Tag, length: Int) {
    append(byte: tag.rawValue)
    append(length: length)
  }

  private static let zero = Data(repeating: 0, count: 1)

  public func write(_ value: ASN1) throws {
    switch value {
    case .boolean(let value):
      append(tag: .boolean, length: 1)
      append(byte: value ? 0xFF : 0x00)

    case .integer(let value):
      let bytes = value.serialized()
      append(tag: .integer, length: max(1, bytes.count))
      append(data: bytes.isEmpty ? Self.zero : bytes)

    case .bitString(let length, let data):
      let usedBits = UInt8(length % 8)
      let unusedBits = usedBits == 0 ? 0 : 8 - usedBits

      append(tag: .bitString, length: data.count + 1)
      append(byte: unusedBits)
      append(data: data)

    case .octetString(let value):
      append(tag: .octetString, length: value.count)
      append(data: value)

    case .null:
      append(tag: .null, length: 0)

    case .objectIdentifier(let value):

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

      var iter = value.makeIterator()

      let first = iter.next()!
      let second = iter.next()!

      var bytes = field(val: first * 40 + second)

      while let val = iter.next() {
        bytes.append(field(val: val))
      }

      append(tag: .objectIdentifier, length: bytes.count)
      append(data: bytes)

    case .real(let value):
      guard !value.isZero else {
        append(tag: .real, length: 0)
        return
      }
      guard !value.isInfinite else {
        append(tag: .real, length: 1)
        append(byte: 0x40 | (value.sign == .plus ? 0x0 : 0x1))
        return
      }
      // Choose ISO-6093 NR3
      var data = String(describing: value).data(using: .ascii) ?? Data()
      data.insert(0x3, at: 0)
      append(tag: .real, length: data.count)
      append(data: data)

    case .utf8String(let value):
      let utf8 = value.data(using: String.Encoding.utf8)!
      append(tag: .utf8String, length: utf8.count)
      append(data: utf8)

    case .sequence(let values):
      let data = try Self.write(values)
      append(tag: ASN1.Tag.sequence.constructed, length: data.count)
      append(data: data)

    case .set(let values):
      let data = try Self.write(values)
      append(tag: ASN1.Tag.set.constructed, length: data.count)
      append(data: data)

    case .numericString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .numericString, length: ascii.count)
      append(data: ascii)

    case .printableString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .printableString, length: ascii.count)
      append(data: ascii)

    case .teletexString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .teletexString, length: ascii.count)
      append(data: ascii)

    case .videotexString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .videotexString, length: ascii.count)
      append(data: ascii)

    case .ia5String(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .ia5String, length: ascii.count)
      append(data: ascii)

    case .utcTime(let value):
      let ascii = utcDateFormatter.string(from: value).data(using: String.Encoding.ascii)!
      append(tag: .utcTime, length: ascii.count)
      append(data: ascii)

    case .generalizedTime(let value):
      let formatter = GeneralizedFormatters.for(timeZone: value.timeZone)
      let ascii = formatter.string(from: value.date).data(using: String.Encoding.ascii)!
      append(tag: .generalizedTime, length: ascii.count)
      append(data: ascii)

    case .graphicString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .graphicString, length: ascii.count)
      append(data: ascii)

    case .visibleString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .visibleString, length: ascii.count)
      append(data: ascii)

    case .generalString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .generalString, length: ascii.count)
      append(data: ascii)

    case .universalString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .universalString, length: ascii.count)
      append(data: ascii)

    case .characterString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .characterString, length: ascii.count)
      append(data: ascii)

    case .bmpString(let value):
      let ascii = value.data(using: String.Encoding.ascii)!
      append(tag: .bmpString, length: ascii.count)
      append(data: ascii)

    case .tagged(let tag, let data):
      append(tag: tag, length: data.count)
      append(data: data)

    case .default:
      // DER not allowed to include default values
      break
    }
  }

}


private let utcDateFormatter: DateFormatter = {
  let fmt = DateFormatter()
  fmt.locale = Locale(identifier: "en_US_POSIX")
  fmt.timeZone = .utc
  fmt.dateFormat = "yyMMddHHmmss'Z'"
  return fmt
}()

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
    formatter.dateFormat = "yyyyMMddHHmmss.SSSXXXXX"

    generalizedFormatters[timeZone] = formatter

    return formatter
  }

}
