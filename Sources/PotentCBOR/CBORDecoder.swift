//
//  CBORDecoder.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// `CBORDecoder` facilitates the decoding of CBOR into semantic `Decodable` types.
///
public class CBORDecoder: ValueDecoder<CBOR, CBORDecoderTransform>, DecodesFromData {

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
  public typealias Decoder = InternalValueDecoder<Value, Self>
  public typealias State = Void

  public static let nilValue = CBOR.null

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let untaggedDateDecodingStrategy: CBORDecoder.UntaggedDateDecodingStrategy
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: CBOR, as type: Bool.Type, decoder: Decoder) throws -> Bool? {
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

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T where T: BinaryInteger,
    F: BinaryFloatingPoint {
    guard let result = T(exactly: round(from)) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T where T: BinaryFloatingPoint,
    F: BinaryInteger {
    guard let result = T(exactly: from) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T, F>(_ from: F, at codingPath: [CodingKey]) throws -> T where T: BinaryFloatingPoint,
    F: BinaryFloatingPoint {
    return T(from)
  }

  public static func unbox(_ value: CBOR, as type: Int.Type, decoder: Decoder) throws -> Int? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Int8.Type, decoder: Decoder) throws -> Int8? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Int16.Type, decoder: Decoder) throws -> Int16? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Int32.Type, decoder: Decoder) throws -> Int32? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Int64.Type, decoder: Decoder) throws -> Int64? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UInt.Type, decoder: Decoder) throws -> UInt? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UInt8.Type, decoder: Decoder) throws -> UInt8? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UInt16.Type, decoder: Decoder) throws -> UInt16? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UInt32.Type, decoder: Decoder) throws -> UInt32? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UInt64.Type, decoder: Decoder) throws -> UInt64? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return uint
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Float.Type, decoder: Decoder) throws -> Float? {
    switch value.untagged {
    case .double(let dbl): return try coerce(dbl, at: decoder.codingPath)
    case .float(let flt): return flt
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Double.Type, decoder: Decoder) throws -> Double? {
    switch value.untagged {
    case .double(let dbl): return dbl
    case .float(let flt): return try coerce(flt, at: decoder.codingPath)
    case .unsignedInt(let uint): return try coerce(uint, at: decoder.codingPath)
    case .negativeInt(let nint): return try -1 - coerce(nint, at: decoder.codingPath)
    case .null: return nil
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: String.Type, decoder: Decoder) throws -> String? {
    switch value.untagged {
    case .null: return nil
    case .utf8String(let string):
      return string
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: UUID.Type, decoder: Decoder) throws -> UUID? {
    switch value {
    case .null: return nil
    case .utf8String(let string):
      return UUID(uuidString: string)
    case .byteString(let data):
      var uuid = UUID_NULL
      withUnsafeMutableBytes(of: &uuid) { ptr in
        _ = data.copyBytes(to: ptr)
      }
      return UUID(uuid: uuid)
    case .tagged(.uuid, let tagged):
      guard case .byteString(let data) = tagged else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: tagged)
      }
      var uuid = UUID_NULL
      withUnsafeMutableBytes(of: &uuid) { ptr in
        _ = data.copyBytes(to: ptr)
      }
      return UUID(uuid: uuid)
    case .tagged(_, let tagged):
      return try unbox(tagged, as: UUID.self, decoder: decoder)
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Date.Type, decoder: Decoder) throws -> Date? {

    func decodeUntaggedNumericDate(from value: Double, unitsPerSeconds: Double) -> Date {
      switch decoder.options.untaggedDateDecodingStrategy {
      case .unitsSince1970:
        return Date(timeIntervalSince1970: Double(value) * unitsPerSeconds)
      case .millisecondsSince1970:
        return Date(timeIntervalSince1970: Double(value) / 1000.0)
      case .secondsSince1970:
        return Date(timeIntervalSince1970: Double(value))
      }
    }

    switch value {
    case .null: return nil
    case .utf8String(let string):
      return _iso8601Formatter.date(from: string)?.utcDate
    case .double(let double):
      return decodeUntaggedNumericDate(from: double, unitsPerSeconds: 1.0)
    case .float(let float):
      return decodeUntaggedNumericDate(from: Double(float), unitsPerSeconds: 1.0)
    case .half(let half):
      return decodeUntaggedNumericDate(from: Double(half.floatValue), unitsPerSeconds: 1.0)
    case .unsignedInt(let uint):
      return decodeUntaggedNumericDate(from: Double(uint), unitsPerSeconds: 1000.0)
    case .negativeInt(let nint):
      return decodeUntaggedNumericDate(from: Double(-1 - Int(nint)), unitsPerSeconds: 1000.0)
    case .tagged(.iso8601DateTime, let tagged):
      guard case .utf8String(let string) = tagged else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: tagged)
      }
      guard let zonedDate = _iso8601Formatter.date(from: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Invalid ISO8601 Date/Time")
      }
      return zonedDate.utcDate
    case .tagged(.epochDateTime, let tagged):
      guard tagged.isNumber else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: tagged)
      }
      guard let secondsDec = tagged.numberValue, let seconds = Double(secondsDec.description) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Invalid Numeric Date/Time")
      }
      return Date(timeIntervalSince1970: seconds)
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Data.Type, decoder: Decoder) throws -> Data? {
    switch value.untagged {
    case .null: return nil
    case .byteString(let data): return data
    case let cbor:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: cbor)
    }
  }

  public static func unbox(_ value: CBOR, as type: Decimal.Type, decoder: Decoder) throws -> Decimal? {
    guard !value.isNull else { return nil }
    let doubleValue = try unbox(value, as: Double.self, decoder: decoder)!
    return Decimal(doubleValue)
  }

  public static func valueToUnkeyedValues(_ value: CBOR, decoder: Decoder) throws -> [CBOR]? {
    guard case .array(let array) = value else { return nil }
    return array
  }

  public static func valueToKeyedValues(_ value: CBOR, decoder: Decoder) throws -> [String: CBOR]? {
    guard case .map(let map) = value else { return nil }
    return try mapToKeyedValues(map, decoder: decoder)
  }

  public static func mapToKeyedValues(_ map: [CBOR: CBOR], decoder: Decoder) throws -> [String: CBOR] {
    return try Dictionary(
      map.compactMap { key, value in
        switch key.untagged {
        case .utf8String(let str): return (str, value)
        case .unsignedInt(let uint): return (String(uint), value)
        case .negativeInt(let nint): return (String(-1 - Int(nint)), value)
        default: return nil
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


private let _iso8601Formatter = SuffixedDateFormatter.optionalFractionalSeconds(basePattern: "yyyy-MM-dd'T'HH:mm:ss")


#if canImport(Combine)

  import Combine

  extension CBORDecoder: TopLevelDecoder {
    public typealias Input = Data
  }

#endif
