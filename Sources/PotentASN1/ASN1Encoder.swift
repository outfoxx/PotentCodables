//
//  ASN1Encoder.swift
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


/// Encodes `Encodable` types into ASN.1/DER data or ``ASN1`` value trees using a ``Schema``.
///
/// When encoding an `Encodable` value to ASN.1, the ``ASN1Encoder`` is initialized with a
/// ``Schema`` to direct encoding.
///
/// Encode an example `TBSCertificate` type with an associated `TBSCertificateSchema` as follows:
/// ```swift
/// ASNEncoder(schema: TBSCertificateSchema)
///   .encode(someCertificate)
/// ```
///
/// See ``Schema`` to learn about defining ASN.1 schemas.
///
/// If the example `TBSCertificate` adopts the ``SchemaSpecified`` protocol, static utility
/// functions can be used to encode values without having to initialize the encoder with a
/// schema. This also ensures the correct schema is always provided to the encoder.
/// ```swift
/// ASN1Encoder.encode(someCertificate)
/// ```
///
public class ASN1Encoder: ValueEncoder<ASN1, ASN1EncoderTransform>, EncodesToData {

  /// Schema to direct and validate encoded value
  public let schema: Schema

  /// The options set on the top-level encoder.
  override public var options: ASN1EncoderTransform.Options {
    return ASN1EncoderTransform.Options(
      schema: schema,
      keyEncodingStrategy: .useDefaultKeys,
      userInfo: userInfo
    )
  }

  /// Initialize encoder with a specified ``Schema``.
  ///
  /// - Parameters schema: 
  public required init(schema: Schema) {
    self.schema = schema
    super.init()
  }

  /// Encode an `Encodeable` & ``SchemaSpecified`` value to ASN.1/DER encoded data.
  ///
  /// - Parameters value: Value to encode.
  /// - Throws: `DecodingError` or ``ASN1DERWriter/Error``.
  ///
  public static func encode<T: Encodable & SchemaSpecified>(_ value: T) throws -> Data {
    return try Self(schema: T.asn1Schema).encode(value)
  }

  /// Encode an `Encodeable` & ``SchemaSpecified`` value to an ``ASN1`` value tree.
  ///
  /// - Parameters value: Value to encode.
  /// - Throws: `DecodingError` or ``ASN1DERWriter/Error``.
  ///
  public static func encodeTree<T: Encodable & SchemaSpecified>(_ value: T) throws -> ASN1 {
    return try Self(schema: T.asn1Schema).encodeTree(value)
  }

}


public struct ASN1EncoderTransform: InternalEncoderTransform, InternalValueSerializer {

  public typealias Value = ASN1

  public struct Options: InternalEncoderOptions {
    public var schema: Schema
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public typealias State = SchemaState

  public static var emptyKeyedContainer = ASN1.sequence([])
  public static var emptyUnkeyedContainer = ASN1.sequence([])

  static func encode(_ value: Any?, encoder: IVE) throws -> ASN1 {

    let state = try encoder.state ?? SchemaState(initial: encoder.options.schema)
    encoder.state = state

    let keep = zip(state.keyStack, encoder.codingPath).prefix { $0.0.stringValue == $0.1.stringValue }.count

    let drop = state.count - keep
    state.removeLast(count: drop)

    for key in encoder.codingPath[state.count...] {
      try state.step(into: encoder.container(depth: state.count), key: key)
    }

    return try state.encode(value)
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

  public static func intercepts(_ type: Encodable.Type) -> Bool {
    return interceptedTypes.contains { $0 == type } || type is Tagged.Type
  }

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: IVE) throws -> ASN1 {
    var value: Any? = value
    if let anyValue = value as? AnyValue {
      return try box(anyValue, encoder: encoder)
    }
    if let uuid = value as? UUID {
      value = uuid.uuidString
    }
    else if let url = value as? URL {
      value = url.absoluteString
    }
    return try encode(value, encoder: encoder)
  }

  public static func boxNil(encoder: IVE) throws -> ASN1 { try encode(nil, encoder: encoder) }
  public static func box(_ value: Bool, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int8, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int16, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int32, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int64, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt8, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt16, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt32, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt64, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Float, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Double, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: String, encoder: IVE) throws -> ASN1 { try encode(value, encoder: encoder) }

  public static func box(_ value: AnyValue, encoder: IVE) throws -> ASN1 {
    switch value {
    case .nil: return try encode(nil, encoder: encoder)
    case .bool(let value): return try encode(value, encoder: encoder)
    case .string(let value): return try encode(value, encoder: encoder)
    case .int8(let value): return try encode(value, encoder: encoder)
    case .int16(let value): return try encode(value, encoder: encoder)
    case .int32(let value): return try encode(value, encoder: encoder)
    case .int64(let value): return try encode(value, encoder: encoder)
    case .uint8(let value): return try encode(value, encoder: encoder)
    case .uint16(let value): return try encode(value, encoder: encoder)
    case .uint32(let value): return try encode(value, encoder: encoder)
    case .uint64(let value): return try encode(value, encoder: encoder)
    case .integer(let value): return try encode(value, encoder: encoder)
    case .unsignedInteger(let value): return try encode(value, encoder: encoder)
    case .float16(let value): return try encode(Double(value), encoder: encoder)
    case .float(let value): return try encode(value, encoder: encoder)
    case .double(let value): return try encode(value, encoder: encoder)
    case .decimal(let value): return try encode(value, encoder: encoder)
    case .data(let value): return try encode(value, encoder: encoder)
    case .url(let value): return try encode(value.absoluteString, encoder: encoder)
    case .uuid(let value): return try encode(value.uuidString, encoder: encoder)
    case .date(let value): return try encode(value, encoder: encoder)
    case .array(let value):
      return try encoder.subEncode { subEncoder in

        let container = subEncoder.unkeyedContainer()

        for (index, element) in value.enumerated() {
          try subEncoder.withCodingKey(AnyCodingKey(intValue: index)) {
            container.append(try box(element, encoder: encoder))
          }
        }

      } ?? .null
    case .dictionary(let value):
      return try encoder.subEncode { subEncoder in

        let container = subEncoder.keyedContainer()

        for (key, value) in value {
          try subEncoder.withCodingKey(AnyCodingKey(stringValue: key.stringValue!)) {
            container[key.stringValue!] = try box(value, encoder: encoder)
          }
        }

      } ?? .null
    }
  }

  public static func unkeyedValuesToValue(_ values: UnkeyedValues, encoder: IVE) throws -> ASN1 {
    return try encode(Array(values), encoder: encoder)
  }

  public static func keyedValuesToValue(_ values: KeyedValues, encoder: IVE) throws -> ASN1 {
    return try encode(values, encoder: encoder)
  }

  public static func data(from value: ASN1, options: Options) throws -> Data {
    return try ASN1Serialization.der(from: value)
  }

}


extension SchemaState {

  public enum EncodingError: Error {
    case disallowedValue(Any, SchemaError.Context)
    case valueOutOfRange(Any, SchemaError.Context)
    case badValue(Any, SchemaError.Context)
  }

  func encode(_ value: Any?) throws -> ASN1 {

    guard let encoded = try tryEncode(value) else {
      let stateOptions = currentPossibleStates.map { $0.description }.joined(separator: " or ")
      throw EncodingError.badValue(value as Any, errorContext("No schemas match value: \(stateOptions)"))
    }

    return encoded
  }

  private func tryEncode(_ value: Any?) throws -> ASN1? {

    for possibleState in currentPossibleStates {

      guard case .schema(let possibleSchema) = possibleState else {
        if value == nil, case .nothing = possibleState {
          return nil
        }

        continue
      }

      switch possibleSchema {

      case .sequence(let fields):

        guard let values = value as? OrderedDictionary<String, ASN1> else {
          // try next possible schema
          continue
        }

        var fieldValues = [ASN1]()

        for (fieldName, fieldSchema) in fields {

          guard let fieldValue = values[fieldName] else {
            try step(into: nil, key: AnyCodingKey(stringValue: fieldName, intValue: nil))
            defer { removeLast() }

            if let value = try tryEncode(nil) {
              fieldValues.append(value)
            }

            continue
          }

          /// HACK: Exclude explicitly/implicitly tagged default values... this should be handled
          /// in a more elegant fashion that is more explicit about what is intended.
          if fieldValue.taggedValue?.data.isEmpty == true, fieldSchema.defaultValue != nil {
            continue
          }

          fieldValues.append(fieldValue)
        }

        // reset scope
        removeScope(forCodingPath: keyStack)

        return .sequence(fieldValues)


      case .sequenceOf(_, size: let allowedSize):

        guard let values = value as? [ASN1] else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(values.count) ?? true else {
          throw EncodingError.valueOutOfRange(values, errorContext("SEQUENCE OF length not allowed by schema"))
        }

        return .sequence(values)


      case .setOf(_, let allowedSize):

        guard let values = value as? [ASN1] else {
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(values.count) ?? true else {
          throw EncodingError.valueOutOfRange(values, errorContext("SET OF length not allowed by schema"))
        }

        return .set(values)


      case .null:

        guard value == nil else {
          // try next possible schema
          continue
        }

        return .null


      case .objectIdentifier(allowed: let allowedOids):

        guard let oid = value as? ObjectIdentifier else {
          // try next possible schema
          continue
        }

        guard allowedOids?.contains(oid) ?? true else {
          throw EncodingError.disallowedValue(oid, errorContext("OBJECT IDENTIFIER value not allowed by schema"))
        }

        return .objectIdentifier(oid.fields)


      case .bitString(size: let allowedSize):
        let length: Int
        let bytes: Data

        switch value {
        case let bitString as BitString:
          length = bitString.length
          bytes = bitString.bytes

        case let data as Data:
          length = data.count * 8
          bytes = data

        case let int as Int8:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as Int16:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as Int32:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as Int64:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as UInt8:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as UInt16:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as UInt32:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        case let int as UInt64:
          let bitString = BitString(bitPattern: int)
          length = bitString.length
          bytes = bitString.bytes

        default:
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(length) ?? true else {
          throw EncodingError.valueOutOfRange(value!, errorContext("BIT STRING length not allowed by schema"))
        }

        return .bitString(length, bytes)


      case .octetString(size: let allowedSize):
        let octets: Data

        switch value {
        case let data as Data:
          octets = data

        case let int as Int8:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as Int16:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as Int32:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as Int64:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as UInt8:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as UInt16:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as UInt32:
          octets = withUnsafeBytes(of: int) { Data($0) }

        case let int as UInt64:
          octets = withUnsafeBytes(of: int) { Data($0) }

        default:
          // try next possible schema
          continue
        }

        guard allowedSize?.contains(octets.count) ?? true else {
          throw EncodingError.valueOutOfRange(value!, errorContext("OCTET STRING length not allowed by schema"))
        }

        return .octetString(octets)


      case .boolean(default: let defaultValue):

        guard let boolValue = value as? Bool else {
          if value == nil, let defaultValue = defaultValue {
            return .default(.boolean(defaultValue))
          }
          // try next possible schema
          continue
        }

        return boolValue == defaultValue ? .default(.boolean(boolValue)) : .boolean(boolValue)


      case .integer(allowed: let allowedValues, default: let defaultValue):

        func check(_ int: ASN1.Integer) throws -> ASN1 {
          if let allowedValues = allowedValues {
            guard allowedValues.contains(int) else {
              throw EncodingError.disallowedValue(value!, errorContext("INTEGER value not allowed by schema"))
            }
          }
          if let defaultValue = defaultValue, int == defaultValue {
            return .default(.integer(int))
          }
          return .integer(int)
        }

        switch value {
        case let int as ASN1.Integer: return try check(int)
        case let int as BigUInt: return try check(ASN1.Integer(int))
        case let int as Int8: return try check(ASN1.Integer(int))
        case let int as Int16: return try check(ASN1.Integer(int))
        case let int as Int32: return try check(ASN1.Integer(int))
        case let int as Int64: return try check(ASN1.Integer(int))
        case let int as Int: return try check(ASN1.Integer(int))
        case let uint as UInt8: return try check(ASN1.Integer(uint))
        case let uint as UInt16: return try check(ASN1.Integer(uint))
        case let uint as UInt32: return try check(ASN1.Integer(uint))
        case let uint as UInt64: return try check(ASN1.Integer(uint))
        case let uint as UInt: return try check(ASN1.Integer(uint))
        default:
          if let defaultValue = defaultValue {
            return .default(.integer(ASN1.Integer(defaultValue)))
          }
          // try next possible schema
          continue
        }


      case .time(kind: let requiredKind):

        func asn1Time(_ zonedDate: ZonedDate) -> ASN1 {
          switch requiredKind {
          case .generalized: return .generalizedTime(zonedDate)
          case .utc: return .utcTime(zonedDate)
          }
        }

        switch value {

        case let date as Date:
          return asn1Time(ZonedDate(date: date, timeZone: .utc))

        case let zonedDate as ZonedDate:
          return asn1Time(zonedDate)

        case let time as AnyTime:

          let kind = time.kind ?? requiredKind
          guard requiredKind == kind else {
            // try next possible schema
            continue
          }

          return asn1Time(time.zonedDate)

        default:
          // try next possible schema
          continue
        }


      case .string(kind: let requiredKind, size: let requiredSize):

        func asn1String(_ string: String) throws -> ASN1 {

          guard requiredSize?.contains(string.count) ?? true else {
            throw EncodingError.valueOutOfRange(value!, errorContext("String length not allowed by schema"))
          }

          switch requiredKind {
          case .utf8: return .utf8String(string)
          case .numeric: return .numericString(string)
          case .printable: return .printableString(string)
          case .teletex: return .teletexString(string)
          case .videotex: return .videotexString(string)
          case .ia5: return .ia5String(string)
          case .graphic: return .graphicString(string)
          case .visible: return .visibleString(string)
          case .general: return .generalString(string)
          case .universal: return .universalString(string)
          case .character: return .characterString(string)
          case .bmp: return .bmpString(string)
          }
        }

        switch value {
        case let string as String:
          return try asn1String(string)

        case let string as AnyString:

          let kind = string.kind ?? requiredKind
          guard requiredKind == kind else {
            // try next possible schema
            continue
          }

          return try asn1String(string.storage)


        default:
          // try next possible schema
          continue
        }


      case .real:
        switch value {
        case let value as Decimal: return .real(value)
        case let value as Float: return .real(Decimal(Double(value)))
        case let value as Double: return .real(Decimal(value))
        default:
          // try next possible schema
          continue
        }


      case .any:
        switch value {
        case nil: return .null
        case let value as ASN1: return value
        default:
          throw EncodingError.badValue(value as Any, errorContext("ANY requires value to be an ASN1 instance"))
        }


      case .implicit(let tag, in: let tagClass, let implicitSchema):
        let implicitSchemaState = try SchemaState(initial: implicitSchema)
        let encoded: ASN1
        if let taggedValue = value as? Tagged {
          guard taggedValue.tag == tag else {
            // try next possible schema
              continue
          }
          encoded = try taggedValue.encode(schema: implicitSchema)
        }
        else {
          guard let value = try implicitSchemaState.tryEncode(value) else {
            // try next possible schema
            continue
          }
          encoded = value
        }
        let encodedData = try ASN1DERReader.parseTagged(data: ASN1DERWriter.write(encoded))?.data ?? Data()
        return .tagged(ASN1.Tag.tag(from: tag, in: tagClass, constructed: implicitSchema.isCollection), encodedData)


      case .explicit(let tag, in: let tagClass, let explicitSchema):
        let explicitSchemaState = try SchemaState(initial: explicitSchema)
        let encoded: ASN1
        if let taggedValue = value as? Tagged {
          guard taggedValue.tag == tag else {
            // try next possible schema
            continue
          }
          encoded = try taggedValue.encode(schema: explicitSchema)
        }
        else {
          guard let value = try explicitSchemaState.tryEncode(value) else {
            continue
          }
          encoded = value
        }
        let encodedData = try ASN1DERWriter.write(encoded)
        return .tagged(ASN1.Tag.tag(from: tag, in: tagClass, constructed: true), encodedData)


      case .choiceOf, .optional, .version, .versioned, .type, .dynamic, .nothing:
        fatalError("corrupt schema, should have been expanded")
      }

    }

    return nil
  }

}


#if canImport(Combine)

  import Combine

  extension ASN1Encoder: TopLevelEncoder {
    public typealias Output = Data
  }

#endif
