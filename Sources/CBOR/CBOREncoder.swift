//
//  CBOREncoder.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


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
  public override var options: CBOREncoderTransform.Options {
    return CBOREncoderTransform.Options(dateEncodingStrategy: dateEncodingStrategy,
                                        keyEncodingStrategy: keyEncodingStrategy,
                                        userInfo: userInfo)
  }

  public override init() {
    super.init()
  }

}



public struct CBOREncoderTransform: InternalEncoderTransform, InternalValueSerializer {

  public typealias Value = CBOR

  public static let nilValue = CBOR.null
  public static var emptyKeyedContainer = CBOR.map([:])

  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: CBOREncoder.DateEncodingStrategy
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public static func box(_ value: Bool, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Int, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int8, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int16, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int32, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int64, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: UInt, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt8, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt16, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt32, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt64, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: String, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Float, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Double, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Decimal, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR((value as NSDecimalNumber).doubleValue) }
  public static func box(_ value: Data, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: URL, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR { return .tagged(.uri, .utf8String(value.absoluteString)) }

  public static func box(_ value: UUID, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR {
    return withUnsafeBytes(of: value) { ptr in
      let bytes = Data(ptr.bindMemory(to: UInt8.self))
      return .tagged(.uuid, .byteString(bytes))
    }
  }

  public static func box(_ value: Date, encoder: InternalValueEncoder<Value, Self>) throws -> CBOR {
    switch encoder.options.dateEncodingStrategy {
    case .iso8601: return .tagged(.iso8601DateTime, .utf8String(_iso8601Formatter.string(from: value)))
    case .secondsSince1970: return .tagged(.epochDateTime, CBOR(value.timeIntervalSince1970))
    case .millisecondsSince1970: return .tagged(.epochDateTime, CBOR(Int64(value.timeIntervalSince1970 * 1000.0)))
    }
  }

  public static func unkeyedValuesToValue(_ values: [CBOR]) -> CBOR {
    return .array(values)
  }

  public static func keyedValuesToValue(_ values: [String: CBOR]) -> CBOR {
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
