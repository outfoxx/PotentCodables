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

  public static func unbox(
    _ value: AnyValue,
    as type: Bool.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Bool? {
    guard case .bool(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Int.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Int? {
    switch MemoryLayout<Int>.size {
    case 4:
      return try unbox(value, as: Int32.self, decoder: decoder).flatMap { Int(exactly: $0)! }
    case 8:
      return try unbox(value, as: Int64.self, decoder: decoder).flatMap { Int(exactly: $0)! }
    default:
      fatalError()
    }
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UInt.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UInt? {
    switch MemoryLayout<UInt>.size {
    case 4:
      return try unbox(value, as: UInt32.self, decoder: decoder).flatMap { UInt(exactly: $0)! }
    case 8:
      return try unbox(value, as: UInt64.self, decoder: decoder).flatMap { UInt(exactly: $0)! }
    default:
      fatalError()
    }
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Int8.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Int8? {
    guard case .int8(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Int16.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Int16? {
    guard case .int16(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Int32.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Int32? {
    guard case .int32(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Int64.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Int64? {
    guard case .int64(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UInt8.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UInt8? {
    guard case .uint8(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UInt16.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UInt16? {
    guard case .uint16(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UInt32.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UInt32? {
    guard case .uint32(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UInt64.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UInt64? {
    guard case .uint64(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Float.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Float? {
    guard case .float(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Double.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Double? {
    guard case .double(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: String.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> String? {
    guard case .string(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: UUID.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> UUID? {
    guard case .uuid(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Date.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Date? {
    guard case .date(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Data.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Data? {
    guard case .data(let value) = value else { return nil }
    return value
  }

  public static func unbox(
    _ value: AnyValue,
    as type: Decimal.Type,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> Decimal? {
    guard case .decimal(let value) = value else { return nil }
    return value
  }

  public static func valueToUnkeyedValues(
    _ value: AnyValue,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> [AnyValue]? {
    guard case .array(let array) = value else { return nil }
    return array
  }

  public static func valueToKeyedValues(
    _ value: AnyValue,
    decoder: InternalValueDecoder<AnyValue, AnyValueDecoderTransform>
  ) throws -> [String: AnyValue]? {
    guard case .dictionary(let dictionary) = value else { return nil }
    return dictionary
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
