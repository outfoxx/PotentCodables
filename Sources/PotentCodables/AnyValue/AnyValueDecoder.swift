//
//  AnyValueDecoder.swift
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


public class AnyValueDecoder: ValueDecoder<AnyValue, AnyValueDecoderTransform> {

  public static let `default` = AnyValueDecoder()

  /// The options set on the top-level decoder.
  override public var options: AnyValueDecoderTransform.Options {
    return AnyValueDecoderTransform.Options(
      keyDecodingStrategy: keyDecodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}

public struct AnyValueDecoderTransform: InternalDecoderTransform {

  public typealias Value = AnyValue
  public typealias State = Void

  public struct Options: InternalDecoderOptions {
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public static var nilValue: AnyValue {
    return .nil
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
    return interceptedTypes.contains { $0 == type } || type is DictionaryAdapter.Type
  }

  public static func unbox(_ value: AnyValue, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
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
    else if let dictType = interceptedType as? DictionaryAdapter.Type {
      return try unbox(value, as: dictType, decoder: decoder)
    }
    fatalError("type not valid for intercept")
  }

  fileprivate static func unbox(_ value: AnyValue, as type: DictionaryAdapter.Type, decoder: IVD) throws -> Any? {
    guard case .dictionary(let dict) = value else { return nil }
    var result = type.empty()
    for (key, value) in dict {
      guard let key = try decoder.unbox(value: key, as: type.keyType) else {
        throw DecodingError.typeMismatch(
          type.keyType,
          .init(codingPath: decoder.codingPath,
                debugDescription: "Expected to decode key of type'\(type.keyType)' but got nil instead")
        )
      }
      guard let value = try decoder.unbox(value: value, as: type.valueType) else {
        throw DecodingError.typeMismatch(
          type.valueType,
          .init(codingPath: decoder.codingPath,
                debugDescription: "Expected to decode value of type'\(type.keyType)' but got nil instead")
        )
      }
      result = type.assign(value: value, forKey: key, to: result)
    }
    return result
  }

  public static func unbox(_ value: AnyValue, as type: Bool.Type, decoder: IVD) throws -> Bool? {
    switch value {
    case .nil: return nil
    case .bool(let value): return value
    default:
      throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: Bool.self, reality: value.unwrapped)
    }
  }

  public static func convert<I: BinaryInteger, O: BinaryInteger>(
    _ value: I,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "\(I.self) value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  public static func convert<I: BinaryInteger, O: BinaryFloatingPoint>(
    _ value: I,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "\(I.self) value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  public static func convert<I: BinaryFloatingPoint, O: BinaryInteger>(
    _ value: I,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "\(I.self) value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  public static func convert<I: BinaryFloatingPoint, O: BinaryFloatingPoint>(
    _ value: I,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "\(I.self) value value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  public static func convert<O: BinaryInteger>(
    _ value: Decimal,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: (value as NSDecimalNumber).int64Value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "Decimal value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  public static func convert<O: BinaryFloatingPoint>(
    _ value: Decimal,
    to type: O.Type,
    decoder: IVD
  ) throws -> O {
    guard let convertedValue = O(exactly: (value as NSDecimalNumber).int64Value) else {
      throw DecodingError.typeMismatch(
        type,
        .init(codingPath: decoder.codingPath, debugDescription: "Decimal value overflow/underflows \(type)")
      )
    }
    return convertedValue
  }

  private static func unboxNumeric<I: BinaryInteger>(
    _ value: AnyValue,
    as type: I.Type,
    decoder: IVD
  ) throws -> I? {
    switch value {
    case .nil: return nil
    case .int8(let val): return try convert(val, to: type, decoder: decoder)
    case .int16(let val): return try convert(val, to: type, decoder: decoder)
    case .int32(let val): return try convert(val, to: type, decoder: decoder)
    case .int64(let val): return try convert(val, to: type, decoder: decoder)
    case .uint8(let val): return try convert(val, to: type, decoder: decoder)
    case .uint16(let val): return try convert(val, to: type, decoder: decoder)
    case .uint32(let val): return try convert(val, to: type, decoder: decoder)
    case .uint64(let val): return try convert(val, to: type, decoder: decoder)
    case .float16(let val): return try convert(val, to: type, decoder: decoder)
    case .float(let val): return try convert(val, to: type, decoder: decoder)
    case .double(let val): return try convert(val, to: type, decoder: decoder)
    case .integer(let val): return try convert(val, to: type, decoder: decoder)
    case .unsignedInteger(let val): return try convert(val, to: type, decoder: decoder)
    case .decimal(let val): return try convert(val, to: type, decoder: decoder)
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  private static func unboxNumeric<I: BinaryFloatingPoint>(
    _ value: AnyValue,
    as type: I.Type,
    decoder: IVD
  ) throws -> I? {
    switch value {
    case .nil: return nil
    case .int8(let val): return try convert(val, to: type, decoder: decoder)
    case .int16(let val): return try convert(val, to: type, decoder: decoder)
    case .int32(let val): return try convert(val, to: type, decoder: decoder)
    case .int64(let val): return try convert(val, to: type, decoder: decoder)
    case .uint8(let val): return try convert(val, to: type, decoder: decoder)
    case .uint16(let val): return try convert(val, to: type, decoder: decoder)
    case .uint32(let val): return try convert(val, to: type, decoder: decoder)
    case .uint64(let val): return try convert(val, to: type, decoder: decoder)
    case .float16(let val): return try convert(val, to: type, decoder: decoder)
    case .float(let val): return try convert(val, to: type, decoder: decoder)
    case .double(let val): return try convert(val, to: type, decoder: decoder)
    case .integer(let val): return try convert(val, to: type, decoder: decoder)
    case .unsignedInteger(let val): return try convert(val, to: type, decoder: decoder)
    case .decimal(let val): return try convert(val, to: type, decoder: decoder)
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: Int.Type, decoder: IVD) throws -> Int? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Float16.Type, decoder: IVD) throws -> Float16? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Float.Type, decoder: IVD) throws -> Float? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: Double.Type, decoder: IVD) throws -> Double? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: String.Type, decoder: IVD) throws -> String? {
    switch value {
    case .nil: return nil
    case .string(let value): return value
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    switch value {
    case .nil: return nil
    case .uuid(let value): return value
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: URL.Type, decoder: IVD) throws -> URL? {
    switch value {
    case .nil: return nil
    case .url(let value): return value
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: Date.Type, decoder: IVD) throws -> Date? {
    switch value {
    case .nil: return nil
    case .date(let value): return value
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: Data.Type, decoder: IVD) throws -> Data? {
    switch value {
    case .nil: return nil
    case .data(let value): return value
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    switch value {
    case .nil: return nil
    case .decimal(let value): return value
    case .int8(let val): return Decimal(val)
    case .int16(let val): return Decimal(val)
    case .int32(let val): return Decimal(val)
    case .int64(let val): return Decimal(val)
    case .uint8(let val): return Decimal(val)
    case .uint16(let val): return Decimal(val)
    case .uint32(let val): return Decimal(val)
    case .uint64(let val): return Decimal(val)
    case .float16(let val): return Decimal(string: val.description)
    case .float(let val): return Decimal(string: val.description)
    case .double(let val): return Decimal(val)
    case .integer(let val): return Decimal(string: val.description)
    case .unsignedInteger(let val): return Decimal(string: val.description)
    default: throw DecodingError.typeMismatch(at: decoder.codingPath, expectation: type, reality: value.unwrapped)
    }
  }

  public static func unbox(_ value: AnyValue, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func unbox(_ value: AnyValue, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    return try unboxNumeric(value, as: type, decoder: decoder)
  }

  public static func valueToUnkeyedValues(_ value: AnyValue, decoder: IVD) throws -> UnkeyedValues? {
    guard case .array(let array) = value else { return nil }
    return array
  }

  public static func valueToKeyedValues(_ value: AnyValue, decoder: IVD) throws -> KeyedValues? {
    guard case .dictionary(let dictionary) = value else { return nil }
    return try KeyedValues(
      dictionary.map { key, value in
        switch key {
        case .float16, .float, .double, .decimal, .date, .data, .uuid, .url, .array, .dictionary:
          throw DecodingError.dataCorrupted(.init(
            codingPath: decoder.codingPath,
            debugDescription: "Dictionary contains unsupported keys"
          ))
        default: return (key.description, value)
        }
      },
      uniquingKeysWith: { _, _ in
        throw DecodingError.dataCorrupted(.init(
          codingPath: decoder.codingPath,
          debugDescription: "Dictionary contains duplicate keys"
        ))
      }
    )
  }

}


extension AnyValueDecoder: TopLevelDecoder {
  public typealias Input = AnyValue

  public func decode<T>(_ type: T.Type, from tree: AnyValue) throws -> T where T: Decodable {
    return try decodeTree(type, from: tree)
  }
}



private protocol DictionaryAdapter {
  static var keyType: Decodable.Type { get }
  static var valueType: Decodable.Type { get }
  static func empty() -> Any
  static func assign(value: Any, forKey: Any, to dict: Any) -> Any
}

extension Dictionary: DictionaryAdapter where Key: Decodable, Value: Decodable {
  static var keyType: Decodable.Type { Key.self }
  static var valueType: Decodable.Type { Value.self }
  static func empty() -> Any { return Dictionary() }
  static func assign(value: Any, forKey key: Any, to dict: Any) -> Any {
    var dict = (dict as? Self).unsafelyUnwrapped
    let key = (key as? Key).unsafelyUnwrapped
    let value = (value as? Value).unsafelyUnwrapped
    dict[key] = value
    return dict
  }
}

extension OrderedDictionary: DictionaryAdapter where Key: Decodable, Value: Decodable {
  static var keyType: Decodable.Type { Key.self }
  static var valueType: Decodable.Type { Value.self }
  static func empty() -> Any { return OrderedDictionary() }
  static func assign(value: Any, forKey key: Any, to dict: Any) -> Any {
    var dict = (dict as? Self).unsafelyUnwrapped
    let key = (key as? Key).unsafelyUnwrapped
    let value = (value as? Value).unsafelyUnwrapped
    dict[key] = value
    return dict
  }
}
