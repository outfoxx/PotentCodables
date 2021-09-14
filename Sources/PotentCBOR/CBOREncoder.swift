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

import Foundation
import PotentCodables


/// `CBOREncoder` facilitates the encoding of `Encodable` values into CBOR values.
///
public class CBOREncoder: ValueEncoder<CBOR, CBOREncoderTransform>, EncodesToData {
  // MARK: Options

  /// The strategy to use for encoding `Date` values.
  public enum DateEncodingStrategy {
    /// Encode the `Date` as a UNIX timestamp (floating point seconds since epoch).
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (integer milliseconds since epoch).
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601
  }

  /// The strategy to use in encoding dates. Defaults to `.iso8601`.
  open var dateEncodingStrategy: DateEncodingStrategy = .iso8601

  /// The options set on the top-level encoder.
  override public var options: CBOREncoderTransform.Options {
    return CBOREncoderTransform.Options(
      dateEncodingStrategy: dateEncodingStrategy,
      keyEncodingStrategy: keyEncodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}



public struct CBOREncoderTransform: InternalEncoderTransform, InternalValueSerializer {

  public typealias Value = CBOR
  public typealias Encoder = InternalValueEncoder<CBOR, Self>
  public typealias State = Void

  public static var emptyKeyedContainer = CBOR.map([:])
  public static var emptyUnkeyedContainer = CBOR.array([])

  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: CBOREncoder.DateEncodingStrategy
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public static func boxNil(encoder: Encoder) throws -> CBOR { return nil }
  public static func box(_ value: Bool, encoder: Encoder) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Int, encoder: Encoder) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int8, encoder: Encoder) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int16, encoder: Encoder) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int32, encoder: Encoder) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int64, encoder: Encoder) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: UInt, encoder: Encoder) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt8, encoder: Encoder) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt16, encoder: Encoder) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt32, encoder: Encoder) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt64, encoder: Encoder) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: String, encoder: Encoder) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Float, encoder: Encoder) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Double, encoder: Encoder) throws -> CBOR { return CBOR(value) }
  public static func box(
    _ value: Decimal,
    encoder: Encoder
  ) throws -> CBOR { return CBOR((value as NSDecimalNumber).doubleValue) }
  public static func box(_ value: Data, encoder: Encoder) throws -> CBOR { return CBOR(value) }
  public static func box(
    _ value: URL,
    encoder: Encoder
  ) throws -> CBOR { return .tagged(.uri, .utf8String(value.absoluteString)) }

  public static func box(_ value: UUID, encoder: Encoder) throws -> CBOR {
    return withUnsafeBytes(of: value) { ptr in
      let bytes = Data(ptr.bindMemory(to: UInt8.self))
      return .tagged(.uuid, .byteString(bytes))
    }
  }

  public static func box(_ value: Date, encoder: Encoder) throws -> CBOR {
    switch encoder.options.dateEncodingStrategy {
    case .iso8601: return .tagged(.iso8601DateTime, .utf8String(_iso8601Formatter.string(from: value)))
    case .secondsSince1970: return .tagged(.epochDateTime, CBOR(value.timeIntervalSince1970))
    case .millisecondsSince1970: return .tagged(.epochDateTime, CBOR(Int64(value.timeIntervalSince1970 * 1000.0)))
    }
  }

  public static func unkeyedValuesToValue(_ values: [CBOR], encoder: Encoder) -> CBOR {
    return .array(values)
  }

  public static func keyedValuesToValue(_ values: [String: CBOR], encoder: Encoder) -> CBOR {
    return .map(Dictionary(uniqueKeysWithValues: values.map { key, value in (CBOR(key), value) }))
  }

  public static func data(from value: CBOR, options: Options) throws -> Data {
    return try CBORSerialization.data(with: value)
  }

}


private let _iso8601Formatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .iso8601)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
  return formatter
}()


#if canImport(Combine)

  import Combine

  extension CBOREncoder: TopLevelEncoder {
    public typealias Output = Data
  }

#endif
