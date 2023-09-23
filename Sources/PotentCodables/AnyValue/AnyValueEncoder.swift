//
//  AnyValueEncoder.swift
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


public class AnyValueEncoder: ValueEncoder<AnyValue, AnyValueEncoderTransform> {

  public static let `default` = AnyValueEncoder()

  /// The options set on the top-level decoder.
  override public var options: AnyValueEncoderTransform.Options {
    return AnyValueEncoderTransform.Options(
      keyEncodingStrategy: keyEncodingStrategy,
      userInfo: userInfo
    )
  }

  override public init() {
    super.init()
  }

}

public struct AnyValueEncoderTransform: InternalEncoderTransform {

  public typealias Value = AnyValue
  public typealias State = Void

  public struct Options: InternalEncoderOptions {
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public static var emptyKeyedContainer: AnyValue {
    return .dictionary([:])
  }

  public static var emptyUnkeyedContainer: AnyValue {
    return .array([])
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

  public static func intercepts(_ type: Encodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type } || type is DictionaryAdapter.Type
  }

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: IVE) throws -> AnyValue {
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
    else if let value = value as? Float16 {
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
    else if let value = value as? DictionaryAdapter {
      return try box(value, encoder: encoder)
    }
    fatalError("type not valid for intercept")
  }

  fileprivate static func box(_ value: DictionaryAdapter, encoder: IVE) throws -> AnyValue {
    var dict = AnyValue.AnyDictionary()
    for (key, value) in value.entries {
      guard let boxedKey = try encoder.box(value: key) else {
        throw EncodingError.invalidValue(
          key,
          .init(codingPath: encoder.codingPath,
                debugDescription: "Expected to encode key '\(key)' but got nil instead")
        )
      }
      guard let boxedValue = try encoder.box(value: value) else {
        throw EncodingError.invalidValue(
          key,
          .init(codingPath: encoder.codingPath,
                debugDescription: "Expected to encode value '\(value)' but got nil instead")
        )
      }
      dict[boxedKey] = boxedValue
    }
    return .dictionary(dict)
  }

  public static func boxNil(encoder: IVE) throws -> AnyValue {
    return .nil
  }

  public static func box(_ value: Bool, encoder: IVE) throws -> AnyValue {
    return .bool(value)
  }

  public static func box(_ value: Int, encoder: IVE) throws -> AnyValue {
    switch MemoryLayout<Int>.size {
    case 4:
      return try box(Int32(value), encoder: encoder)
    case 8:
      return try box(Int64(value), encoder: encoder)
    default:
      fatalError("unknown memory layout")
    }
  }

  public static func box(_ value: Int8, encoder: IVE) throws -> AnyValue {
    return .int8(value)
  }

  public static func box(_ value: Int16, encoder: IVE) throws -> AnyValue {
    return .int16(value)
  }

  public static func box(_ value: Int32, encoder: IVE) throws -> AnyValue {
    return .int32(value)
  }

  public static func box(_ value: Int64, encoder: IVE) throws -> AnyValue {
    return .int64(value)
  }

  public static func box(_ value: UInt, encoder: IVE) throws -> AnyValue {
    switch MemoryLayout<UInt>.size {
    case 4:
      return try box(UInt32(value), encoder: encoder)
    case 8:
      return try box(UInt64(value), encoder: encoder)
    default:
      fatalError("unknown memory layout")
    }
  }

  public static func box(_ value: UInt8, encoder: IVE) throws -> AnyValue {
    return .uint8(value)
  }

  public static func box(_ value: UInt16, encoder: IVE) throws -> AnyValue {
    return .uint16(value)
  }

  public static func box(_ value: UInt32, encoder: IVE) throws -> AnyValue {
    return .uint32(value)
  }

  public static func box(_ value: UInt64, encoder: IVE) throws -> AnyValue {
    return .uint64(value)
  }

  public static func box(_ value: String, encoder: IVE) throws -> AnyValue {
    return .string(value)
  }

  public static func box(_ value: Float16, encoder: IVE) throws -> AnyValue {
    return .float16(value)
  }

  public static func box(_ value: Float, encoder: IVE) throws -> AnyValue {
    return .float(value)
  }

  public static func box(_ value: Double, encoder: IVE) throws -> AnyValue {
    return .double(value)
  }

  public static func box(_ value: Decimal, encoder: IVE) throws -> AnyValue {
    return .decimal(value)
  }

  public static func box(_ value: Data, encoder: IVE) throws -> AnyValue {
    return .data(value)
  }

  public static func box(_ value: URL, encoder: IVE) throws -> AnyValue {
    return .url(value)
  }

  public static func box(_ value: UUID, encoder: IVE) throws -> AnyValue {
    return .uuid(value)
  }

  public static func box(_ value: Date, encoder: IVE) throws -> AnyValue {
    return .date(value)
  }

  public static func box(_ value: BigInt, encoder: IVE) throws -> AnyValue {
    return .integer(value)
  }

  public static func box(_ value: BigUInt, encoder: IVE) throws -> AnyValue {
    return .unsignedInteger(value)
  }

  public static func unkeyedValuesToValue(_ values: UnkeyedValues, encoder: IVE) throws -> AnyValue {
    return .array(AnyValue.AnyArray(values))
  }

  public static func keyedValuesToValue(_ values: KeyedValues, encoder: IVE) throws -> AnyValue {
    return .dictionary(AnyValue.AnyDictionary(uniqueKeysWithValues: values.map { (key: .string($0), value: $1) }))
  }

}


extension AnyValueEncoder: TopLevelEncoder {
  public typealias Output = AnyValue

  public func encode<T>(_ value: T) throws -> AnyValue where T: Encodable {
    return try encodeTree(value)
  }
}



private protocol DictionaryAdapter {
  var entries: [(Encodable, Encodable)] { get }
}
extension Dictionary: DictionaryAdapter where Key: Encodable, Value: Encodable {
  var entries: [(Encodable, Encodable)] { Array(self) }
}
extension OrderedDictionary: DictionaryAdapter where Key: Encodable, Value: Encodable {
  var entries: [(Encodable, Encodable)] { Array(elements) }
}
