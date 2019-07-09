//
//  AnyValueEncoder.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public class AnyValueEncoder: ValueEncoder<AnyValue, AnyValueEncoderTransform> {

  public static let `default` = AnyValueEncoder()

  /// The options set on the top-level decoder.
  public override var options: AnyValueEncoderTransform.Options {
    return AnyValueEncoderTransform.Options(keyEncodingStrategy: keyEncodingStrategy,
                                            userInfo: userInfo)
  }

  public override init() {
    super.init()
  }

}

public struct AnyValueEncoderTransform: InternalEncoderTransform {

  public typealias Value = AnyValue

  public struct Options: InternalEncoderOptions {
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public static var nilValue: AnyValue {
    return .nil
  }

  public static var emptyKeyedContainer: AnyValue {
    return .dictionary([:])
  }

  public static func box(_ value: Bool, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .bool(value)
  }

  public static func box(_ value: Int, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    switch MemoryLayout<Int>.size {
    case 32:
      return try box(Int32(value), encoder: encoder)
    case 64:
      return try box(Int64(value), encoder: encoder)
    default:
      fatalError()
    }
  }

  public static func box(_ value: Int8, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .int8(value)
  }

  public static func box(_ value: Int16, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .int16(value)
  }

  public static func box(_ value: Int32, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .int32(value)
  }

  public static func box(_ value: Int64, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .int64(value)
  }

  public static func box(_ value: UInt, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    switch MemoryLayout<Int>.size {
    case 32:
      return try box(UInt32(value), encoder: encoder)
    case 64:
      return try box(UInt64(value), encoder: encoder)
    default:
      fatalError()
    }
  }

  public static func box(_ value: UInt8, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .uint8(value)
  }

  public static func box(_ value: UInt16, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .uint16(value)
  }

  public static func box(_ value: UInt32, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .uint32(value)
  }

  public static func box(_ value: UInt64, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .uint64(value)
  }

  public static func box(_ value: String, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .string(value)
  }

  public static func box(_ value: Float, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .float(value)
  }

  public static func box(_ value: Double, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .double(value)
  }

  public static func box(_ value: Decimal, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .decimal(value)
  }

  public static func box(_ value: Data, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .data(value)
  }

  public static func box(_ value: URL, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .url(value)
  }

  public static func box(_ value: UUID, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .uuid(value)
  }

  public static func box(_ value: Date, encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .date(value)
  }

  public static func unkeyedValuesToValue(_ values: [AnyValue]) -> AnyValue {
    return .array(values)
  }

  public static func keyedValuesToValue(_ values: [String: AnyValue]) -> AnyValue {
    return .dictionary(values)
  }

}
