//
//  YAMLDecoder.swift
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


/// ``YAMLDecoder`` facilitates the decoding of YAML into semantic `Decodable` types.
///
public class YAMLDecoder: ValueDecoder<YAML, YAMLDecoderTransform>, DecodesFromString {

  public static let `default` = YAMLDecoder()

  // MARK: Options

  /// The strategy to use for decoding `Date` values.
  public enum DateDecodingStrategy {
    /// Defer to `Date` for decoding. This is the default strategy.
    case deferredToDate

    /// Decode the `Date` as a UNIX timestamp from a YAML number.
    case secondsSince1970

    /// Decode the `Date` as UNIX millisecond timestamp from a YAML number.
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

  /// The strategy to use for YAML-conforming floating-point values (IEEE 754 infinity and NaN).
  public enum NonConformingFloatDecodingStrategy {

    /// Decode values following the YAML 1.2 sepcification.
    case `default`

    /// Throw upon encountering non-conforming values. This is the default strategy.
    case `throw`
  }

  /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
  open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate

  /// The strategy to use in decoding binary data. Defaults to `.base64`.
  open var dataDecodingStrategy: DataDecodingStrategy = .base64

  /// The options set on the top-level decoder.
  override public var options: YAMLDecoderTransform.Options {
    return YAMLDecoderTransform.Options(
      dateDecodingStrategy: dateDecodingStrategy,
      dataDecodingStrategy: dataDecodingStrategy,
      keyDecodingStrategy: keyDecodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}


public struct YAMLDecoderTransform: InternalDecoderTransform, InternalValueDeserializer, InternalValueParser {

  public typealias Value = YAML
  public typealias State = Void

  public static let nilValue = YAML.null(anchor: nil)

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let dateDecodingStrategy: YAMLDecoder.DateDecodingStrategy
    public let dataDecodingStrategy: YAMLDecoder.DataDecodingStrategy
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
    AnyValue.AnyDictionary.self,
  ]

  public static func intercepts(_ type: Decodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type }
  }

  public static func unbox(_ value: YAML, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
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
    else if interceptedType == AnyValue.AnyDictionary.self {
      return try unbox(value, as: AnyValue.AnyDictionary.self, decoder: decoder)
    }
    fatalError("type not valid for intercept")
  }

  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: YAML, as type: Bool.Type, decoder: IVD) throws -> Bool? {
    switch value {
    case .bool(let value, _): return value
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  static func overflow(_ type: Any.Type, value: Any, at codingPath: [CodingKey]) -> Error {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(value) overflows \(type)")
    return DecodingError.typeMismatch(type, context)
  }

  static func coerce<T>(_ from: YAML.Number, at codingPath: [CodingKey]) throws -> T
    where T: BinaryInteger & FixedWidthInteger {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T>(_ from: YAML.Number, at codingPath: [CodingKey]) throws -> T
    where T: BinaryFloatingPoint & LosslessStringConvertible {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func decode<T>(_ from: YAML.Number, at codingPath: [CodingKey]) throws -> T?
  where T: BinaryFloatingPoint & LosslessStringConvertible {
    if from.isNaN {
      return T.nan
    }
    else if from.isInfinity {
      return from.isNegative ? -T.infinity : +T.infinity
    }
    else {
      return try coerce(from, at: codingPath)
    }
  }

  public static func unbox(_ value: YAML, as type: Int.Type, decoder: IVD) throws -> Int? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    switch value {
    case .integer(let number, _): return BigInt(number.value)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    switch value {
    case .integer(let number, _):
      if number.isNegative {
        throw overflow(type, value: value, at: decoder.codingPath)
      }
      return BigUInt(number.value)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Float16.Type, decoder: IVD) throws -> Float16? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try decode(number, at: decoder.codingPath)
    case .null: return nil
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(_ value: YAML, as type: Float.Type, decoder: IVD) throws -> Float? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try decode(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Double.Type, decoder: IVD) throws -> Double? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try decode(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {

    func decodeInteger(_ number: YAML.Number) throws -> Decimal {
      guard let decimal = Decimal(string: number.value) else {
        throw DecodingError.typeMismatch(
          Decimal.self,
          .init(codingPath: decoder.codingPath,
                debugDescription: "Decimal unable to parse number"))
      }
      return decimal
    }

    func decodeFloat(_ number: YAML.Number) throws -> Decimal {
      if number.isNaN {
        return Decimal.nan
      }
      else if number.isInfinity {
        throw DecodingError.typeMismatch(
          Decimal.self,
          .init(codingPath: decoder.codingPath,
                debugDescription: "Decimal does not support infinity"))
      }
      guard let decimal = Decimal(string: number.value) else {
        throw DecodingError.typeMismatch(
          Decimal.self,
          .init(codingPath: decoder.codingPath,
                debugDescription: "Decimal unable to parse number"))
      }
      return decimal
    }

    switch value {
    case .integer(let number, _): return try decodeInteger(number)
    case .float(let number, _): return try decodeFloat(number)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: String.Type, decoder: IVD) throws -> String? {
    switch value {
    case .string(let string, _, _, _):
      return string
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    switch value {
    case .string(let string, _, _, _):
      guard let uuid = UUID(uuidString: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected valid URL string")
      }
      return uuid
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: URL.Type, decoder: IVD) throws -> URL? {
    switch value {
    case .string(let string, _, _, _):
      guard let url = URL(string: string) else {
        throw DecodingError.dataCorruptedError(in: decoder, debugDescription: "Expected valid URL string")
      }
      return url
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }

  public static func unbox(_ value: YAML, as type: Date.Type, decoder: IVD) throws -> Date? {

    func decodeISO8601(from value: YAML) throws -> Date? {
      guard let string = try unbox(value, as: String.self, decoder: decoder) else {
        return nil
      }
      guard let date = ZonedDate(iso8601Encoded: string)?.utcDate else {
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Expected date string to be ISO8601-formatted."
        ))
      }
      return date
    }

    func decodeFormatted(from value: YAML, formatter: DateFormatter) throws -> Date? {
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

  public static func unbox(_ value: YAML, as type: Data.Type, decoder: IVD) throws -> Data? {

    func decodeBase64(from value: YAML) throws -> Data {
      guard case .string(let string, _, _, _) = value else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }

      guard let data = Data(base64EncodedUnpadded: string) else {
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

  public static func unbox(_ value: YAML, as type: AnyValue.Type, decoder: IVD) throws -> AnyValue {

    func decode(from value: YAML.Number) -> AnyValue {
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
    case .bool(let value, _):
      return .bool(value)
    case .string(let value, _, _, _):
      return .string(value)
    case .integer(let value, anchor: _), .float(let value, anchor: _):
      return decode(from: value)
    case .sequence(let value, _, _, _):
      return .array(try value.map { try unbox($0, as: AnyValue.self, decoder: decoder) })
    case .mapping(let value, _, _, _):
      return .dictionary(AnyValue.AnyDictionary(uniqueKeysWithValues: try value.map { entry in
        (try unbox(entry.key, as: AnyValue.self, decoder: decoder),
         try unbox(entry.value, as: AnyValue.self, decoder: decoder))
      }))
    default:
      break
    }
    throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
  }

  public static func unbox(
    _ value: YAML,
    as type: AnyValue.AnyDictionary.Type,
    decoder: IVD
  ) throws -> AnyValue.AnyDictionary {
    guard case .mapping(let mapping, _, _, _) = value else {
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
    }
    return AnyValue.AnyDictionary(uniqueKeysWithValues: try mapping.map { entry in
      (try unbox(entry.key, as: AnyValue.self, decoder: decoder),
       try unbox(entry.value, as: AnyValue.self, decoder: decoder))
    })
  }

  public static func valueToUnkeyedValues(_ value: YAML, decoder: IVD) throws -> UnkeyedValues? {
    guard case .sequence(let sequence, _, _, _) = value else { return nil }
    return sequence
  }

  public static func valueToKeyedValues(_ value: YAML, decoder: IVD) throws -> KeyedValues? {
    guard case .mapping(let mapping, _, _, _) = value else { return nil }
    return try KeyedValues(
      mapping.map { entry in
        switch entry.key {
        case .string(let stringKey, _, _, _):
          return (stringKey, entry.value)
        case .integer(let intKey, _):
          return (intKey.value, entry.value)
        default:
          throw DecodingError.dataCorruptedError(
            in: decoder,
            debugDescription: "Mapping contains unsupported keys"
          )
        }
      },
      uniquingKeysWith: { _, _ in
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Mapping contains duplicate keys"
        ))
      }
    )
  }

  public static func value(from data: Data, options: Options) throws -> YAML {
    return try YAMLSerialization.yaml(from: data)
  }

  public static func value(from string: String, options: Options) throws -> YAML {
    return try YAMLSerialization.yaml(from: string)
  }

}

extension Data {

  init?(base64EncodedUnpadded string: String) {
    self.init(base64Encoded: Data.padBase64(string))
  }

  private static func padBase64(_ string: String) -> String {
    let offset = string.count % 4
    guard offset != 0 else { return string }
    return string.padding(toLength: string.count + 4 - offset, withPad: "=", startingAt: 0)
  }

}



#if canImport(Combine)

  import Combine

  extension YAMLDecoder: TopLevelDecoder {
    public typealias Input = Data
  }

#endif
