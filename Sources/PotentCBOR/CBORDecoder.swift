//
//  CBORDecoder.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import OrderedCollections
import PotentCodables


/// `CBORDecoder` facilitates the decoding of CBOR into semantic `Decodable` types.
///
public class CBORDecoder: ValueDecoder<CBOR, CBORDecoderTransform>, DecodesFromData {

  public static let `default` = CBORDecoder()

  /// The strategy to use for decoding untagged `Date` values.
  ///
  /// - Important: The strategy is only used when untagged numeric values are decoded as
  ///  dates, properly tagged date values are decoded according to the CBOR specification
  public enum UntaggedDateDecodingStrategy {
    /// Decode float point values as UNIX timestamp with second precision and decode
    /// integer values as a UNIX timestamp with millisecond precision.
    case unitsSince1970

    /// Decode any numeric values as a UNIX timestamp with second precision.
    case secondsSince1970

    /// Decode any numeric values as a UNIX timestamp with millisecond precision.
    case millisecondsSince1970
  }

  /// The strategy used in decoding of untagged numeric values as `Date`. Defaults to `.unitsSince1970`.
  public var untaggedDateDecodingStrategy: UntaggedDateDecodingStrategy = .unitsSince1970

  /// The options set on the top-level decoder.
  override public var options: CBORDecoderTransform.Options {
    return CBORDecoderTransform.Options(
      untaggedDateDecodingStrategy: untaggedDateDecodingStrategy,
      keyDecodingStrategy: keyDecodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}


public struct CBORDecoderTransform: InternalDecoderTransform, InternalValueDeserializer {

  public typealias Value = CBOR
  public typealias State = Void

  public static let nilValue = CBOR.null

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let untaggedDateDecodingStrategy: CBORDecoder.UntaggedDateDecodingStrategy
    public let keyDecodingStrategy: KeyDecodingStrategy
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
  ]

  public static func intercepts(_ type: Decodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type }
  }

  public static func unbox(_ value: CBOR, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
    if interceptedType == CBOR.Half.self {
      return try unbox(value, as: CBOR.Half.self, decoder: decoder)
    }
    else if interceptedType == Date.self || interceptedType == NSDate.self {
      return try unbox(value, as: Date.self, decoder: decoder)
    }
    else if interceptedType == Data.self || interceptedType == NSData.self {
      return try unbox(value, as: Data.self, decoder: decoder)
    }
    else if interceptedType == URL.self || interceptedType == NSURL.self {
      return try unbox(value, as: URL.self, decoder: decoder)
    }
    else if interceptedType == UUID.self || interceptedType == NSUUID.self {
      return try unbox(value, as: UUID.self, decoder: decoder)
    }
    else if interceptedType == Decimal.self || interceptedType == NSDecimalNumber.self {
      return try unbox(value, as: Decimal.self, decoder: decoder)
    }
    else if interceptedType == BigInt.self {
      return try unbox(value, as: BigInt.self, decoder: decoder)
    }
    else if interceptedType == BigUInt.self {
      return try unbox(value, as: BigUInt.self, decoder: decoder)
    }
    else if interceptedType == AnyValue.self {
      return try unbox(value, as: AnyValue.self, decoder: decoder)
    }
    fatalError("type not valid for intercept")
  }

  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: CBOR, as type: Bool.Type, decoder: IVD) throws -> Bool? {
    switch value {
    case .boolean(let value): return value
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  static func overflow(_ type: Any.Type, value: Any, at codingPath: [CodingKey]) -> Error {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(value) overflows \(type)")
    return DecodingError.typeMismatch(type, context)
  }

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T where T: BinaryInteger, F: BinaryInteger {
    guard let result = T(exactly: from) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T
  where T: BinaryFloatingPoint, F: BinaryInteger {
    guard let result = T(exactly: from) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T
  where T: BinaryFloatingPoint, F: BinaryFloatingPoint {
    return T(from)
  }

  public static func unbox<T: BinaryInteger>(_ value: CBOR, type: T.Type, decoder: IVD) throws -> T? {
    switch value {
    case .simple(let int):
      return try coerce(int, at: decoder.codingPath)
    case .unsignedInt(let uint):
      return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint):
      return try coerce(Int64(bitPattern: ~nint), at: decoder.codingPath)
    case .tagged(.positiveBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .plus, magnitude: BigUInt(data)), at: decoder.codingPath)
    case .tagged(.negativeBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .minus, magnitude: BigUInt(data) + 1), at: decoder.codingPath)
    case .tagged(_, let untagged):
      return try unbox(untagged, type: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox<T>(_ value: CBOR, type: T.Type, decoder: IVD) throws -> T?
  where T: BinaryFloatingPoint, T: LosslessStringConvertible {
    switch value {
    case .simple(let int):
      return try coerce(int, at: decoder.codingPath)
    case .unsignedInt(let uint):
      return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint):
      return try coerce(Int64(bitPattern: ~nint), at: decoder.codingPath)
    case .tagged(.positiveBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .plus, magnitude: BigUInt(data)), at: decoder.codingPath)
    case .tagged(.negativeBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .minus, magnitude: BigUInt(data) + 1), at: decoder.codingPath)
    case .half(let hlf):
      return try coerce(hlf, at: decoder.codingPath)
    case .float(let flt):
      return try coerce(flt, at: decoder.codingPath)
    case .double(let dbl):
      return try coerce(dbl, at: decoder.codingPath)
    case .tagged(.decimalFraction, .array(let items)) where items.count == 2:
      return try decode(fromDecimalFraction: items)
    case .tagged(_, let untagged):
      return try unbox(untagged, type: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }

    func decode(fromDecimalFraction items: [CBOR]) throws -> T {
      guard
        let exp = try? unbox(items[0], type: Int.self, decoder: decoder),
        let man = try? unbox(items[1], type: BigInt.self, decoder: decoder)
      else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }
      guard let sig = Decimal(string: man.magnitude.description) else {
        throw overflow(type, value: value, at: decoder.codingPath)
      }
      let dec = Decimal(sign: man.sign == .plus ? .plus : .minus, exponent: exp, significand: sig)
      guard let result = T(dec.description) else {
        throw overflow(type, value: value, at: decoder.codingPath)
      }
      return result
    }
  }

  public static func unbox(_ value: CBOR, type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    switch value {
    case .simple(let int):
      return Decimal(int)
    case .unsignedInt(let uint):
      return Decimal(uint)
    case .negativeInt(let nint):
      return Decimal(Int64(bitPattern: ~nint))
    case .tagged(.positiveBignum, .byteString(let data)):
      guard let result = Decimal(string: BigInt(sign: .plus, magnitude: BigUInt(data)).description) else {
        throw overflow(Decimal.self, value: value, at: decoder.codingPath)
      }
      return result
    case .tagged(.negativeBignum, .byteString(let data)):
      guard let result = Decimal(string: BigInt(sign: .minus, magnitude: BigUInt(data) + 1).description) else {
        throw overflow(Decimal.self, value: value, at: decoder.codingPath)
      }
      return result
    case .half(let hlf):
      return Decimal(Double(hlf))
    case .float(let flt):
      return Decimal(Double(flt))
    case .double(let dbl):
      return Decimal(dbl)
    case .tagged(.decimalFraction, .array(let items)) where items.count == 2:
      return try decode(fromDecimalFraction: items)
    case .tagged(_, let untagged):
      return try unbox(untagged, type: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }

    func decode(fromDecimalFraction items: [CBOR]) throws -> Decimal {
      guard
        let exp = try? unbox(items[0], type: Int.self, decoder: decoder),
        let man = try? unbox(items[1], type: BigInt.self, decoder: decoder)
      else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }
      // CHECK: Decimal(exactly:) is a fatal error for all inputs?
      guard let sig = Decimal(string: man.magnitude.description) else {
        throw overflow(Decimal.self, value: value, at: decoder.codingPath)
      }
      return Decimal(sign: man.sign == .plus ? .plus : .minus, exponent: exp, significand: sig)
    }
  }

  public static func unbox(_ value: CBOR, as type: Int.Type, decoder: IVD) throws -> Int? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: CBOR.Half.Type, decoder: IVD) throws -> CBOR.Half? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Float.Type, decoder: IVD) throws -> Float? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Double.Type, decoder: IVD) throws -> Double? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    return try unbox(value, type: type, decoder: decoder)
  }

  public static func unbox(_ value: CBOR, as type: String.Type, decoder: IVD) throws -> String? {
    switch value {
    case .utf8String(let string), .tagged(_, .utf8String(let string)): return string
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox(_ value: CBOR, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    switch value {
    case .utf8String(let string), .tagged(.uuid, .utf8String(let string)):
      return try decode(from: string)
    case .byteString(let data), .tagged(.uuid, .byteString(let data)):
      return try decode(from: data)
    case .tagged(_, let tagged): return try unbox(tagged, as: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }

    func decode(from string: String) throws -> UUID {
      guard let result = UUID(uuidString: string) else {
        throw DecodingError.typeMismatch(type, .init(codingPath: decoder.codingPath,
                                                     debugDescription: "Expected properly formatted UUID string"))
      }
      return result
    }

    func decode(from data: Data) throws -> UUID {
      guard data.count == MemoryLayout<uuid_t>.size else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }
      var uuid = UUID_NULL
      withUnsafeMutableBytes(of: &uuid) { ptr in
        _ = data.copyBytes(to: ptr)
      }
      return UUID(uuid: uuid)
    }
  }

  public static func unbox(_ value: CBOR, as type: URL.Type, decoder: IVD) throws -> URL? {
    switch value {
    case .utf8String(let string), .tagged(.uri, .utf8String(let string)):
      guard let url = URL(string: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected URL string")
      }
      return url
    case .tagged(_, let tagged): return try unbox(tagged, as: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox(_ value: CBOR, as type: Date.Type, decoder: IVD) throws -> Date? {

    switch value {
    case .utf8String(let string), .tagged(.iso8601DateTime, .utf8String(let string)):
      return try decode(from: string)
    case .tagged(.epochDateTime, let number):
      return try unbox(number, type: TimeInterval.self, decoder: decoder).map { Date(timeIntervalSince1970: $0) }
    case .unsignedInt, .negativeInt, .simple, .tagged(.positiveBignum, _), .tagged(.negativeBignum, _):
      return try unbox(value, type: Int64.self, decoder: decoder).map {
        decode(fromUntaggedNumericDate: TimeInterval($0), unitsPerSeconds: 1000.0)
      }
    case .double, .float, .half, .tagged(.decimalFraction, _):
      return try unbox(value, type: TimeInterval.self, decoder: decoder).map {
        decode(fromUntaggedNumericDate: $0, unitsPerSeconds: 1.0)
      }
    case .tagged(_, let tagged):
      return try unbox(tagged, as: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }

    func decode(from string: String) throws -> Date {
      guard let date = ZonedDate(iso8601Encoded: string) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Expected date string to be ISO8601-formatted."))
      }
      return date.utcDate
    }

    func decode(fromUntaggedNumericDate value: TimeInterval, unitsPerSeconds: Double) -> Date {
      switch decoder.options.untaggedDateDecodingStrategy {
      case .unitsSince1970:
        return Date(timeIntervalSince1970: value / unitsPerSeconds)
      case .millisecondsSince1970:
        return Date(timeIntervalSince1970: value / 1000.0)
      case .secondsSince1970:
        return Date(timeIntervalSince1970: value)
      }
    }
  }

  public static func unbox(_ value: CBOR, as type: Data.Type, decoder: IVD) throws -> Data? {
    switch value {
    case .byteString(let data), .tagged(_, .byteString(let data)): return data
    case .tagged(.base64, .utf8String(let string)):
      guard let data = Data(base64Encoded: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected Base64 encoded string")
      }
      return data
    case .tagged(.base64Url, .utf8String(let string)):
      guard let data = Data(base64UrlEncoded: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected URL Safe Base64 encoded string")
      }
      return data
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox(_ value: CBOR, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    switch value {
    case .simple(let value): return BigInt(exactly: value)
    case .unsignedInt(let value): return BigInt(exactly: value)
    case .negativeInt(let value): return BigInt(exactly: Int64(bitPattern: ~value))
    case .tagged(.positiveBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .plus, magnitude: BigUInt(data)), at: decoder.codingPath)
    case .tagged(.negativeBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .minus, magnitude: BigUInt(data) + 1), at: decoder.codingPath)
    case .tagged(_, let tagged): return try unbox(tagged, as: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox(_ value: CBOR, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    switch value {
    case .simple(let value): return BigUInt(exactly: value)
    case .unsignedInt(let value): return BigUInt(exactly: value)
    case .tagged(.positiveBignum, .byteString(let data)):
      return try coerce(BigInt(sign: .plus, magnitude: BigUInt(data)), at: decoder.codingPath)
    case .tagged(_, let untagged): return try unbox(untagged, as: type, decoder: decoder)
    case .null: return nil
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
  }

  public static func unbox(_ value: CBOR, as type: AnyValue.Type, decoder: IVD) throws -> AnyValue {
    switch value {
    case .null, .undefined:
      return .nil
    case .boolean(let value):
      return .bool(value)
    case .utf8String(let value):
      return .string(value)
    case .byteString(let value):
      return .data(value)
    case .simple(let value):
      return .uint8(value)
    case .unsignedInt(let value):
      if value <= Int64.max {
        return .int64(Int64(value))
      }
      else {
        return .uint64(value)
      }
    case .negativeInt(let value):
      return .int64(Int64(bitPattern: ~value))
    case .float(let value):
      return .float(value)
    case .half(let value):
      return .float16(value)
    case .double(let value):
      return .double(value)
    case .array(let value):
      return .array(try value.map { try unbox($0, as: AnyValue.self, decoder: decoder) })
    case .map(let value):
      return try dictionary(from: value)
    case .tagged(.positiveBignum, _), .tagged(.negativeBignum, _):
      guard let int = try unbox(value, as: BigInt.self, decoder: decoder) else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: BigInt.self, reality: value)
      }
      return .integer(int)
    case .tagged(.decimalFraction, _):
      guard let decimal = try unbox(value, as: Decimal.self, decoder: decoder) else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: Decimal.self, reality: value)
      }
      return .decimal(decimal)
    case .tagged(.iso8601DateTime, _), .tagged(.epochDateTime, _):
      guard let date = try unbox(value, as: Date.self, decoder: decoder) else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: Date.self, reality: value)
      }
      return .date(date)
    case .tagged(.uuid, _):
      return try unbox(value, as: UUID.self, decoder: decoder).map { .uuid($0) } ?? .nil
    case .tagged(.uri, _):
      return try unbox(value, as: URL.self, decoder: decoder).map { .url($0) } ?? .nil
    case .tagged(.base64, _), .tagged(.base64Url, _):
      return try unbox(value, as: Data.self, decoder: decoder).map { .data($0) } ?? .nil
    case .tagged(_, let untagged):
      return try unbox(untagged, as: AnyValue.self, decoder: decoder)
    }

    func dictionary(from value: CBOR.Map) throws -> AnyValue {
      return .dictionary(.init(uniqueKeysWithValues: try value.map { key, value in
        let key = try unbox(key, as: AnyValue.self, decoder: decoder)
        let value = try unbox(value, as: AnyValue.self, decoder: decoder)
        return (key, value)
      }))
    }
  }

  public static func valueToUnkeyedValues(_ value: CBOR, decoder: IVD) throws -> UnkeyedValues? {
    guard case .array(let array) = value else { return nil }
    return array
  }

  public static func valueToKeyedValues(_ value: CBOR, decoder: IVD) throws -> KeyedValues? {
    guard case .map(let map) = value else { return nil }
    return try KeyedValues(
      map.map { key, value in
        switch key {
        case .utf8String(let stringKey), .tagged(_, .utf8String(let stringKey)):
          return (stringKey, value)
        case .unsignedInt(let intKey), .tagged(_, .unsignedInt(let intKey)):
          return (String(intKey), value)
        case .negativeInt(let nintKey), .tagged(_, .negativeInt(let nintKey)):
          return (String(Int64(bitPattern: ~nintKey)), value)
        default:
          throw DecodingError.dataCorrupted(.init(
            codingPath: decoder.codingPath,
            debugDescription: "Map contains unsupported keys"
          ))
        }
      },
      uniquingKeysWith: { _, _ in
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Map contains duplicate keys"
        ))
      }
    )
  }

  public static func value(from data: Data, options: Options) throws -> CBOR {
    return try CBORSerialization.cbor(from: data)
  }

}

extension Data {

  init?(base64UrlEncoded string: String) {
    self.init(base64Encoded: string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/"))
  }

}


#if canImport(Combine)

  import Combine

  extension CBORDecoder: TopLevelDecoder {
    public typealias Input = Data
  }

#endif
