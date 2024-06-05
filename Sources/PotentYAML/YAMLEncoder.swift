//
//  YAMLEncoder.swift
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


/// ``YAMLEncoder`` facilitates the encoding of `Encodable` values into YAML values.
///
public class YAMLEncoder: ValueEncoder<YAML, YAMLEncoderTransform>, EncodesToString {

  public static let `default` = YAMLEncoder()

  // MARK: Options

  /// The formatting of the output YAML data.
  public struct OutputFormatting: OptionSet {

    /// The format's default value.
    public let rawValue: UInt

    /// Creates an OutputFormatting value with the given raw value.
    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    /// Attempt to output good looking YAML
    ///
    /// Aside from selecting the style (flow or block) for mappings
    /// and sequences, it limits the output width to 80 characters
    /// by using folded strings when necessary.
    public static let pretty = OutputFormatting(rawValue: 1 << 0)

    /// Produce YAML with dictionary keys sorted in lexicographic order.
    public static let sortedKeys = OutputFormatting(rawValue: 1 << 1)

    /// Produce JSON compatible output.
    public static let json = OutputFormatting(rawValue: 1 << 2)
  }

  /// The strategy to use for encoding `Date` values.
  public enum DateEncodingStrategy {

    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate

    /// Encode the `Date` as a UNIX timestamp (as a YAML number).
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (as a YAML number).
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601

    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)

    /// Encode the `Date` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder
    ///  will encode an empty automatic container in its place.
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

  /// The output format to produce. Defaults to `[]`.
  public var outputFormatting: OutputFormatting = []

  /// The preferred output style for sequences and mappings. Defaults to `.any`.
  public var preferredCollectionStyle: YAML.CollectionStyle = .any

  /// The preferred output style for strings. Defaults to `.any`.
  public var preferredStringStyle: YAML.StringStyle = .any

  /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
  public var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate

  /// The strategy to use in encoding binary data. Defaults to `.base64`.
  public var dataEncodingStrategy: YAMLEncoder.DataEncodingStrategy = .base64

  /// The options set on the top-level encoder.
  override public var options: YAMLEncoderTransform.Options {
    return YAMLEncoderTransform.Options(
      dateEncodingStrategy: dateEncodingStrategy,
      dataEncodingStrategy: dataEncodingStrategy,
      outputFormatting: outputFormatting,
      keyEncodingStrategy: keyEncodingStrategy,
      preferredCollectionStyle: preferredCollectionStyle,
      preferredStringStyle: preferredStringStyle,
      userInfo: userInfo
    )
  }


  override public init() {
    super.init()
  }

}



public struct YAMLEncoderTransform: InternalEncoderTransform, InternalValueSerializer, InternalValueStringifier {

  public typealias Value = YAML
  public typealias State = Void

  public static var emptyKeyedContainer = YAML.mapping([])
  public static var emptyUnkeyedContainer = YAML.sequence([])

  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: YAMLEncoder.DateEncodingStrategy
    public let dataEncodingStrategy: YAMLEncoder.DataEncodingStrategy
    public let outputFormatting: YAMLEncoder.OutputFormatting
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let preferredCollectionStyle: YAML.CollectionStyle
    public let preferredStringStyle: YAML.StringStyle
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

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: IVE) throws -> YAML {
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

  public static func boxNil(encoder: IVE) throws -> YAML { return .null(anchor: nil) }
  public static func box(_ value: Bool, encoder: IVE) throws -> YAML { return .bool(value) }
  public static func box(_ value: Int, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: Int8, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: Int16, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: Int32, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: Int64, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: UInt, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: UInt8, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: UInt16, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: UInt32, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: UInt64, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: BigInt, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: BigUInt, encoder: IVE) throws -> YAML { return .integer(.init(value)) }
  public static func box(_ value: String, encoder: IVE) throws -> YAML { return .string(value) }
  public static func box(_ value: URL, encoder: IVE) throws -> YAML { return .string(value.absoluteString) }
  public static func box(_ value: UUID, encoder: IVE) throws -> YAML { return .string(value.uuidString) }

  public static func box(_ float: Float16, encoder: IVE) throws -> YAML {
    guard !float.isInfinite, !float.isNaN else {
      if float == Float16.infinity {
        return .float(YAML.Number("+.inf", isInteger: false, isNegative: false))
      }
      else if float == -Float16.infinity {
        return .float(YAML.Number("-.inf", isInteger: false, isNegative: true))
      }
      else {
        return .float(YAML.Number(".nan", isInteger: false, isNegative: false))
      }
    }

    return .float(.init(float))
  }

  public static func box(_ float: Float, encoder: IVE) throws -> YAML {
    guard !float.isInfinite, !float.isNaN else {
      if float == Float.infinity {
        return .float(YAML.Number("+.inf", isInteger: false, isNegative: false))
      }
      else if float == -Float.infinity {
        return .float(YAML.Number("-.inf", isInteger: false, isNegative: true))
      }
      else {
        return .float(YAML.Number(".nan", isInteger: false, isNegative: false))
      }
    }

    return .float(.init(float))
  }

  public static func box(_ double: Double, encoder: IVE) throws -> YAML {
    guard !double.isInfinite, !double.isNaN else {
      if double == Double.infinity {
        return .float(YAML.Number("+.inf", isInteger: false, isNegative: false))
      }
      else if double == -Double.infinity {
        return .float(YAML.Number("-.inf", isInteger: false, isNegative: true))
      }
      else {
        return .float(YAML.Number(".nan", isInteger: false, isNegative: false))
      }
    }

    return .float(.init(double))
  }

  public static func box(_ decimal: Decimal, encoder: IVE) throws -> YAML {
    guard !decimal.isInfinite, !decimal.isNaN else {
      if decimal.isNaN {
        return .float(YAML.Number(".nan", isInteger: false, isNegative: false))
      }
      else {
        throw EncodingError.invalidFloatingPointValue(decimal, at: encoder.codingPath)
      }
    }

    return .float(YAML.Number(decimal.description, isInteger: false, isNegative: false))
  }

  public static func box(_ value: Data, encoder: IVE) throws -> YAML {
    switch encoder.options.dataEncodingStrategy {
    case .deferredToData:
      return try encoder.subEncode { try value.encode(to: $0.encoder) } ?? emptyKeyedContainer

    case .base64:
      return .string(value.base64EncodedString())

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0.encoder) } ?? emptyKeyedContainer
    }
  }

  public static func box(_ value: Date, encoder: IVE) throws -> YAML {
    switch encoder.options.dateEncodingStrategy {
    case .deferredToDate:
      return try encoder.subEncode { try value.encode(to: $0.encoder) } ?? emptyKeyedContainer

    case .secondsSince1970:
      return .float(.init(value.timeIntervalSince1970.description))

    case .millisecondsSince1970:
      return .integer(.init((1000.0 * value.timeIntervalSince1970).description))

    case .iso8601:
      return .string(ZonedDate(date: value, timeZone: .utc).iso8601EncodedString())

    case .formatted(let formatter):
      return .string(formatter.string(from: value))

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0.encoder) } ?? emptyKeyedContainer
    }
  }

  public static func box(_ value: AnyValue, encoder: IVE) throws -> YAML {
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
      return .sequence(try value.map { try box($0, encoder: encoder) })
    case .dictionary(let value):
      return .mapping(try value.map {
        YAML.MappingEntry(key: try box($0, encoder: encoder), value: try box($1, encoder: encoder))
      })
    }
  }

  public static func unkeyedValuesToValue(_ values: UnkeyedValues, encoder: IVE) -> YAML {
    return .sequence(values)
  }

  public static func keyedValuesToValue(_ values: KeyedValues, encoder: IVE) -> YAML {
    return .mapping(
      values.map { YAML.MappingEntry(key: YAML($0), value: $1) },
      style: .any,
      tag: nil,
      anchor: nil
    )
  }

  public static func data(from value: YAML, options: Options) throws -> Data {
    var writingOptions: YAMLSerialization.WritingOptions = []
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    if options.outputFormatting.contains(.pretty) {
      writingOptions.insert(.pretty)
    }
    if options.outputFormatting.contains(.json) {
      writingOptions.insert(.json)
    }
    return try YAMLSerialization.data(from: value,
                                      preferredCollectionStyle: options.preferredCollectionStyle,
                                      preferredStringStyle: options.preferredStringStyle,
                                      options: writingOptions)
  }

  public static func string(from value: YAML, options: Options) throws -> String {
    var writingOptions: YAMLSerialization.WritingOptions = []
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    if options.outputFormatting.contains(.pretty) {
      writingOptions.insert(.pretty)
    }
    if options.outputFormatting.contains(.json) {
      writingOptions.insert(.json)
    }
    return try YAMLSerialization.string(from: value,
                                        preferredCollectionStyle: options.preferredCollectionStyle,
                                        preferredStringStyle: options.preferredStringStyle,
                                        options: writingOptions)
  }

}


extension YAMLEncoder: TopLevelEncoder {
  public typealias Output = Data
}
