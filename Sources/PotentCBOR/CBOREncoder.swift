//
//  CBOREncoder.swift
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


/// ``CBOREncoder`` facilitates the encoding of `Encodable` values into CBOR values.
///
public class CBOREncoder: ValueEncoder<CBOR, CBOREncoderTransform>, EncodesToData {

  /// Encoder with the default options
  public static let `default` = CBOREncoder()

  /// Encoder with deterministic encoding enabled
  public static let deterministic = {
    let encoder = CBOREncoder()
    encoder.deterministic = true
    return encoder
  }()

  // MARK: Options

  /// The strategy to use for encoding `Date` values.
  public enum DateEncodingStrategy {
    /// Encode the `Date` as a UNIX timestamp (floating point seconds since
    ///  epoch) tagged as ``CBOR/Tag/epochDateTime``.
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (integer milliseconds
    ///  since epoch), untagged.
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format)
    ///  tagged as ``CBOR/Tag/epochDateTime``.
    case iso8601
  }

  /// The strategy to use in encoding dates. Defaults to `.iso8601`.
  open var dateEncodingStrategy: DateEncodingStrategy = .iso8601

  /// Enables or disables CBOR deterministic encoding.
  open var deterministic: Bool = false

  /// The options set on the top-level encoder.
  override public var options: CBOREncoderTransform.Options {
    return CBOREncoderTransform.Options(
      dateEncodingStrategy: dateEncodingStrategy,
      keyEncodingStrategy: keyEncodingStrategy,
      deterministic: deterministic,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}



public struct CBOREncoderTransform: InternalEncoderTransform, InternalValueSerializer {

  public typealias Value = CBOR
  public typealias State = Void

  public static var emptyKeyedContainer = CBOR.map([:])
  public static var emptyUnkeyedContainer = CBOR.array([])

  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: CBOREncoder.DateEncodingStrategy
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let deterministic: Bool
    public let userInfo: [CodingUserInfoKey: Any]
  }

  static let interceptedTypes: [Any.Type] = [
    CBOR.Half.self,
    Date.self, NSDate.self,
    Data.self, NSData.self,
    URL.self, NSURL.self,
    UUID.self, NSUUID.self,
    Decimal.self, NSDecimalNumber.self,
    BigInt.self,
    BigUInt.self,
    AnyValue.self,
    AnyValue.AnyDictionary.self,
  ]

  public static func intercepts(_ type: Encodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type }
  }

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: IVE) throws -> CBOR {
    if let value = value as? CBOR.Half {
      return try box(value, encoder: encoder)
    }
    if let value = value as? Date {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? Data {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? URL {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? UUID {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? Decimal {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? BigInt {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? BigUInt {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? AnyValue {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? AnyValue.AnyDictionary {
      return try box(.dictionary(value), encoder: encoder)
    }
    fatalError("type not valid for intercept")
  }

  public static func boxNil(encoder: IVE) throws -> CBOR { return nil }
  public static func box(_ value: Bool, encoder: IVE) throws -> CBOR { return CBOR(value) }
  public static func box(_ value: Int, encoder: IVE) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int8, encoder: IVE) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int16, encoder: IVE) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int32, encoder: IVE) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: Int64, encoder: IVE) throws -> CBOR { return CBOR(Int64(value)) }
  public static func box(_ value: UInt, encoder: IVE) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt8, encoder: IVE) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt16, encoder: IVE) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt32, encoder: IVE) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: UInt64, encoder: IVE) throws -> CBOR { return CBOR(UInt64(value)) }
  public static func box(_ value: Float, encoder: IVE) throws -> CBOR { return .float(value) }
  public static func box(_ value: Double, encoder: IVE) throws -> CBOR { return .double(value) }
  public static func box(_ value: String, encoder: IVE) throws -> CBOR { return .utf8String(value) }

  public static func box(_ value: CBOR.Half, encoder: IVE) throws -> CBOR { return .half(value) }
  public static func box(_ value: Data, encoder: IVE) throws -> CBOR { return .byteString(value) }

  public static func box(_ value: BigInt, encoder: IVE) throws -> CBOR {
    if value.sign == .plus {
      return .tagged(.positiveBignum, .byteString(value.magnitude.serialize()))
    }
    else {
      return .tagged(.negativeBignum, .byteString((value.magnitude - 1).serialize()))
    }
  }

  public static func box(_ value: BigUInt, encoder: IVE) throws -> CBOR {
    return .tagged(.positiveBignum, .byteString(value.magnitude.serialize()))
  }

  public static func box(_ value: Decimal, encoder: IVE) throws -> CBOR {
    let exp: CBOR = value.exponent < 0
      ? .negativeInt(UInt64(bitPattern: ~Int64(value.exponent)))
      : .unsignedInt(UInt64(value.exponent))
    guard let sig = BigInt(value.significand.description) else {
      throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath,
                                                    debugDescription: "Significand cannot be represented as integer"))
    }
    let man: CBOR = value.sign == .plus
      ? .tagged(.positiveBignum, .byteString(sig.magnitude.serialize()))
      : .tagged(.negativeBignum, .byteString((sig.magnitude - 1).serialize()))
    return .tagged(.decimalFraction, .array([exp, man]))
  }

  public static func box(_ value: URL, encoder: IVE) throws -> CBOR {
    return .tagged(.uri, .utf8String(value.absoluteString))
  }

  public static func box(_ value: UUID, encoder: IVE) throws -> CBOR {
    return withUnsafeBytes(of: value) { ptr in
      let bytes = Data(ptr.bindMemory(to: UInt8.self))
      return .tagged(.uuid, .byteString(bytes))
    }
  }

  public static func box(_ value: Date, encoder: IVE) throws -> CBOR {
    switch encoder.options.dateEncodingStrategy {
    case .iso8601:
      return .tagged(.iso8601DateTime, .utf8String(ZonedDate(date: value, timeZone: .utc).iso8601EncodedString()))
    case .secondsSince1970:
      return .tagged(.epochDateTime, CBOR(value.timeIntervalSince1970))
    case .millisecondsSince1970:
      return CBOR(Int64(value.timeIntervalSince1970 * 1000.0))
    }
  }

  public static func box(_ value: AnyValue, encoder: IVE) throws -> CBOR {

    func encode(_ value: AnyValue.AnyDictionary) throws -> CBOR {
      return .map(.init(uniqueKeysWithValues: try value.map { key, value in
        let key = try box(key, encoder: encoder)
        let value = try box(value, encoder: encoder)
        return (key, value)
      }))
    }

    switch value {
    case .nil:
      return try boxNil(encoder: encoder)
    case .bool(let value):
      return try box(value, encoder: encoder)
    case .string(let value):
      return try box(value, encoder: encoder)
    case .int8(let value):
      return try box(value, encoder: encoder)
    case .int16(let value):
      return try box(value, encoder: encoder)
    case .int32(let value):
      return try box(value, encoder: encoder)
    case .int64(let value):
      return try box(value, encoder: encoder)
    case .uint8(let value):
      return try box(value, encoder: encoder)
    case .uint16(let value):
      return try box(value, encoder: encoder)
    case .uint32(let value):
      return try box(value, encoder: encoder)
    case .uint64(let value):
      return try box(value, encoder: encoder)
    case .integer(let value):
      return try box(value, encoder: encoder)
    case .unsignedInteger(let value):
      return try box(value, encoder: encoder)
    case .float16(let value):
      return try box(value, encoder: encoder)
    case .float(let value):
      return try box(value, encoder: encoder)
    case .double(let value):
      return try box(value, encoder: encoder)
    case .decimal(let value):
      return try box(value, encoder: encoder)
    case .data(let value):
      return try box(value, encoder: encoder)
    case .url(let value):
      return try box(value, encoder: encoder)
    case .uuid(let value):
      return try box(value, encoder: encoder)
    case .date(let value):
      return try box(value, encoder: encoder)
    case .array(let value):
      return .array(.init(try value.map { try box($0, encoder: encoder) }))
    case .dictionary(let value):
      return try encode(value)
    }
  }

  public static func unkeyedValuesToValue(_ values: UnkeyedValues, encoder: IVE) -> CBOR {
    return .array(CBOR.Array(values))
  }

  public static func keyedValuesToValue(_ values: KeyedValues, encoder: IVE) -> CBOR {
    return .map(CBOR.Map(uniqueKeysWithValues: values.map { key, value in (CBOR(key), value) }))
  }

  public static func data(from value: CBOR, options: Options) throws -> Data {
    var encodingOptions = CBORSerialization.EncodingOptions()
    if options.deterministic {
      encodingOptions.insert(.deterministic)
    }

    return try CBORSerialization.data(from: value, options: encodingOptions)
  }

}


extension CBOREncoder: TopLevelEncoder {
  public typealias Output = Data
}
