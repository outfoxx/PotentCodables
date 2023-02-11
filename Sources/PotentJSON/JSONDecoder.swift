//
//  JSONDecoder.swift
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


/// ``JSONDecoder`` facilitates the decoding of JSON into semantic `Decodable` types.
///
public class JSONDecoder: ValueDecoder<JSON, JSONDecoderTransform>, DecodesFromString {

  public static let `default` = JSONDecoder()

  // MARK: Options

  /// The strategy to use for decoding `Date` values.
  public enum DateDecodingStrategy {
    /// Defer to `Date` for decoding. This is the default strategy.
    case deferredToDate

    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    case secondsSince1970

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    case millisecondsSince1970

    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601

    /// Decode the `Date` as a string parsed by the given formatter.
    case formatted(DateFormatter)

    /// Decode the `Date` as a custom value decoded by the given closure.
    case custom((_ decoder: Decoder) throws -> Date)
  }

  /// The strategy to use for decoding `Data` values.
  public enum DataDecodingStrategy {
    /// Defer to `Data` for decoding.
    case deferredToData

    /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
    case base64

    /// Decode the `Data` as a custom value decoded by the given closure.
    case custom((_ decoder: Decoder) throws -> Data)
  }

  /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
  public enum NonConformingFloatDecodingStrategy {
    /// Throw upon encountering non-conforming values. This is the default strategy.
    case `throw`

    /// Decode the values from the given representation strings.
    case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
  }

  /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
  open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate

  /// The strategy to use in decoding binary data. Defaults to `.base64`.
  open var dataDecodingStrategy: DataDecodingStrategy = .base64

  /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
  open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw

  /// The options set on the top-level decoder.
  override public var options: JSONDecoderTransform.Options {
    return JSONDecoderTransform.Options(
      dateDecodingStrategy: dateDecodingStrategy,
      dataDecodingStrategy: dataDecodingStrategy,
      nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
      keyDecodingStrategy: keyDecodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}


public struct JSONDecoderTransform: InternalDecoderTransform, InternalValueDeserializer, InternalValueParser {

  public typealias Value = JSON
  public typealias State = Void

  public static let nilValue = JSON.null

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    public let dataDecodingStrategy: JSONDecoder.DataDecodingStrategy
    public let nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  static let interceptedTypes: [Any.Type] = [
    Date.self, NSDate.self,
    Data.self, NSData.self,
    URL.self, NSURL.self,
    UUID.self, NSUUID.self,
    Float16.self,
    Decimal.self, NSDecimalNumber.self,
    BigInt.self,
    BigUInt.self,
    AnyValue.self,
  ]

  public static func intercepts(_ type: Decodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type }
  }

  public static func unbox(_ value: JSON, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
    if interceptedType == Date.self || interceptedType == NSDate.self {
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
    else if interceptedType == Float16.self {
      return try unbox(value, as: Float16.self, decoder: decoder)
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
  public static func unbox(_ value: JSON, as type: Bool.Type, decoder: IVD) throws -> Bool? {
    switch value {
    case .bool(let value): return value
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  static func overflow(_ type: Any.Type, value: Any, at codingPath: [CodingKey]) -> Error {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(value) overflows \(type)")
    return DecodingError.typeMismatch(type, context)
  }

  static func coerce<T>(_ from: JSON.Number, at codingPath: [CodingKey]) throws -> T
    where T: BinaryInteger & FixedWidthInteger {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T>(_ from: JSON.Number, at codingPath: [CodingKey]) throws -> T
    where T: BinaryFloatingPoint & LosslessStringConvertible {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  public static func unbox(_ value: JSON, as type: Int.Type, decoder: IVD) throws -> Int? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    switch value {
    case .number(let number):
      guard let int = BigInt(number.value) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Invalid integer literal")
      }
      return int
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    switch value {
    case .number(let number):
      guard let int = BigUInt(number.value) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Invalid unsigned integer literal")
      }
      return int
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Float16.Type, decoder: IVD) throws -> Float16? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .string(let string):
      if let mapped = decoder.options.mapNonConformingFloatDecodingStrategyStrings(Float16.self, value: string) {
        return mapped
      }
    case .null: return nil
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(_ value: JSON, as type: Float.Type, decoder: IVD) throws -> Float? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .string(let string):
      if let mapped = decoder.options.mapNonConformingFloatDecodingStrategyStrings(Float.self, value: string) {
        return mapped
      }
    case .null: return nil
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(_ value: JSON, as type: Double.Type, decoder: IVD) throws -> Double? {
    switch value {
    case .number(let number): return try coerce(number, at: decoder.codingPath)
    case .string(let string):
      if let mapped = decoder.options.mapNonConformingFloatDecodingStrategyStrings(Double.self, value: string) {
        return mapped
      }
    case .null: return nil
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(_ value: JSON, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    switch value {
    case .number(let number): return Decimal(string: number.value)
    case .string(let string):
      if let (_, _, nanStr) = decoder.options.nonConformingFloatDecodingStrategyStrings, string == nanStr {
        return Decimal.nan
      }
    case .null: return nil
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(_ value: JSON, as type: String.Type, decoder: IVD) throws -> String? {
    switch value {
    case .string(let string):
      return string
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    switch value {
    case .string(let string):
      guard let uuid = UUID(uuidString: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected valid UUID string")
      }
      return uuid
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: URL.Type, decoder: IVD) throws -> URL? {
    switch value {
    case .string(let string):
      guard let url = URL(string: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected valid URL string")
      }
      return url
    case .null: return nil
    case let json:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: json)
    }
  }

  public static func unbox(_ value: JSON, as type: Date.Type, decoder: IVD) throws -> Date? {

    func decodeISO8601(from value: JSON) throws -> Date? {
      guard let string = try unbox(value, as: String.self, decoder: decoder) else {
        return nil
      }
      guard let zonedDate = ZonedDate(iso8601Encoded: string) else {
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Expected date string to be ISO8601-formatted."
        ))
      }
      return zonedDate.utcDate
    }

    func decodeFormatted(from value: JSON, formatter: DateFormatter) throws -> Date? {
      guard let string = try unbox(value, as: String.self, decoder: decoder) else {
        return nil
      }
      guard let date = formatter.date(from: string) else {
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Date string does not match format expected by formatter."
        ))
      }
      return date
    }

    guard !value.isNull else { return nil }

    switch decoder.options.dateDecodingStrategy {
    case .deferredToDate:
      return try decoder.subDecode(with: value) { try Date(from: $0) }

    case .secondsSince1970:
      return try unbox(value, as: Double.self, decoder: decoder).map { Date(timeIntervalSince1970: $0) }

    case .millisecondsSince1970:
      return try unbox(value, as: Double.self, decoder: decoder).map { Date(timeIntervalSince1970: $0 / 1000.0) }

    case .iso8601:
      return try decodeISO8601(from: value)

    case .formatted(let formatter):
      return try decodeFormatted(from: value, formatter: formatter)

    case .custom(let closure):
      return try decoder.subDecode(with: value) { try closure($0) }
    }
  }

  public static func unbox(_ value: JSON, as type: Data.Type, decoder: IVD) throws -> Data? {

    func decodeBase64(from value: JSON) throws -> Data {
      guard case .string(let string) = value else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }

      guard let data = Data(base64Encoded: string) else {
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Encountered Data is not valid Base64."
        ))
      }

      return data
    }

    guard !value.isNull else { return nil }

    switch decoder.options.dataDecodingStrategy {
    case .deferredToData:
      return try decoder.subDecode(with: value) { try Data(from: $0) }

    case .base64:
      return try decodeBase64(from: value)

    case .custom(let closure):
      return try decoder.subDecode(with: value) { try closure($0) }
    }
  }

  public static func unbox(_ value: JSON, as type: AnyValue.Type, decoder: IVD) throws -> AnyValue {

    func decode(from value: JSON.Number) -> AnyValue {
      switch value.numberValue {
      case .none: return .nil
      case let int as Int:
        return MemoryLayout<Int>.size == 4 ? .int32(Int32(int)) : .int64(Int64(int))
      case let uint as UInt:
        return MemoryLayout<UInt>.size == 4 ? .uint32(UInt32(uint)) : .uint64(UInt64(uint))
      case let int as Int64:
        return .int64(Int64(int))
      case let uint as UInt64:
        return .uint64(UInt64(uint))
      case let int as BigInt:
        return .integer(int)
      case let double as Double:
        return .double(double)
      default:
        fatalError("numberValue returned unsupported value")
      }
    }

    switch value {
    case .null:
      return .nil
    case .bool(let value):
      return .bool(value)
    case .string(let value):
      return .string(value)
    case .number(let value):
      return decode(from: value)
    case .array(let value):
      return .array(try value.map { try unbox($0, as: AnyValue.self, decoder: decoder) })
    case .object(let value):
      return .dictionary(AnyValue.AnyDictionary(uniqueKeysWithValues: try value.map { key, value in
        (.string(key), try unbox(value, as: AnyValue.self, decoder: decoder))
      }))
    }
  }

  public static func valueToUnkeyedValues(_ value: JSON, decoder: IVD) throws -> UnkeyedValues? {
    guard case .array(let array) = value else { return nil }
    return array
  }

  public static func valueToKeyedValues(_ value: JSON, decoder: IVD) throws -> KeyedValues? {
    guard case .object(let dict) = value else { return nil }
    return dict
  }

  public static func value(from data: Data, options: Options) throws -> JSON {
    return try JSONSerialization.json(from: data, options: [.allowFragments])
  }

  public static func value(from string: String, options: Options) throws -> JSON {
    return try JSONSerialization.json(from: string, options: [.allowFragments])
  }

}


#if canImport(Combine)

  import Combine

  extension JSONDecoder: TopLevelDecoder {
    public typealias Input = Data
  }

#endif


extension JSONDecoderTransform.Options {

  // swiftlint:disable:next identifier_name
  var nonConformingFloatDecodingStrategyStrings: (posInf: String, negInf: String, nan: String)? {
    if case .convertFromString(positiveInfinity: let posInfStr, negativeInfinity: let negInfStr, nan: let nanStr)
        = nonConformingFloatDecodingStrategy {
      return (posInfStr, negInfStr, nanStr)
    }
    return nil
  }

  func mapNonConformingFloatDecodingStrategyStrings<F: BinaryFloatingPoint>(
    _ type: F.Type, value: String, posInf: F? = +.infinity, negInf: F? = -.infinity, nan: F? = .nan
  ) -> F? {
    if let (posInfStr, negInfStr, nanStr) = nonConformingFloatDecodingStrategyStrings {
      if value == posInfStr {
        return posInf
      }
      else if value == negInfStr {
        return negInf
      }
      else if value == nanStr {
        return nan
      }
    }
    return nil
  }

}
