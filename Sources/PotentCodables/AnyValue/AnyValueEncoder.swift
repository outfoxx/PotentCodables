/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation


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

  public static func boxNil(encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>) throws -> AnyValue {
    return .nil
  }

  public static func box(
    _ value: Bool,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .bool(value)
  }

  public static func box(
    _ value: Int,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    switch MemoryLayout<Int>.size {
    case 4:
      return try box(Int32(value), encoder: encoder)
    case 8:
      return try box(Int64(value), encoder: encoder)
    default:
      fatalError()
    }
  }

  public static func box(
    _ value: Int8,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .int8(value)
  }

  public static func box(
    _ value: Int16,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .int16(value)
  }

  public static func box(
    _ value: Int32,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .int32(value)
  }

  public static func box(
    _ value: Int64,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .int64(value)
  }

  public static func box(
    _ value: UInt,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    switch MemoryLayout<UInt>.size {
    case 4:
      return try box(UInt32(value), encoder: encoder)
    case 8:
      return try box(UInt64(value), encoder: encoder)
    default:
      fatalError()
    }
  }

  public static func box(
    _ value: UInt8,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .uint8(value)
  }

  public static func box(
    _ value: UInt16,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .uint16(value)
  }

  public static func box(
    _ value: UInt32,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .uint32(value)
  }

  public static func box(
    _ value: UInt64,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .uint64(value)
  }

  public static func box(
    _ value: String,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .string(value)
  }

  public static func box(
    _ value: Float,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .float(value)
  }

  public static func box(
    _ value: Double,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .double(value)
  }

  public static func box(
    _ value: Decimal,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .decimal(value)
  }

  public static func box(
    _ value: Data,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .data(value)
  }

  public static func box(
    _ value: URL,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .url(value)
  }

  public static func box(
    _ value: UUID,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .uuid(value)
  }

  public static func box(
    _ value: Date,
    encoder: InternalValueEncoder<AnyValue, AnyValueEncoderTransform>
  ) throws -> AnyValue {
    return .date(value)
  }

  public static func unkeyedValuesToValue(
    _ values: [AnyValue],
    encoder: InternalValueEncoder<Value, Self>
  ) -> AnyValue {
    return .array(values)
  }

  public static func keyedValuesToValue(
    _ values: [String: AnyValue],
    encoder: InternalValueEncoder<Value, Self>
  ) -> AnyValue {
    return .dictionary(values)
  }

}


#if canImport(Combine)

  import Combine

  extension AnyValueEncoder: TopLevelEncoder {
    public typealias Output = AnyValue

    public func encode<T>(_ value: T) throws -> AnyValue where T: Encodable {
      return try encodeTree(value)
    }
  }

#endif
