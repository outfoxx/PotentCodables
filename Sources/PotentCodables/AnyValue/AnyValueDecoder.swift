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
    guard case .bool(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Int.Type, decoder: IVD) throws -> Int? {
    switch MemoryLayout<Int>.size {
    case 4:
      return try unbox(value, as: Int32.self, decoder: decoder).flatMap { Int(exactly: $0) }
    case 8:
      return try unbox(value, as: Int64.self, decoder: decoder).flatMap { Int(exactly: $0) }
    default:
      fatalError("unknown memory layout")
    }
  }

  public static func unbox(_ value: AnyValue, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    switch MemoryLayout<UInt>.size {
    case 4:
      return try unbox(value, as: UInt32.self, decoder: decoder).flatMap { UInt(exactly: $0) }
    case 8:
      return try unbox(value, as: UInt64.self, decoder: decoder).flatMap { UInt(exactly: $0) }
    default:
      fatalError("unknown memory layout")
    }
  }

  public static func unbox(_ value: AnyValue, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    guard case .int8(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    guard case .int16(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    guard case .int32(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    guard case .int64(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    guard case .uint8(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    guard case .uint16(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    guard case .uint32(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    guard case .uint64(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Float16.Type, decoder: IVD) throws -> Float16? {
    guard case .float16(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Float.Type, decoder: IVD) throws -> Float? {
    guard case .float(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Double.Type, decoder: IVD) throws -> Double? {
    guard case .double(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: String.Type, decoder: IVD) throws -> String? {
    guard case .string(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    guard case .uuid(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: URL.Type, decoder: IVD) throws -> URL? {
    guard case .url(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Date.Type, decoder: IVD) throws -> Date? {
    guard case .date(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Data.Type, decoder: IVD) throws -> Data? {
    guard case .data(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    guard case .decimal(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    guard case .integer(let value) = value else { return nil }
    return value
  }

  public static func unbox(_ value: AnyValue, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    guard case .unsignedInteger(let value) = value else { return nil }
    return value
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


#if canImport(Combine)

  import Combine

  extension AnyValueDecoder: TopLevelDecoder {
    public typealias Input = AnyValue

    public func decode<T>(_ type: T.Type, from tree: AnyValue) throws -> T where T: Decodable {
      return try decodeTree(type, from: tree)
    }
  }

#endif



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
