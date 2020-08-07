//
//  YAMLDecoder.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// `YAMLDecoder` facilitates the decoding of YAML into semantic `Decodable` types.
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
  
  /// The strategy to use for non-YAML-conforming floating-point values (IEEE 754 infinity and NaN).
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
  public override var options: YAMLDecoderTransform.Options {
    return YAMLDecoderTransform.Options(dateDecodingStrategy: dateDecodingStrategy,
                                        dataDecodingStrategy: dataDecodingStrategy,
                                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                                        keyDecodingStrategy: keyDecodingStrategy,
                                        userInfo: userInfo)
  }
  
  public override init() {
    super.init()
  }
  
}


public struct YAMLDecoderTransform: InternalDecoderTransform, InternalValueDeserializer, InternalValueParser {
  
  public typealias Value = YAML
  public typealias Decoder = InternalValueDecoder<Value, Self>
  public typealias State = Void
  
  public static let nilValue = YAML.null(anchor: nil)
  
  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let dateDecodingStrategy: YAMLDecoder.DateDecodingStrategy
    public let dataDecodingStrategy: YAMLDecoder.DataDecodingStrategy
    public let nonConformingFloatDecodingStrategy: YAMLDecoder.NonConformingFloatDecodingStrategy
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }
  
  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: YAML, as type: Bool.Type, decoder: Decoder) throws -> Bool? {
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
  
  static func coerce<T>(_ from: YAML.Number, at codingPath: [CodingKey]) throws -> T where T: BinaryInteger & FixedWidthInteger {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }
  
  static func coerce<T>(_ from: YAML.Number, at codingPath: [CodingKey]) throws -> T where T: BinaryFloatingPoint & LosslessStringConvertible {
    guard let result = T(from.value) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }
  
  public static func unbox(_ value: YAML, as type: Int.Type, decoder: Decoder) throws -> Int? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Int8.Type, decoder: Decoder) throws -> Int8? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Int16.Type, decoder: Decoder) throws -> Int16? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Int32.Type, decoder: Decoder) throws -> Int32? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Int64.Type, decoder: Decoder) throws -> Int64? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UInt.Type, decoder: Decoder) throws -> UInt? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UInt8.Type, decoder: Decoder) throws -> UInt8? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UInt16.Type, decoder: Decoder) throws -> UInt16? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UInt32.Type, decoder: Decoder) throws -> UInt32? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UInt64.Type, decoder: Decoder) throws -> UInt64? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Float.Type, decoder: Decoder) throws -> Float? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Double.Type, decoder: Decoder) throws -> Double? {
    switch value {
    case .integer(let number, _): return try coerce(number, at: decoder.codingPath)
    case .float(let number, _): return try coerce(number, at: decoder.codingPath)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Decimal.Type, decoder: Decoder) throws -> Decimal? {
    switch value {
    case .integer(let number, _): return Decimal(string: number.value)
    case .float(let number, _): return Decimal(string: number.value)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: String.Type, decoder: Decoder) throws -> String? {
    switch value {
    case .null: return nil
    case .string(let string, _, _, _):
      return string
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: UUID.Type, decoder: Decoder) throws -> UUID? {
    switch value {
    case .string(let string, _, _, _):
      return UUID(uuidString: string)
    case .null: return nil
    case let yaml:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: yaml)
    }
  }
  
  public static func unbox(_ value: YAML, as type: Date.Type, decoder: Decoder) throws -> Date? {
    guard !value.isNull else { return nil }
    
    switch decoder.options.dateDecodingStrategy {
    case .deferredToDate:
      return try decoder.subDecode(with: value) { try Date(from: $0) }
      
    case .secondsSince1970:
      let double = try unbox(value, as: Double.self, decoder: decoder)!
      return Date(timeIntervalSince1970: double)
      
    case .millisecondsSince1970:
      let double = try unbox(value, as: Double.self, decoder: decoder)!
      return Date(timeIntervalSince1970: double / 1000.0)
      
    case .iso8601:
      let string = try unbox(value, as: String.self, decoder: decoder)!
      guard let date = _iso8601Formatter.date(from: string) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Expected date string to be ISO8601-formatted."))
      }
      return date
      
    case .formatted(let formatter):
      let string = try unbox(value, as: String.self, decoder: decoder)!
      guard let date = formatter.date(from: string) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Date string does not match format expected by formatter."))
      }
      return date
      
    case .custom(let closure):
      return try decoder.subDecode(with: value) { try closure($0) }
    }
  }
  
  public static func unbox(_ value: YAML, as type: Data.Type, decoder: Decoder) throws -> Data? {
    guard !value.isNull else { return nil }
    
    switch decoder.options.dataDecodingStrategy {
    case .deferredToData:
      return try decoder.subDecode(with: value) { try Data(from: $0) }
      
    case .base64:
      guard case .string(let string, _, _, _) = value else {
        throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value)
      }
      
      guard let data = Data(base64Encoded: string) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Encountered Data is not valid Base64."))
      }
      
      return data
      
    case .custom(let closure):
      return try decoder.subDecode(with: value) { try closure($0) }
    }
  }
  
  public static func valueToUnkeyedValues(_ value: YAML, decoder: Decoder) throws -> [YAML]? {
    guard case .sequence(let sequence, _, _, _) = value else { return nil }
    return sequence
  }
  
  public static func valueToKeyedValues(_ value: YAML, decoder: Decoder) throws -> [String: YAML]? {
    guard case .mapping(let mapping, _, _, _) = value else { return nil }
    return Dictionary(uniqueKeysWithValues: try mapping.map {
      guard let stringKey = $0.key.stringValue else {
        throw DecodingError.typeMismatch(type(of: $0.key.unwrapped), DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Key is not a string", underlyingError: nil))
      }
      return (stringKey, $0.value)
    })
  }
  
  public static func value(from data: Data, options: Options) throws -> YAML {
    return try YAMLSerialization.yaml(from: data)
  }
  
  public static func value(from string: String, options: Options) throws -> YAML {
    guard let data = string.data(using: .utf8) else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "String cannot be encoded as UTF-8", underlyingError: nil))
    }
    return try YAMLSerialization.yaml(from: data)
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

extension YAMLDecoder : TopLevelDecoder {
  public typealias Input = Data
}

#endif
