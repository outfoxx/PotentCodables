//
//  YAMLEncoder.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// `YAMLEncoder` facilitates the encoding of `Encodable` values into YAML values.
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
    
    /// Produce YAML with dictionary keys sorted in lexicographic order.
    public static let sortedKeys = OutputFormatting(rawValue: 1 << 1)
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
  
  /// The strategy to use for non-YAML-conforming floating-point values (IEEE 754 infinity and NaN).
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
  public var dataEncodingStrategy: YAMLEncoder.DataEncodingStrategy = .base64
  
  /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
  public var nonConformingFloatEncodingStrategy: YAMLEncoder.NonConformingFloatEncodingStrategy = .throw
  
  /// The options set on the top-level encoder.
  public override var options: YAMLEncoderTransform.Options {
    return YAMLEncoderTransform.Options(dateEncodingStrategy: dateEncodingStrategy,
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



public struct YAMLEncoderTransform: InternalEncoderTransform, InternalValueSerializer, InternalValueStringifier {
  
  public typealias Value = YAML
  public typealias Encoder = InternalValueEncoder<Value, Self>
  public typealias State = Void
  
  public static var emptyKeyedContainer = YAML.mapping([], style: .any, tag: nil, anchor: nil)
  public static var emptyUnkeyedContainer = YAML.sequence([], style: .any, tag: nil, anchor: nil)
  
  public struct Options: InternalEncoderOptions {
    public let dateEncodingStrategy: YAMLEncoder.DateEncodingStrategy
    public let dataEncodingStrategy: YAMLEncoder.DataEncodingStrategy
    public let nonConformingFloatEncodingStrategy: YAMLEncoder.NonConformingFloatEncodingStrategy
    public let outputFormatting: YAMLEncoder.OutputFormatting
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }
  
  public static func boxNil(encoder: Encoder) throws -> YAML { return .null(anchor: nil) }
  public static func box(_ value: Bool, encoder: Encoder) throws -> YAML { return .bool(value, anchor: nil) }
  public static func box(_ value: Int, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: Int8, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: Int16, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: Int32, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: Int64, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: UInt, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: UInt8, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: UInt16, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: UInt32, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: UInt64, encoder: Encoder) throws -> YAML { return .integer(.init(value.description), anchor: nil) }
  public static func box(_ value: String, encoder: Encoder) throws -> YAML { return .string(value, style: .any, tag: nil, anchor: nil) }
  public static func box(_ value: URL, encoder: Encoder) throws -> YAML { return .string(value.absoluteString, style: .any, tag: nil, anchor: nil) }
  public static func box(_ value: UUID, encoder: Encoder) throws -> YAML { return .string(value.uuidString, style: .any, tag: nil, anchor: nil) }
  
  public static func box(_ float: Float, encoder: Encoder) throws -> YAML {
    guard !float.isInfinite, !float.isNaN else {
      guard case .convertToString(let posInfString,
                                  let negInfString,
                                  let nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(float, at: encoder.codingPath)
      }
      
      if float == Float.infinity {
        return .string(posInfString, style: .any, tag: nil, anchor: nil)
      }
      else if float == -Float.infinity {
        return .string(negInfString, style: .any, tag: nil, anchor: nil)
      }
      else {
        return .string(nanString, style: .any, tag: nil, anchor: nil)
      }
    }
    
    return .float(.init(float.description), anchor: nil)
  }
  
  public static func box(_ double: Double, encoder: Encoder) throws -> YAML {
    guard !double.isInfinite, !double.isNaN else {
      guard case .convertToString(let posInfString,
                                  let negInfString,
                                  let nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(double, at: encoder.codingPath)
      }
      
      if double == Double.infinity {
        return .string(posInfString, style: .any, tag: nil, anchor: nil)
      }
      else if double == -Double.infinity {
        return .string(negInfString, style: .any, tag: nil, anchor: nil)
      }
      else {
        return .string(nanString, style: .any, tag: nil, anchor: nil)
      }
    }
    
    return .float(.init(double.description), anchor: nil)
  }
  
  public static func box(_ decimal: Decimal, encoder: Encoder) throws -> YAML {
    guard !decimal.isInfinite, !decimal.isNaN else {
      guard case .convertToString(let posInfString,
                                  let negInfString,
                                  let nanString) = encoder.options.nonConformingFloatEncodingStrategy else {
        throw EncodingError.invalidFloatingPointValue(decimal, at: encoder.codingPath)
      }
      
      if decimal.isInfinite, decimal.sign == .plus {
        return .string(posInfString, style: .any, tag: nil, anchor: nil)
      }
      else if decimal.isInfinite, decimal.sign == .minus {
        return .string(negInfString, style: .any, tag: nil, anchor: nil)
      }
      else {
        return .string(nanString, style: .any, tag: nil, anchor: nil)
      }
    }
    
    var decimal = decimal
    let rep = NSDecimalString(&decimal, NSLocale.system)
    
    return .float(.init(rep.description), anchor: nil)
  }
  
  public static func box(_ value: Data, encoder: Encoder) throws -> YAML {
    switch encoder.options.dataEncodingStrategy {
    case .deferredToData:
      return try encoder.subEncode { try value.encode(to: $0) } ?? emptyKeyedContainer
      
    case .base64:
      return .string(value.base64EncodedString(), style: .any, tag: nil, anchor: nil)
      
    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0) } ?? emptyKeyedContainer
    }
  }
  
  public static func box(_ value: Date, encoder: Encoder) throws -> YAML {
    switch encoder.options.dateEncodingStrategy {
    case .deferredToDate:
      return try encoder.subEncode { try value.encode(to: $0) } ?? emptyKeyedContainer
      
    case .secondsSince1970:
      return .float(.init(value.timeIntervalSince1970.description), anchor: nil)
      
    case .millisecondsSince1970:
      return .integer(.init((1000.0 * value.timeIntervalSince1970).description), anchor: nil)
      
    case .iso8601:
      return .string(_iso8601Formatter.string(from: value), style: .any, tag: nil, anchor: nil)
      
    case .formatted(let formatter):
      return .string(formatter.string(from: value), style: .any, tag: nil, anchor: nil)
      
    case .custom(let closure):
      return try encoder.subEncode { try closure(value, $0) } ?? emptyKeyedContainer
    }
  }
  
  public static func unkeyedValuesToValue(_ values: [YAML], encoder: Encoder) -> YAML {
    return .sequence(values, style: .any, tag: nil, anchor: nil)
  }
  
  public static func keyedValuesToValue(_ values: [String: YAML], encoder: Encoder) -> YAML {
    return .mapping(values.map { (.init(key: .string($0.key, style: .any, tag: nil, anchor: nil), value: $0.value)) }, style: .any, tag: nil, anchor: nil)
  }
  
  public static func data(from value: YAML, options: Options) throws -> Data {
    var writingOptions: YAMLSerialization.WritingOptions = []
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    return try YAMLSerialization.data(from: value, options: writingOptions)
  }
  
  public static func string(from value: YAML, options: Options) throws -> String {
    var writingOptions: YAMLSerialization.WritingOptions = []
    if options.outputFormatting.contains(.sortedKeys) {
      writingOptions.insert(.sortedKeys)
    }
    return try YAMLSerialization.string(from: value, options: writingOptions)
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

extension YAMLEncoder : TopLevelEncoder {
  public typealias Output = Data
}

#endif
