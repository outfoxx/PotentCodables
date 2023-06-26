//
//  JSONEncoder.swift
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


/// ``JSONEncoder`` facilitates the encoding of `Encodable` values into JSON values.
///
public class JSONEncoder: ValueEncoder<JSON, JSONEncoderTransform>, EncodesToString {

  public static let `default` = JSONEncoder()

  // MARK: Options

  /// The formatting of the output JSON data.
  public struct OutputFormatting: OptionSet {

    /// The format's default value.
    public let rawValue: UInt

    /// Creates an OutputFormatting value with the given raw value.
    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    /// Produce human-readable JSON with indented output.
    public static let prettyPrinted = OutputFormatting(rawValue: 1 << 0)

    /// Produce JSON with dictionary keys sorted in lexicographic order.
    public static let sortedKeys = OutputFormatting(rawValue: 1 << 1)

    /// Produce JSON with slashes escaped.
    public static let escapeSlashes = OutputFormatting(rawValue: 1 << 2)
  }

  /// The strategy to use for encoding `Date` values.
  public enum DateEncodingStrategy {

    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate

    /// Encode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601

    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)

    /// Encode the `Date` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder
    /// will encode an empty automatic container in its place.
    case custom((Date, Encoder) throws -> Void)
  }

  /// The strategy to use for encoding `Data` values.
  public enum DataEncodingStrategy {

    /// Defer to `Data` for choosing an encoding.
    case deferredToData

    /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
    case base64

    /// Encode the `Data` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder
    ///  will encode an empty automatic container in its place.
    case custom((Data, Encoder) throws -> Void)
  }

  /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
  public enum NonConformingFloatEncodingStrategy {

    /// Throw upon encountering non-conforming values. This is the default strategy.
    case `throw`

    /// Encode the values using the given representation strings.
    case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
  }

  /// The output format to produce. Defaults to `[]`.
  public var outputFormatting: OutputFormatting = []

  /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
  public var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate

  /// The strategy to use in encoding binary data. Defaults to `.base64`.
  public var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64

  /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
  public var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = .throw

  /// The options set on the top-level encoder.
  override public var options: JSONEncoderTransform.Options {
    return JSONEncoderTransform.Options(
      dateEncodingStrategy: dateEncodingStrategy,
      dataEncodingStrategy: dataEncodingStrategy,
      nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
      outputFormatting: outputFormatting,
      keyEncodingStrategy: keyEncodingStrategy,
      userInfo: userInfo
    )
  }


  override public init() {
    super.init()
  }

}



public struct JSONEncoderTransform: InternalEncoderTransform, InternalValueSerializer, InternalValueStringifier {

  public typealias Value = JSON
  public typealias State = Void

  public static var emptyKeyedContainer = JSON.object([:])
  public static var emptyUnkeyedContainer = JSON.array([])

  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
    public let dataEncodingStrategy: JSONEncoder.DataEncodingStrategy
    public let nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy
    public let outputFormatting: JSONEncoder.OutputFormatting
    public let keyEncodingStrategy: KeyEncodingStrategy
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

  public static func intercepts(_ type: Encodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type }
  }

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: IVE) throws -> JSON {
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
    else if let value = value as? AnyValue {
      return try box(value, encoder: encoder)
    }
    else if let value = value as? AnyValue.AnyDictionary {
      return try box(.dictionary(value), encoder: encoder)
    }
    fatalError("type not valid for intercept")
  }

  public static func boxNil(encoder: IVE) throws -> JSON { return .null }
  public static func box(_ value: Bool, encoder: IVE) throws -> JSON { return .bool(value) }
  public static func box(_ value: Int, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: Int8, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: Int16, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: Int32, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: Int64, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: UInt, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: UInt8, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: UInt16, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: UInt32, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: UInt64, encoder: IVE) throws -> JSON { return .number(.init(value.description)) }
  public static func box(_ value: String, encoder: IVE) throws -> JSON { return .string(value) }
  public static func box(_ value: URL, encoder: IVE) throws -> JSON { return .string(value.absoluteString) }
  public static func box(_ value: UUID, encoder: IVE) throws -> JSON { return .string(value.uuidString) }

  public static func box(_ float: Float16, encoder: IVE) throws -> JSON {
    guard !float.isInfinite, !float.isNaN else {
      guard case .convertToString(
        let posInfString,
        let negInfString,
        let nanString
      ) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(float, at: encoder.codingPath)
      }

      if float == Float16.infinity {
        return .string(posInfString)
      }
      else if float == -Float16.infinity {
        return .string(negInfString)
      }
      else {
        return .string(nanString)
      }
    }

    return .number(.init(float))
  }

  public static func box(_ float: Float, encoder: IVE) throws -> JSON {
    guard !float.isInfinite, !float.isNaN else {
      guard case .convertToString(
        let posInfString,
        let negInfString,
        let nanString
      ) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(float, at: encoder.codingPath)
      }

      if float == Float.infinity {
        return .string(posInfString)
      }
      else if float == -Float.infinity {
        return .string(negInfString)
      }
      else {
        return .string(nanString)
      }
    }

    return .number(.init(float))
  }

  public static func box(_ double: Double, encoder: IVE) throws -> JSON {
    guard !double.isInfinite, !double.isNaN else {
      guard case .convertToString(
        let posInfString,
        let negInfString,
        let nanString
      ) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(double, at: encoder.codingPath)
      }

      if double == Double.infinity {
        return .string(posInfString)
      }
      else if double == -Double.infinity {
        return .string(negInfString)
      }
      else {
        return .string(nanString)
      }
    }

    return .number(.init(double))
  }

  public static func box(_ decimal: Decimal, encoder: IVE) throws -> JSON {
    guard !decimal.isInfinite, !decimal.isNaN else {
      guard case .convertToString(
        let posInfString,
        let negInfString,
        let nanString
      ) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(decimal, at: encoder.codingPath)
      }

      if decimal.isInfinite, decimal.sign == .plus {
        return .string(posInfString)
      }
      else if decimal.isInfinite, decimal.sign == .minus {
        return .string(negInfString)
      }
      else {
        return .string(nanString)
      }
    }

    return .number(.init(decimal.description))
  }

  public static func box(_ value: BigInt, encoder: IVE) throws -> JSON {
    return .number(.init(value.description))
  }

  public static func box(_ value: BigUInt, encoder: IVE) throws -> JSON {
    return .number(.init(value.description))
  }

  public static func box(_ value: Data, encoder: IVE) throws -> JSON {
    switch encoder.options.dataEncodingStrategy {
    case .deferredToData:
      return try encoder.subEncode { try value.encode(to: $0.encoder) } ?? .null

    case .base64:
      return .string(value.base64EncodedString())

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0.encoder) } ?? .null
    }
  }

  public static func box(_ value: Date, encoder: IVE) throws -> JSON {
    switch encoder.options.dateEncodingStrategy {
    case .deferredToDate:
      return try encoder.subEncode { try value.encode(to: $0.encoder) } ?? .null

    case .secondsSince1970:
      return .number(.init(value.timeIntervalSince1970.description))

    case .millisecondsSince1970:
      return .number(.init((1000.0 * value.timeIntervalSince1970).description))

    case .iso8601:
      return .string(ZonedDate(date: value, timeZone: .utc).iso8601EncodedString())

    case .formatted(let formatter):
      return .string(formatter.string(from: value))

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0.encoder) } ?? .null
    }
  }

  public static func box(_ value: AnyValue, encoder: IVE) throws -> JSON {

    func encodeObject(from value: AnyValue.AnyDictionary) throws -> JSON.Object {
      return JSON.Object(uniqueKeysWithValues: try value.map { key, value in
        let boxedValue = try box(value, encoder: encoder)
        if let stringKey = key.stringValue {
          return (stringKey, boxedValue)
        }
        else if let intKey = key.integerValue(Int.self) {
          return (String(intKey), boxedValue)
        }
        throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath,
                                                      debugDescription: "Dictionary contains non-string values"))
      })
    }

    switch value {
    case .nil:
      return try boxNil(encoder: encoder)
    case .bool(let value):
      return try box(value, encoder: encoder)
    case .int8(let value):
      return try box(value, encoder: encoder)
    case .int16(let value):
      return try box(value, encoder: encoder)
    case .int32(let value):
      return try box(value, encoder: encoder)
    case .int64(let value):
      return try box(value, encoder: encoder)
    case .integer(let value):
      return try box(value, encoder: encoder)
    case .uint8(let value):
      return try box(value, encoder: encoder)
    case .uint16(let value):
      return try box(value, encoder: encoder)
    case .uint32(let value):
      return try box(value, encoder: encoder)
    case .uint64(let value):
      return try box(value, encoder: encoder)
    case .unsignedInteger(let value):
      return try box(value, encoder: encoder)
    case .float16(let value):
      return try box(value, encoder: encoder)
    case .float(let value):
      return try box(value, encoder: encoder)
    case .double(let value):
      return try box(value, encoder: encoder)
    case .decimal(let value):
      return try box(value, encoder: encoder)
    case .string(let value):
      return try box(value, encoder: encoder)
    case .data(let value):
      return try box(value, encoder: encoder)
    case .url(let value):
      return try box(value, encoder: encoder)
    case .date(let value):
      return try box(value, encoder: encoder)
    case .uuid(let value):
      return try box(value, encoder: encoder)
    case .array(let value):
      return .array(try value.map { try box($0, encoder: encoder) })
    case .dictionary(let value):
      return .object(try encodeObject(from: value))
    }
  }

  public static func unkeyedValuesToValue(_ values: UnkeyedValues, encoder: IVE) -> JSON {
    return .array(values)
  }

  public static func keyedValuesToValue(_ values: KeyedValues, encoder: IVE) -> JSON {
    return .object(values)
  }

  public static func data(from value: JSON, options: Options) throws -> Data {
    var writingOptions: JSONSerialization.WritingOptions = []
    if options.outputFormatting.contains(.escapeSlashes) {
      writingOptions.insert(.escapeSlashes)
    }
    if options.outputFormatting.contains(.prettyPrinted) {
      writingOptions.insert(.prettyPrinted)
    }
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    return try JSONSerialization.data(from: value, options: writingOptions)
  }

  public static func string(from value: JSON, options: Options) throws -> String {
    var writingOptions: JSONSerialization.WritingOptions = []
    if options.outputFormatting.contains(.escapeSlashes) {
      writingOptions.insert(.escapeSlashes)
    }
    if options.outputFormatting.contains(.prettyPrinted) {
      writingOptions.insert(.prettyPrinted)
    }
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    return try JSONSerialization.string(from: value, options: writingOptions)
  }

}


#if canImport(Combine)

  import Combine

  extension JSONEncoder: TopLevelEncoder {
    public typealias Output = Data
  }

#endif
