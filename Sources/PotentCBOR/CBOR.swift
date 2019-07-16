//
//  CBOR.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// General CBOR value.
///
/// # Map Access
/// `CBOR` supoprts Swift's "dnyamic member lookup" so CBOR fields of `map` values can be accessed in Swift syntax
///
///     cborObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     cborObject["@value"]
///
/// - Note: CBOR supports complex key values and thus any `CBOR` value can be used to subscript a `map` value.
///
/// # Array Access
/// The elements of CBOR `array` values can use index subscripting to access individual array values:
///
///     cborArray[0]
///
@dynamicMemberLookup
public indirect enum CBOR: Equatable, Hashable {

  /// A CBOR `tag` for tagged values supported by the specification.
  ///
  public struct Tag: RawRepresentable, Equatable, Hashable {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
      self.rawValue = rawValue
    }

    public var hashValue: Int {
      return rawValue.hashValue
    }
  }

  case unsignedInt(UInt64)
  case negativeInt(UInt64)
  case byteString(Data)
  case utf8String(String)
  case array([CBOR])
  case map([CBOR: CBOR])
  case tagged(Tag, CBOR)
  case simple(UInt8)
  case boolean(Bool)
  case null
  case undefined
  case half(Float16)
  case float(Float32)
  case double(Float64)

  public var isNull: Bool {
    if case .null = self { return true }
    return false
  }

  public var booleanValue: Bool? {
    guard case .boolean(let bool) = untagged else { return nil }
    return bool
  }

  public var bytesStringValue: Data? {
    guard case .byteString(let data) = untagged else { return nil }
    return data
  }

  public var utf8StringValue: String? {
    guard case .utf8String(let string) = untagged else { return nil }
    return string
  }

  public var arrayValue: [CBOR]? {
    guard case .array(let array) = untagged else { return nil }
    return array
  }

  public var mapValue: [CBOR: CBOR]? {
    guard case .map(let map) = untagged else { return nil }
    return map
  }

  public var halfValue: Float16? {
    guard case .half(let half) = untagged else { return nil }
    return half
  }

  public var floatValue: Float32? {
    guard case .float(let float) = untagged else { return nil }
    return float
  }

  public var doubleValue: Float64? {
    guard case .double(let double) = untagged else { return nil }
    return double
  }

  public var simpleValue: UInt8? {
    guard case .simple(let simple) = untagged else { return nil }
    return simple
  }

  public var isNumber: Bool {
    switch untagged {
    case .unsignedInt, .negativeInt, .half, .float, .double: return true
    default: return false
    }
  }

  public var numberValue: Float80? {
    switch untagged {
    case .unsignedInt(let uint): return Float80(exactly: uint)
    case .negativeInt(let nint): return Float80(exactly: nint).map { -1 - $0 }
    case .half(let half): return Float80(half.floatValue)
    case .float(let float): return Float80(float)
    case .double(let double): return Float80(double)
    default: return nil
    }
  }

  public init(_ value: Bool) {
    self = .boolean(value)
  }

  public init(_ value: String) {
    self = .utf8String(value)
  }

  public init(_ value: Data) {
    self = .byteString(value)
  }

  public init(_ value: Int) {
    self.init(Int64(value))
  }

  public init(_ value: Int64) {
    if value < 0 {
      self = .negativeInt(~UInt64(bitPattern: Int64(value)))
    }
    else {
      self = .unsignedInt(UInt64(value))
    }
  }

  public init(_ value: UInt) {
    self.init(UInt64(value))
  }

  public init(_ value: UInt64) {
    self = .unsignedInt(value)
  }

  public init(_ value: Half) {
    self = .half(value)
  }

  public init(_ value: Float) {
    self = .float(value)
  }

  public init(_ value: Double) {
    self = .double(value)
  }

  public subscript(dynamicMember member: CBOR) -> CBOR? {
    if let map = mapValue {
      return map[member]
    }
    return nil
  }

  public subscript(position: CBOR) -> CBOR? {
    get {
      switch (self, position) {
      case (let .array(l), .unsignedInt(let i)): return l[Int(i)]
      case (let .map(l), let i): return l[i]
      default: return nil
      }
    }
    set(x) {
      switch (self, position) {
      case (var .array(l), .unsignedInt(let i)):
        l[Int(i)] = x!
        self = .array(l)
      case (var .map(l), let i):
        l[i] = x!
        self = .map(l)
      default: break
      }
    }
  }

  /// Returns the CBOR value stripped of all `tagged` values.
  ///
  /// # Map/Array
  /// If the value is a compex value, like `map` or `array` all values
  /// contained in them are untagged recursively.
  ///
  public var untagged: CBOR {
    guard case .tagged(_, let value) = self else {
      return self
    }
    return value.untagged
  }

}

extension CBOR: ExpressibleByNilLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral,
  ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByBooleanLiteral,
  ExpressibleByFloatLiteral {

  public init(nilLiteral: ()) {
    self = .null
  }

  public init(integerLiteral value: Int) {
    self.init(value)
  }

  public init(extendedGraphemeClusterLiteral value: String) {
    self = .utf8String(value)
  }

  public init(unicodeScalarLiteral value: String) {
    self = .utf8String(value)
  }

  public init(stringLiteral value: String) {
    self = .utf8String(value)
  }

  public init(arrayLiteral elements: CBOR...) {
    self = .array(elements)
  }

  public init(dictionaryLiteral elements: (CBOR, CBOR)...) {
    var result = [CBOR: CBOR]()
    for (key, value) in elements {
      result[key] = value
    }
    self = .map(result)
  }

  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }

  public init(floatLiteral value: Double) {
    self = .double(value)
  }

}

extension CBOR.Tag {
  public static let iso8601DateTime = CBOR.Tag(rawValue: 0)
  public static let epochDateTime = CBOR.Tag(rawValue: 1)
  public static let positiveBignum = CBOR.Tag(rawValue: 2)
  public static let negativeBignum = CBOR.Tag(rawValue: 3)
  public static let decimalFraction = CBOR.Tag(rawValue: 4)
  public static let bigfloat = CBOR.Tag(rawValue: 5)

  // 6...20 unassigned

  public static let expectedConversionToBase64URLEncoding = CBOR.Tag(rawValue: 21)
  public static let expectedConversionToBase64Encoding = CBOR.Tag(rawValue: 22)
  public static let expectedConversionToBase16Encoding = CBOR.Tag(rawValue: 23)
  public static let encodedCBORDataItem = CBOR.Tag(rawValue: 24)

  // 25...31 unassigned

  public static let uri = CBOR.Tag(rawValue: 32)
  public static let base64Url = CBOR.Tag(rawValue: 33)
  public static let base64 = CBOR.Tag(rawValue: 34)
  public static let regularExpression = CBOR.Tag(rawValue: 35)
  public static let mimeMessage = CBOR.Tag(rawValue: 36)
  public static let uuid = CBOR.Tag(rawValue: 37)

  // 38...55798 unassigned

  public static let selfDescribeCBOR = CBOR.Tag(rawValue: 55799)
}

extension CBOR: Value {

  public var unwrapped: Any? {
    switch self {
    case .null: return nil
    case .undefined: return nil
    case .boolean(let value): return value
    case .utf8String(let value): return value
    case .byteString(let value): return value
    case .simple(let value): return value
    case .unsignedInt(let value): return value
    case .negativeInt(let value): return -1 - Int(value)
    case .float(let value): return value
    case .half(let value): return value.floatValue
    case .double(let value): return value
    case .array(let value): return Array(value.map { $0.unwrapped })
    case .map(let value): return Dictionary(uniqueKeysWithValues: value.map { key, value in (key.unwrapped as! String, value.unwrapped) })
    case .tagged(_, let value): return value.unwrapped
    }
  }

}


/// Make encoders/decoders available in CBOR namespace
///
public extension CBOR {

  typealias Encoder = CBOREncoder
  typealias Decoder = CBORDecoder

}
