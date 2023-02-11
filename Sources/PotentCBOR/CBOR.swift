//
//  CBOR.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import OrderedCollections
import PotentCodables


/// General CBOR value.
///
/// # Map Access
/// ``CBOR`` supoprts Swift's "dnyamic member lookup" so CBOR fields of ``CBOR/map(_:)`` values can be accessed in
/// Swift syntax
///
///     cborObject.someValue
///
/// For field names that are non-conformant Swift identifiers subscript syntax is also supported:
///
///     cborObject["@value"]
///
/// - Note: CBOR supports complex key values and thus any ``CBOR`` value can be used to subscript a ``CBOR/map(_:)``
/// value.
///
/// # Array Access
/// The elements of CBOR ``CBOR/array(_:)`` values can use index subscripting to access individual array values:
///
///     cborArray[0]
///
@dynamicMemberLookup
public indirect enum CBOR {

  /// A CBOR `tag` for tagged values supported by the specification.
  ///
  public struct Tag: RawRepresentable, Equatable, Hashable {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
      self.rawValue = rawValue
    }
  }


  public typealias Half = Float16
  public typealias Float = Float32
  public typealias Double = Float64

  public typealias Array = [CBOR]
  public typealias Map = OrderedDictionary<CBOR, CBOR>

  case unsignedInt(UInt64)
  case negativeInt(UInt64)
  case byteString(Data)
  case utf8String(String)
  case array(Array)
  case map(Map)
  case tagged(Tag, CBOR)
  case simple(UInt8)
  case boolean(Bool)
  case null
  case undefined
  case half(Half)
  case float(Float)
  case double(Double)

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
      self = .negativeInt(UInt64(bitPattern: ~value))
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

  public init(_ value: Swift.Float) {
    self = .float(value)
  }

  public init(_ value: Swift.Double) {
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
      case (let .array(array), .unsignedInt(let index)) where index < array.count: return array[Int(index)]
      case (let .map(map), let key): return map[key]
      default: return nil
      }
    }
    set {
      switch (self, position) {
      case (var .array(array), .unsignedInt(let index)):
        array[Int(index)] = newValue ?? .null
        self = .array(array)
      case (var .map(map), let key):
        map[key] = newValue ?? .null
        self = .map(map)
      default: break
      }
    }
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

  public var arrayValue: Array? {
    guard case .array(let array) = untagged else { return nil }
    return array
  }

  public var mapValue: Map? {
    guard case .map(let map) = untagged else { return nil }
    return map
  }

  public var halfValue: Half? {
    guard case .half(let half) = untagged else { return nil }
    return half
  }

  public var floatValue: Float? {
    guard case .float(let float) = untagged else { return nil }
    return float
  }

  public var doubleValue: Double? {
    guard case .double(let double) = untagged else { return nil }
    return double
  }

  public var simpleValue: UInt8? {
    guard case .simple(let simple) = untagged else { return nil }
    return simple
  }

  @available(*, deprecated, message: "Use floatingPointValue or integerValue instead")
  public var numberValue: Double? { floatingPointValue() }

  public func integerValue<T: BinaryInteger>() -> T? {
    switch untagged {
    case .unsignedInt(let uint): return T(uint)
    case .negativeInt(let nint): return T(Int64(bitPattern: ~nint))
    default: return nil
    }
  }

  public func floatingPointValue<T: BinaryFloatingPoint>() -> T? {
    switch untagged {
    case .unsignedInt(let uint): return T(uint)
    case .negativeInt(let nint): return T(Int64(bitPattern: ~nint))
    case .half(let half): return T(half)
    case .float(let float): return T(float)
    case .double(let double): return T(double)
    default: return nil
    }
  }

  /// Returns the CBOR value stripped of all ``CBOR/tagged(_:_:)`` values.
  ///
  /// # Map/Array
  /// If the value is a compex value, like ``CBOR/map(_:)`` or ``CBOR/array(_:)`` all values
  /// contained in them are untagged recursively.
  ///
  public var untagged: CBOR {
    guard case .tagged(_, let value) = self else {
      return self
    }
    return value.untagged
  }

}

public extension CBOR.Tag {
  static let iso8601DateTime = CBOR.Tag(rawValue: 0)
  static let epochDateTime = CBOR.Tag(rawValue: 1)
  static let positiveBignum = CBOR.Tag(rawValue: 2)
  static let negativeBignum = CBOR.Tag(rawValue: 3)
  static let decimalFraction = CBOR.Tag(rawValue: 4)
  static let bigfloat = CBOR.Tag(rawValue: 5)

  // 6...20 unassigned

  static let expectedConversionToBase64URLEncoding = CBOR.Tag(rawValue: 21)
  static let expectedConversionToBase64Encoding = CBOR.Tag(rawValue: 22)
  static let expectedConversionToBase16Encoding = CBOR.Tag(rawValue: 23)
  static let encodedCBORDataItem = CBOR.Tag(rawValue: 24)

  // 25...31 unassigned

  static let uri = CBOR.Tag(rawValue: 32)
  static let base64Url = CBOR.Tag(rawValue: 33)
  static let base64 = CBOR.Tag(rawValue: 34)
  static let regularExpression = CBOR.Tag(rawValue: 35)
  static let mimeMessage = CBOR.Tag(rawValue: 36)
  static let uuid = CBOR.Tag(rawValue: 37)

  // 38...55798 unassigned

  static let selfDescribeCBOR = CBOR.Tag(rawValue: 55799)
}


// MARK: Conformances

extension CBOR: Equatable {}
extension CBOR: Hashable {}
extension CBOR: Value {

  public var isNull: Bool {
    if case .null = self {
      return true
    }
    return false
  }

}


// MARK: Wrapping

extension CBOR {

  public var unwrapped: Any? {
    switch self {
    case .null: return nil
    case .undefined: return nil
    case .boolean(let value): return value
    case .utf8String(let value): return value
    case .byteString(let value): return value
    case .simple(let value): return value
    case .unsignedInt(let value): return value
    case .negativeInt(let value): return Int64(bitPattern: ~value)
    case .float(let value): return value
    case .half(let value): return value
    case .double(let value): return value
    case .array(let value): return Swift.Array(value.map(\.unwrapped))
    case .map(let value): return Dictionary(uniqueKeysWithValues: value.map { key, value in
        (key.unwrapped as? AnyHashable, value.unwrapped)
      })
    case .tagged(_, let value): return value.unwrapped
    }
  }

}


// MARK: Literals

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
    self = .map(Map(uniqueKeysWithValues: elements))
  }

  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }

  public init(floatLiteral value: Double) {
    self = .double(value)
  }

}


// Make encoders/decoders available in AnyValue namespace

public extension CBOR {

  typealias Encoder = CBOREncoder
  typealias Decoder = CBORDecoder

}
