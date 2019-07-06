//
//  JSONEncoder.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/13/19.
//

import Foundation


/// `JSONEncoder` facilitates the encoding of `Encodable` values into JSON values.
public class JSONEncoder : ValueEncoder<JSON, JSONEncoderTransform> {

  public static let `default` = JSONEncoder()

  // MARK: Options

  /// The formatting of the output JSON data.
  public struct OutputFormatting : OptionSet {

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
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
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
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
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
    return JSONEncoderTransform.Options(dateEncodingStrategy: dateEncodingStrategy,
                                        dataEncodingStrategy: dataEncodingStrategy,
                                        nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
                                        outputFormatting: outputFormatting,
                                        keyEncodingStrategy: keyEncodingStrategy,
                                        userInfo: userInfo)
  }


  public override init() {
    super.init()
  }

}



public struct JSONEncoderTransform : InternalEncoderTransform, InternalValueSerializer, InternalValueStringifier {

  public typealias Value = JSON

  public static let nilValue = JSON.null
  public static var emptyKeyedContainer = JSON.object([:])

  public struct Options : InternalEncoderOptions {
    public let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
    public let dataEncodingStrategy: JSONEncoder.DataEncodingStrategy
    public let nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy
    public let outputFormatting: JSONEncoder.OutputFormatting
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey : Any]
  }

  public static func box(_ value: Bool, encoder: InternalValueEncoder<Value, Self>)     throws -> JSON { return .bool(value) }
  public static func box(_ value: Int, encoder: InternalValueEncoder<Value, Self>)      throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: Int8, encoder: InternalValueEncoder<Value, Self>)     throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: Int16, encoder: InternalValueEncoder<Value, Self>)    throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: Int32, encoder: InternalValueEncoder<Value, Self>)    throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: Int64, encoder: InternalValueEncoder<Value, Self>)    throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: UInt, encoder: InternalValueEncoder<Value, Self>)     throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: UInt8, encoder: InternalValueEncoder<Value, Self>)    throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: UInt16, encoder: InternalValueEncoder<Value, Self>)   throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: UInt32, encoder: InternalValueEncoder<Value, Self>)   throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: UInt64, encoder: InternalValueEncoder<Value, Self>)   throws -> JSON { return .number(Float80(exactly: value)!) }
  public static func box(_ value: String, encoder: InternalValueEncoder<Value, Self>)   throws -> JSON { return .string(value) }
  public static func box(_ value: URL, encoder: InternalValueEncoder<Value, Self>)      throws -> JSON { return .string(value.absoluteString) }
  public static func box(_ value: UUID, encoder: InternalValueEncoder<Value, Self>)     throws -> JSON { return .string(value.uuidString) }

  public static func box(_ float: Float, encoder: InternalValueEncoder<Value, Self>) throws -> JSON {
    guard !float.isInfinite && !float.isNaN else {
      guard case let .convertToString(positiveInfinity: posInfString,
                                      negativeInfinity: negInfString,
                                      nan: nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
                                        throw EncodingError._invalidFloatingPointValue(float, at: encoder.codingPath)
      }

      if float == Float.infinity {
        return .string(posInfString)
      } else if float == -Float.infinity {
        return .string(negInfString)
      } else {
        return .string(nanString)
      }
    }

    return .number(Float80(float))
  }

  public static func box(_ double: Double, encoder: InternalValueEncoder<Value, Self>) throws -> JSON {
    guard !double.isInfinite && !double.isNaN else {
      guard case let .convertToString(positiveInfinity: posInfString,
                                      negativeInfinity: negInfString,
                                      nan: nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
                                        throw EncodingError._invalidFloatingPointValue(double, at: encoder.codingPath)
      }

      if double == Double.infinity {
        return .string(posInfString)
      } else if double == -Double.infinity {
        return .string(negInfString)
      } else {
        return .string(nanString)
      }
    }

    return .number(Float80(double))
  }

  public static func box(_ decimal: Decimal, encoder: InternalValueEncoder<Value, Self>) throws -> JSON {
    guard !decimal.isInfinite && !decimal.isNaN else {
      guard case let .convertToString(positiveInfinity: posInfString,
                                      negativeInfinity: negInfString,
                                      nan: nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
                                        throw EncodingError._invalidFloatingPointValue(decimal, at: encoder.codingPath)
      }

      if decimal.isInfinite && decimal.sign == .plus {
        return .string(posInfString)
      } else if decimal.isInfinite && decimal.sign == .minus {
        return .string(negInfString)
      } else {
        return .string(nanString)
      }
    }

    var decimal = decimal
    let rep = NSDecimalString(&decimal, NSLocale.system)

    return .number(Float80(rep)!)
  }

  public static func box(_ value: Data, encoder: InternalValueEncoder<Value, Self>) throws -> JSON {
    switch encoder.options.dataEncodingStrategy {
    case .deferredToData:
      return try encoder.subEncode { try value.encode(to: $0) }

    case .base64:
      return .string(value.base64EncodedString())

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0) }
    }
  }

  public static func box(_ value: Date, encoder: InternalValueEncoder<Value, Self>) throws -> JSON {
    switch encoder.options.dateEncodingStrategy {
    case .deferredToDate:
      return try encoder.subEncode { try value.encode(to: $0) }

    case .secondsSince1970:
      return .number(Float80(value.timeIntervalSince1970))

    case .millisecondsSince1970:
      return .number(Float80(1000.0 * value.timeIntervalSince1970))

    case .iso8601:
      return .string(_iso8601Formatter.string(from: value))

    case .formatted(let formatter):
      return .string(formatter.string(from: value))

    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0) }
    }
  }

  public static func unkeyedValuesToValue(_ values: [JSON]) -> JSON {
    return .array(values)
  }

  public static func keyedValuesToValue(_ values: [String : JSON]) -> JSON {
    return .object(values)
  }

  public static func data(from value: JSON, options: Options) throws -> Data {
    var writingOptions: JSONSerialization.WritingOptions = []
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
    if options.outputFormatting.contains(.prettyPrinted) {
      writingOptions.insert(.prettyPrinted)
    }
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    return try JSONSerialization.string(from: value, options: writingOptions)
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
