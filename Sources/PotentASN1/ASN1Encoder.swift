//
//  ASN1Encoder.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables


/// `ASN1Encoder` facilitates the encoding of `Encodable` values into ASN1 values.
///
public class ASN1Encoder: ValueEncoder<ASN1, ASN1EncoderTransform>, EncodesToData {

  /// Schema to direct and validate encoded value
  public let schema: Schema

  /// The options set on the top-level encoder.
  public override var options: ASN1EncoderTransform.Options {
    return ASN1EncoderTransform.Options(schema: schema,
                                        keyEncodingStrategy: .useDefaultKeys,
                                        userInfo: userInfo)
  }

  public required init(schema: Schema) {
    self.schema = schema
    super.init()
  }

  public static func encode<T: Encodable & SchemaSpecified>(_ value: T) throws -> Data {
    return try Self(schema: T.asn1Schema).encode(value)
  }

  public static func encodeTree<T: Encodable & SchemaSpecified>(_ value: T) throws -> ASN1 {
    return try Self(schema: T.asn1Schema).encodeTree(value)
  }

}


public struct ASN1EncoderTransform: InternalEncoderTransform, InternalValueSerializer {

  public typealias Value = ASN1
  public typealias Encoder = InternalValueEncoder<Value, Self>

  public struct Options: InternalEncoderOptions {
    public var schema: Schema
    public let keyEncodingStrategy: KeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  public typealias State = SchemaState

  public static var emptyKeyedContainer = ASN1.sequence([])
  public static var emptyUnkeyedContainer = ASN1.sequence([])

  static func encode(_ value: Any?, encoder: Encoder) throws -> ASN1 {
//    print("codingPath =", encoder.codingPath.map { $0.stringValue })
//    print("containers =", encoder.containerTypes, "\n\n")

    if encoder.state == nil {
      encoder.state = try SchemaState(initial: encoder.options.schema)
    }

    let keep = zip(encoder.state.keyStack, encoder.codingPath).prefix { $0.0.stringValue == $0.1.stringValue }.count

    let drop = encoder.state.count - keep
    encoder.state.removeLast(count: drop)

    for key in encoder.codingPath[encoder.state.count...] {
      try encoder.state.step(into: encoder.container(depth: encoder.state.count), key: key)
    }

    return try encoder.state.encode(value)
  }

  public static func boxNil(encoder: Encoder) throws -> ASN1 { try encode(nil, encoder: encoder) }
  public static func box(_ value: Bool, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int8, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int16, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int32, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Int64, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt8, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt16, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt32, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UInt64, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: String, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: URL, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: UUID, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Float, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Double, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Decimal, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Data, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }
  public static func box(_ value: Date, encoder: Encoder) throws -> ASN1 { try encode(value, encoder: encoder) }

  public static func intercepts(_ type: Encodable.Type) -> Bool {
    return
      type is ASN1.Type || type is TaggedValue.Type ||
      type == AnyString.self || type == AnyTime.self ||
      type == BitString.self || type == ObjectIdentifier.self || type == BigInt.self
  }

  public static func box(_ value: Any, interceptedType: Encodable.Type, encoder: Encoder) throws -> ASN1 {

    if let value = value as? ASN1 {
      return value
    }

    return try encode(value, encoder: encoder)
  }

  public static func unkeyedValuesToValue(_ values: [ASN1], encoder: Encoder) throws -> ASN1 {

    return try encode(values, encoder: encoder)
  }

  public static func keyedValuesToValue(_ values: [String: ASN1], encoder: Encoder) throws -> ASN1 {

    return try encode(values, encoder: encoder)
  }

  public static func data(from value: ASN1, options: Options) throws -> Data {
    return try ASN1Serialization.der(from: value)
  }

  private static func doubleFrom(_ decimal: Decimal, _ encoder: Encoder) throws -> Double {
    guard let value = Double(decimal.description) else {
      throw Swift.EncodingError.invalidValue(decimal, .init(codingPath: encoder.codingPath,
                                                            debugDescription: ""))
    }
    return value
  }

}


extension SchemaState {

  public enum EncodingError: Error {
    case disallowedValue(Any, SchemaError.Context)
    case valueOutOfRange(Any, SchemaError.Context)
    case badValue(Any, SchemaError.Context)
  }

  mutating func encode(_ value: Any?) throws -> ASN1 {

    guard let encoded = try tryEncode(value) else {
      throw EncodingError.badValue(value as Any, errorContext("No schemas \(currentPossibleStates) match value"))
    }

    return encoded
  }

  private mutating func tryEncode(_ value: Any?) throws -> ASN1? {

    for possibleState in currentPossibleStates {

      guard case .schema(let possibleSchema) = possibleState else {
        if value == nil, case .nothing = possibleState {
          return nil
        }

        continue
      }

      switch possibleSchema {

      case .sequence(let fields):

        guard let values = value as? [String: ASN1] else {
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

        guard let value = value as? Bool else {
          // try next possible schema
          continue
        }

        return value == defaultValue ? .default(.boolean(value)) : .boolean(value)


      case .integer(allowed: let allowedValues, default: let defaultValue):

        func check(_ int: BigInt) throws -> ASN1 {
          if let allowedValues = allowedValues {
            guard let test = int.integerValue, allowedValues.contains(test) else {
              throw EncodingError.disallowedValue(value!, errorContext("INTEGER value not allowed by schema"))
            }
          }
          if let defaultValue = defaultValue, int.integerValue == defaultValue {
            return .default(.integer(int))
          }
          return .integer(int)
        }

        switch value {
        case let int as BigInt: return try check(int)
        case let int as Int: return try check(BigInt(int))
        case let uint as UInt: return try check(BigInt(uint))
        default:
          // try next possible schema
          continue
        }


      case .time(kind: let requiredKind):

        func asn1Time(_ date: Date) -> ASN1 {
          switch requiredKind {
          case .generalized: return .generalizedTime(date)
          case .utc: return .utcTime(date)
          }
        }

        switch value {
        case let date as Date:
          return asn1Time(date)

        case let time as AnyTime:

          let kind = time.kind ?? requiredKind
          guard requiredKind == kind else {
            // try next possible schema
            continue
          }

          return asn1Time(time.storage)


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
        guard let encoded = value as? ASN1 else {
          throw EncodingError.badValue(value as Any, errorContext("ANY requires value to be an ASN1 instance"))
        }
        return encoded


      case .implicit(let tag, in: let tagClass, let implicitSchema):
        var implicitSchemaState = try SchemaState(initial: implicitSchema)
        var source: Any?
        if let taggedValue = value as? TaggedValue {
          let (tvTag, tvValue) = taggedValue.tagAndValue
          guard tvTag == tag else {
            // try next possible schema
            continue
          }
          source = tvValue
        }
        else {
          source = value
        }
        guard let encoded = try implicitSchemaState.tryEncode(source) else {
          // try next possible schema
          continue
        }
        let encodedData = try DERReader.parseTagged(data: DERWriter.write(encoded)).data
        return .tagged(ASN1.Tag.tag(from: tag, in: tagClass), encodedData)


      case .explicit(let tag, in: let tagClass, let explicitSchema):
        var explicitSchemaState = try SchemaState(initial: explicitSchema)
        var source: Any?
        if let taggedValue = value as? TaggedValue {
          let (tvTag, tvValue) = taggedValue.tagAndValue
          guard tvTag == tag else {
            // try next possible schema
            continue
          }
          source = tvValue
        }
        else {
          source = value
        }
        guard let encoded = try explicitSchemaState.tryEncode(source) else {
          continue
        }
        let encodedData = try DERWriter.write(encoded)
        return .tagged(ASN1.Tag.structuredTag(from: tag, in: tagClass), encodedData)


      case .choiceOf, .optional, .version, .versioned, .type, .dynamic:
        fatalError("corrupt schema, should have been expanded")
      }

    }

    return nil
  }

}
