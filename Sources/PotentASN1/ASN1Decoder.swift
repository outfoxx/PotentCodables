//
//  ASN1Decoder.swift
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
import PotentCodables


/// Decodes `Decodable` types from ASN.1/DER data or ``ASN1`` value trees using a ``Schema``.
///
/// When decoding a `Decodable` type from ASN.1, the ``ASN1Decoder`` is initialized with a
/// ``Schema`` to direct decoding.
///
/// Decode an example `TBSCertificate` type with an associated `TBSCertificateSchema` as follows:
/// ```swift
/// ASN1Decoder(schema: TBSCertificateSchema)
///   .decode(TBSCertificate.self, from: asn1Data)
/// ```
///
/// See ``Schema`` to learn about defining ASN.1 schemas.
///
/// If the example `TBSCertificate` adopts the ``SchemaSpecified`` protocol, static utility
/// functions can be used to decode types without having to initialize the decoder with a
/// schema. This also ensures the correct schema is always provided to the decoder.
/// ```swift
/// ASN1Decoder.decode(TBSCertificate.self, from: asn1Data)
/// ```
///
public class ASN1Decoder: ValueDecoder<ASN1, ASN1DecoderTransform>, DecodesFromData {

  public let schema: Schema

  /// The options set on the top-level decoder.
  override public var options: ASN1DecoderTransform.Options {
    return ASN1DecoderTransform.Options(
      schema: schema,
      keyDecodingStrategy: .useDefaultKeys,
      userInfo: userInfo
    )
  }

  /// Initialize decoder with a specified ``schema``.
  ///
  /// - Parameter schema: Schema to use for decoding.
  ///
  public required init(schema: Schema) {
    self.schema = schema
    super.init()
  }

  /// Decode a `Decodable` & ``SchemaSpecified`` type from ASN.1/DER encoded data.
  ///
  /// - Parameters:
  ///   - type: Type of value to decode.
  ///   - data: ASN.1/DER encoded data.
  /// - Returns: Decoded value of `type`.
  /// - Throws:
  public static func decode<T: Decodable & SchemaSpecified>(_ type: T.Type, from data: Data) throws -> T {
    return try Self(schema: T.asn1Schema).decode(type, from: data)
  }

  /// Decode a `Decodable` & ``SchemaSpecified`` type from an ``ASN1`` value tree.
  ///
  /// - Parameters:
  ///   - type: Type of value to decode.
  ///   - asn1: ASN1 value tree.
  /// - Returns: Decoded value of `type`.
  ///
  public static func decodeTree<T: Decodable & SchemaSpecified>(_ type: T.Type, from asn1: ASN1) throws -> T {
    return try Self(schema: T.asn1Schema).decodeTree(type, from: asn1)
  }

}


public struct ASN1DecoderTransform: InternalDecoderTransform, InternalValueDeserializer {

  public typealias Value = ASN1
  public typealias State = SchemaState

  public static let nilValue = ASN1.null

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let schema: Schema
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  static func decode(_ value: ASN1, decoder: IVD) throws -> Any? {

    let state = try decoder.state ?? SchemaState(initial: decoder.options.schema)
    decoder.state = state

    let keep = zip(state.keyStack, decoder.codingPath).prefix { $0.0.stringValue == $0.1.stringValue }.count

    let drop = state.count - keep
    state.removeLast(count: drop)

    for key in decoder.codingPath[state.count...] {
      guard let container = state.container(forCodingPath: state.keyStack) else {
        fatalError("container should already be cached")
      }
      try state.step(into: container, key: key)
    }

    return try state.decode(value)
  }

  static let interceptedTypes: [Any.Type] = [
    AnyString.self,
    AnyTime.self,
    ZonedDate.self,
    BitString.self,
    ObjectIdentifier.self,
    ASN1.Integer.self,
    Date.self, NSDate.self,
    Data.self, NSData.self,
    URL.self, NSURL.self,
    UUID.self, NSUUID.self,
    Decimal.self, NSDecimalNumber.self,
    BigInt.self,
    BigUInt.self,
    AnyValue.self,
  ]

  public static func intercepts(_ type: Decodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type } || type is Tagged.Type
  }

  public static func unbox(_ value: ASN1, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
    if let taggedType = interceptedType as? Tagged.Type {
      return try unbox(value, as: taggedType, decoder: decoder)
    }
    else if interceptedType == AnyString.self {
      return try unbox(value, as: AnyString.self, decoder: decoder)
    }
    else if interceptedType == AnyTime.self {
      return try unbox(value, as: AnyTime.self, decoder: decoder)
    }
    else if interceptedType == ZonedDate.self {
      return try unbox(value, as: ZonedDate.self, decoder: decoder)
    }
    else if interceptedType == BitString.self {
      return try unbox(value, as: BitString.self, decoder: decoder)
    }
    else if interceptedType == ObjectIdentifier.self {
      return try unbox(value, as: ObjectIdentifier.self, decoder: decoder)
    }
    else if interceptedType == Date.self || interceptedType == NSDate.self {
      return try unbox(value, as: Date.self, decoder: decoder)
    }
    else if interceptedType == Data.self || interceptedType == NSData.self {
      return try unbox(value, as: Data.self, decoder: decoder)
    }
    else if interceptedType == URL.self || interceptedType == URL.self {
      return try unbox(value, as: URL.self, decoder: decoder)
    }
    else if interceptedType == UUID.self || interceptedType == UUID.self {
      return try unbox(value, as: UUID.self, decoder: decoder)
    }
    else if interceptedType == Decimal.self || interceptedType == NSDecimalNumber.self {
      return try unbox(value, as: Decimal.self, decoder: decoder)
    }
    else if interceptedType == BigInt.self {
      return try unbox(value, as: BigInt.self, decoder: decoder)
    }
    else if interceptedType == BigUInt.self {
      return try unbox(value, as: BigUInt.self, decoder: decoder)
    }
    else if interceptedType == AnyValue.self {
      return try unbox(value, as: AnyValue.self, decoder: decoder)
    }
    else {
      fatalError("type not valid for intercept")
    }
  }

  public static func unbox(_ value: ASN1, as type: Tagged.Type, decoder: IVD) throws -> Tagged? {
    guard let decoded = try decode(value, decoder: decoder) else { return nil }
    return type.init(tag: value.anyTag, value: decoded)
  }

  public static func unbox(_ value: ASN1, as type: AnyString.Type, decoder: IVD) throws -> AnyString? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString: return string
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: AnyTime.Type, decoder: IVD) throws -> AnyTime? {
    switch try decode(value, decoder: decoder) {
    case let time as AnyTime: return time
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: ZonedDate.Type, decoder: IVD) throws -> ZonedDate? {
    switch try decode(value, decoder: decoder) {
    case let time as AnyTime: return time.zonedDate
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: BitString.Type, decoder: IVD) throws -> BitString? {
    switch try decode(value, decoder: decoder) {
    case let bitString as BitString: return bitString
    case let data as Data: return BitString(length: data.count * 8, bytes: data)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: ObjectIdentifier.Type, decoder: IVD) throws -> ObjectIdentifier? {
    switch try decode(value, decoder: decoder) {
    case let oid as ObjectIdentifier: return oid
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: ASN1, as type: Bool.Type, decoder: IVD) throws -> Bool? {
    switch try decode(value, decoder: decoder) {
    case let bool as Bool: return bool
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  static func overflow(_ type: Any.Type, value: Any, at codingPath: [CodingKey]) -> Error {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(value) overflows \(type)")
    return DecodingError.typeMismatch(type, context)
  }

  static func coerce<T>(_ from: ASN1.Integer, at codingPath: [CodingKey]) throws -> T
    where T: BinaryInteger & FixedWidthInteger {
    guard let result = T(exactly: from) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T>(_ from: Decimal, at codingPath: [CodingKey]) throws -> T
    where T: BinaryFloatingPoint & LosslessStringConvertible {
    guard let result = T(from.description) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  static func coerce<T>(_ from: ASN1.Integer, at codingPath: [CodingKey]) throws -> T
    where T: BinaryFloatingPoint & LosslessStringConvertible {
    guard let result = T(from.description) else {
      throw overflow(T.self, value: from, at: codingPath)
    }
    return result
  }

  public static func unbox(_ value: ASN1, as type: Int.Type, decoder: IVD) throws -> Int? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int8.Type, decoder: IVD) throws -> Int8? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int8.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int16.Type, decoder: IVD) throws -> Int16? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int16.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int32.Type, decoder: IVD) throws -> Int32? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int32.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int64.Type, decoder: IVD) throws -> Int64? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int64.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt.Type, decoder: IVD) throws -> UInt? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt8.Type, decoder: IVD) throws -> UInt8? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt8.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt16.Type, decoder: IVD) throws -> UInt16? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt16.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt32.Type, decoder: IVD) throws -> UInt32? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt32.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt64.Type, decoder: IVD) throws -> UInt64? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt64.self)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: BigInt.Type, decoder: IVD) throws -> BigInt? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer: return integer
    case let bitString as BitString:
      if bitString.bytes.isEmpty {
        return BigInt.zero
      }
      var data = Data(count: bitString.bytes.count)
      bitString.copyOctets(into: &data)
      return BigInt(derEncoded: data)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: BigUInt.Type, decoder: IVD) throws -> BigUInt? {
    switch try decode(value, decoder: decoder) {
    case let integer as ASN1.Integer:
      if integer.sign == .minus {
        throw overflow(BigUInt.self, value: integer, at: decoder.codingPath)
      }
      return integer.magnitude
    case let bitString as BitString:
      if bitString.bytes.isEmpty {
        return BigUInt.zero
      }
      var data = Data(count: bitString.bytes.count)
      bitString.copyOctets(into: &data)
      return BigUInt(derEncoded: data)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Float.Type, decoder: IVD) throws -> Float? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return try coerce(number, at: decoder.codingPath)
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Double.Type, decoder: IVD) throws -> Double? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return try coerce(number, at: decoder.codingPath)
    case let integer as ASN1.Integer: return try coerce(integer, at: decoder.codingPath)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Decimal.Type, decoder: IVD) throws -> Decimal? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return number
    case let integer as ASN1.Integer: return Decimal(string: integer.description)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: String.Type, decoder: IVD) throws -> String? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString: return string.storage
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UUID.Type, decoder: IVD) throws -> UUID? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString:
      guard let uuid = UUID(uuidString: string.storage) else {
        throw DecodingError.dataCorruptedError(
          in: decoder,
          debugDescription: "Failed to decode UUID from invalid UUID string"
        )
      }
      return uuid
    case let data as Data:
      if data.count != 16 {
        throw DecodingError.dataCorruptedError(
          in: decoder,
          debugDescription: "Failed to decode UUID from binary data that is not 16 bytes"
        )
      }
      return UUID(uuid: data.withUnsafeBytes { $0.bindMemory(to: uuid_t.self).first ?? nullUUID })
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: URL.Type, decoder: IVD) throws -> URL? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString: return URL(string: string.storage)
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Date.Type, decoder: IVD) throws -> Date? {
    switch try decode(value, decoder: decoder) {
    case let time as AnyTime:
      return time.zonedDate.utcDate
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Data.Type, decoder: IVD) throws -> Data? {
    switch try decode(value, decoder: decoder) {
    case let data as Data: return data
    case let bitString as BitString: return bitString.bytes
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid as Any
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: AnyValue.Type, decoder: IVD) throws -> AnyValue {
    switch value.absolute {
    case .boolean(let value): return .bool(value)
    case .integer(let value): return .integer(value)
    case .bitString(let length, let bytes): return .string(BitString(length: length, bytes: bytes).bitFlagString)
    case .octetString(let value): return .data(value)
    case .null: return .nil
    case .objectIdentifier(let fields): return .array(fields.map(AnyValue.uint64))
    case .real(let value): return .decimal(value)
    case .utf8String(let value): return .string(value)
    case .sequence(let values): return .array(try values.map { try unbox($0, as: AnyValue.self, decoder: decoder) })
    case .set(let values): return .array(try values.map { try unbox($0, as: AnyValue.self, decoder: decoder) })
    case .numericString(let value): return .string(value)
    case .printableString(let value): return .string(value)
    case .teletexString(let value): return .string(value)
    case .videotexString(let value): return .string(value)
    case .ia5String(let value): return .string(value)
    case .utcTime(let value): return .date(value.utcDate)
    case .generalizedTime(let value): return .date(value.utcDate)
    case .graphicString(let value): return .string(value)
    case .visibleString(let value): return .string(value)
    case .generalString(let value): return .string(value)
    case .universalString(let value): return .string(value)
    case .characterString(let value): return .string(value)
    case .bmpString(let value): return .string(value)
    default:
      fatalError("unexpected value")
    }
  }

  public static func valueToUnkeyedValues(_ value: ASN1, decoder: IVD) throws -> UnkeyedValues? {

    guard let decoded = try decode(value, decoder: decoder) else { return nil }

    guard let collection = decoded as? UnkeyedValues else {
      return nil
    }

    decoder.state?.save(container: UnkeyedContainer(backing: collection), forCodingPath: decoder.codingPath)

    return collection
  }

  public static func valueToKeyedValues(_ value: ASN1, decoder: IVD) throws -> KeyedValues? {

    guard let decoded = try decode(value, decoder: decoder) else { return nil }

    guard let structure = decoded as? KeyedValues else {
      return nil
    }

    decoder.state?.save(container: KeyedContainer(backing: structure), forCodingPath: decoder.codingPath)

    return structure
  }

  public static func value(from data: Data, options: Options) throws -> ASN1 {
    let values = try ASN1Serialization.asn1(fromDER: data)
    if values.isEmpty {
      return .null
    }
    if values.count > 1 {
      return .sequence(values)
    }
    else {
      return values[0]
    }
  }

}



extension SchemaState {

  public enum DecodingError: Error {
    case disallowedValue(Any, SchemaError.Context)
    case valueOutOfRange(Any, SchemaError.Context)
    case badValue(Any, SchemaError.Context)
  }

  func decode(_ value: ASN1) throws -> Any? {

    for possibleState in currentPossibleStates {

      guard case .schema(let possibleSchema) = possibleState else {
        if value == .null, case .nothing = possibleState {
          return nil
        }

        continue
      }

      switch possibleSchema {

      case .sequence(let fields):

        guard let values = value.sequenceValue else {
          // try next possible schema
          continue
        }

        var results = OrderedDictionary<String, ASN1>()
        var valueIdx = 0

        for (fieldName, fieldSchema) in fields {
          let possibleValue: ASN1? = valueIdx < values.count ? values[valueIdx] : nil

          guard let value = possibleValue else {
            // No value... assign default (if available)
            results[fieldName] = try fieldSchema.defaultValueEncoded()
            continue
          }

          if let fieldSchemaPossibleTags = fieldSchema.possibleTags, !fieldSchemaPossibleTags.contains(value.anyTag) {
            // Value tag not in schema's possible tags... assign defaul and skip to next field
            results[fieldName] = try fieldSchema.defaultValueEncoded()
            continue
          }

          // matched to possible tags or no possbile tags (aka dynamic or any)... consume value and move next
          results[fieldName] = value
          valueIdx += 1
        }

        // reset scope
        removeScope(forCodingPath: keyStack)

        return results


      case .sequenceOf(_, size: let allowedSize):

        guard let values = value.collectionValue else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(values.count) ?? true else {
          throw DecodingError.valueOutOfRange(values, errorContext("SEQUENCE OF length not allowed by schema"))
        }

        return values


      case .setOf(_, let allowedSize):

        guard let values = value.setValue else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(values.count) ?? true else {
          throw DecodingError.valueOutOfRange(values, errorContext("SET OF length not allowed by schema"))
        }

        return values


      case .null:

        guard value == .null else {
          // try next possible schema
          continue
        }

        return nil


      case .objectIdentifier(allowed: let allowedOids):

        guard let oid = value.objectIdentifierValue else {
          // try next possible schema
          continue
        }

        guard allowedOids?.contains(oid) ?? true else {
          throw DecodingError.disallowedValue(oid, errorContext("OBJECT IDENTIFIER value not allowed by schema"))
        }

        return oid


      case .bitString(size: let allowedSize):

        guard let bitString = value.bitStringValue else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(bitString.length) ?? true else {
          throw DecodingError.valueOutOfRange(value, errorContext("BIT STRING length not allowed by schema"))
        }

        return BitString(length: bitString.length, bytes: bitString.bytes)


      case .octetString(size: let allowedSize):

        guard let data = value.octetStringValue else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(data.count) ?? true else {
          throw DecodingError.valueOutOfRange(value, errorContext("OCTET STRING length not allowed by schema"))
        }

        return data


      case .boolean:

        guard let value = value.booleanValue else {
          // try next possible schema
          continue
        }

        return value


      case .integer(allowed: let allowedValues, default: _):

        guard let value = value.integerValue else {
          // try next possible schema
          continue
        }

        if let allowedValues = allowedValues {
          guard allowedValues.contains(value) else {
            throw DecodingError.disallowedValue(value, errorContext("INTEGER value not allowed by schema"))
          }
        }

        return value


      case .time(kind: let requiredKind):

        guard let time = value.timeValue, requiredKind == time.kind else {
          // try next possible schema
          continue
        }

        return time


      case .string(kind: let requiredKind, size: let requiredSize):

        guard let string = value.stringValue, let kind = string.kind, requiredKind == kind else {
          // try next possible schema
          continue
        }

        guard requiredSize?.contains(string.count) ?? true else {
          throw DecodingError.valueOutOfRange(value, errorContext("\(kind)String length not allowed by schema"))
        }

        return string


      case .real:

        guard let real = value.realValue else {
          // try next possible schema
          continue
        }

        return real


      case .any:
        return value.currentValue


      case .implicit(let schemaTag, in: let schemaTagClass, let implicitSchema):

        guard
          let tagged = value.taggedValue,
          ASN1.Tag.tag(from: schemaTag, in: schemaTagClass, constructed: implicitSchema.isCollection) == tagged.tag
        else {
          // try next possible schema
          continue
        }

        switch implicitSchema {
        case .sequence, .sequenceOf:
          let item = try ASN1DERReader.parseItem(tagged.data, as: ASN1.Tag.sequence.constructed)
          return item.sequenceValue!

        case .setOf:
          let item = try ASN1DERReader.parseItem(tagged.data, as: ASN1.Tag.set.constructed)
          return item.setValue!

        default:
          if tagged.data.isEmpty {
            if let defaultValue = implicitSchema.defaultValue {
              return defaultValue.currentValue
            }
            throw DecodingError.badValue(value, errorContext("Implicit tagged value contains no data"))
          }
          guard let nextPossibleTags = implicitSchema.possibleTags, nextPossibleTags.count == 1 else {
            throw SchemaError.ambiguousImplicitTag(errorContext("Implicit schema is ambiguous"))
          }
          return try ASN1DERReader.parseItem(tagged.data, as: nextPossibleTags[0]).currentValue
        }


      case .explicit(let schemaTag, in: let schemaTagClass, let explicitSchema):

        guard
          let tagged = value.taggedValue,
          ASN1.Tag.tag(from: schemaTag, in: schemaTagClass, constructed: true) == tagged.tag
        else {
          // try next possible schema
          continue
        }

        let items = try ASN1DERReader.parse(data: tagged.data)
        guard items.count == 1 else {
          if items.count == 0, let defaultValue = explicitSchema.defaultValue {
            return defaultValue.currentValue
          }
          throw DecodingError.badValue(value, errorContext("Explicit tagged value contains invalid data"))
        }

        return items[0].currentValue


      case .choiceOf, .optional, .version, .versioned, .type, .dynamic, .nothing:
        fatalError("corrupt schema, should have been expanded")
      }

    }

    throw DecodingError.badValue(
      value.currentValue as Any,
      errorContext("No schemas \(currentPossibleStates) match value")
    )
  }

}


#if canImport(Combine)

  import Combine

  extension ASN1Decoder: TopLevelDecoder {
    public typealias Input = Data
  }

#endif

private let nullUUID = uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
