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
import PotentCodables


/// `ASN1Decoder` facilitates the decoding of ASN1 into semantic `Decodable` types.
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

  public required init(schema: Schema) {
    self.schema = schema
    super.init()
  }

  public static func decode<T: Decodable & SchemaSpecified>(_ type: T.Type, from data: Data) throws -> T {
    return try Self(schema: T.asn1Schema).decode(type, from: data)
  }

  public static func decodeTree<T: Decodable & SchemaSpecified>(_ type: T.Type, from asn1: ASN1) throws -> T {
    return try Self(schema: T.asn1Schema).decodeTree(type, from: asn1)
  }

}


public struct ASN1DecoderTransform: InternalDecoderTransform, InternalValueDeserializer {

  public typealias Value = ASN1
  public typealias Decoder = InternalValueDecoder<Value, Self>
  public typealias State = SchemaState

  public static let nilValue = ASN1.null

  /// Options set on the top-level decoder to pass down the decoding hierarchy.
  public struct Options: InternalDecoderOptions {
    public let schema: Schema
    public let keyDecodingStrategy: KeyDecodingStrategy
    public let userInfo: [CodingUserInfoKey: Any]
  }

  static func decode(_ value: ASN1, decoder: Decoder) throws -> Any? {
//    print("codingPath =", decoder.codingPath.map { $0.stringValue })

    if decoder.state == nil {
      decoder.state = try SchemaState(initial: decoder.options.schema)
    }

    let keep = zip(decoder.state.keyStack, decoder.codingPath).prefix { $0.0.stringValue == $0.1.stringValue }.count

    let drop = decoder.state.count - keep
    decoder.state.removeLast(count: drop)

    for key in decoder.codingPath[decoder.state.count...] {
      guard let container = decoder.state.container(forCodingPath: decoder.state.keyStack) else {
        fatalError("container should already be cached")
      }
      try decoder.state.step(into: container, key: key)
    }

    return try decoder.state.decode(value)
  }

  /// Returns the given value unboxed from a container.
  public static func unbox(_ value: ASN1, as type: Bool.Type, decoder: Decoder) throws -> Bool? {
    switch try decode(value, decoder: decoder) {
    case let bool as Bool: return bool
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  static func overflow(_ type: Any.Type, value: Any, at codingPath: [CodingKey]) -> Error {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(value) overflows \(type)")
    return DecodingError.typeMismatch(type, context)
  }

  static func coerce<T>(_ from: BigInt, at codingPath: [CodingKey]) throws -> T
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

  public static func unbox(_ value: ASN1, as type: Int.Type, decoder: Decoder) throws -> Int? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int8.Type, decoder: Decoder) throws -> Int8? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int8.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int16.Type, decoder: Decoder) throws -> Int16? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int16.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int32.Type, decoder: Decoder) throws -> Int32? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int32.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Int64.Type, decoder: Decoder) throws -> Int64? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(Int64.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt.Type, decoder: Decoder) throws -> UInt? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt8.Type, decoder: Decoder) throws -> UInt8? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt8.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt16.Type, decoder: Decoder) throws -> UInt16? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt16.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt32.Type, decoder: Decoder) throws -> UInt32? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt32.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UInt64.Type, decoder: Decoder) throws -> UInt64? {
    switch try decode(value, decoder: decoder) {
    case let integer as BigInt: return try coerce(integer, at: decoder.codingPath)
    case let bitString as BitString: return bitString.integer(UInt64.self)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Float.Type, decoder: Decoder) throws -> Float? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return try coerce(number, at: decoder.codingPath)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Double.Type, decoder: Decoder) throws -> Double? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return try coerce(number, at: decoder.codingPath)
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Decimal.Type, decoder: Decoder) throws -> Decimal? {
    switch try decode(value, decoder: decoder) {
    case let number as Decimal: return number
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: String.Type, decoder: Decoder) throws -> String? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString: return string.storage
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: UUID.Type, decoder: Decoder) throws -> UUID? {
    switch try decode(value, decoder: decoder) {
    case let string as AnyString: return UUID(uuidString: string.storage)
    case let data as Data where data.count == 16:
      return UUID(uuid: data.withUnsafeBytes { $0.bindMemory(to: uuid_t.self).first ?? UUID_NULL })
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Date.Type, decoder: Decoder) throws -> Date? {
    switch try decode(value, decoder: decoder) {
    case let date as Date: return date
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func unbox(_ value: ASN1, as type: Data.Type, decoder: Decoder) throws -> Data? {
    switch try decode(value, decoder: decoder) {
    case let data as Data: return data
    case let bitString as BitString: return bitString.bytes
    case .none: return nil
    case let invalid:
      throw DecodingError.typeMismatch(
        at: decoder.codingPath,
        expectation: type,
        reality: invalid!
      )
    }
  }

  public static func intercepts(_ type: Decodable.Type) -> Bool {
    return
      type == ASN1.self || type is TaggedValue.Type ||
      type == AnyString.self || type == AnyTime.self ||
      type == BitString.self || type == ObjectIdentifier.self || type == BigInt.self
  }

  public static func unbox(_ value: ASN1, interceptedType: Decodable.Type, decoder: Decoder) throws -> Any? {
    if interceptedType == ASN1.self {
      return value
    }

    guard let decoded = try decode(value, decoder: decoder) else { return nil }
    if interceptedType == BigInt.self {
      guard let int = decoded as? BigInt else {
        throw DecodingError.typeMismatch(
          at: decoder.codingPath,
          expectation: interceptedType,
          reality: decoded
        )
      }
      return int
    }
    else if interceptedType == AnyString.self {
      guard let string = decoded as? AnyString else {
        throw DecodingError.typeMismatch(
          at: decoder.codingPath,
          expectation: interceptedType,
          reality: decoded
        )
      }
      return string
    }
    else if interceptedType == AnyTime.self {
      guard let time = decoded as? AnyTime else {
        throw DecodingError.typeMismatch(
          at: decoder.codingPath,
          expectation: interceptedType,
          reality: decoded
        )
      }
      return time
    }
    else if interceptedType == BitString.self {
      switch decoded {
      case let bitString as BitString: return bitString
      case let data as Data: return BitString(length: data.count * 8, bytes: data)
      default:
        throw DecodingError.typeMismatch(
          at: decoder.codingPath,
          expectation: interceptedType,
          reality: decoded
        )
      }
    }
    else if interceptedType == ObjectIdentifier.self {
      guard let oid = decoded as? ObjectIdentifier else {
        throw DecodingError.typeMismatch(
          at: decoder.codingPath,
          expectation: interceptedType,
          reality: decoded
        )
      }
      return oid
    }
    else if let taggedValueType = interceptedType as? TaggedValue.Type {
      return taggedValueType.init(tag: value.anyTag, value: decoded)
    }
    else {
      fatalError("Unhandled type")
    }
  }

  public static func valueToUnkeyedValues(_ value: ASN1, decoder: Decoder) throws -> [ASN1]? {

    guard let decoded = try decode(value, decoder: decoder) else { return nil }

    guard let collection = decoded as? [ASN1] else {
      fatalError()
    }

    decoder.state.save(container: UnkeyedContainer(backing: collection), forCodingPath: decoder.codingPath)

    return collection
  }

  public static func valueToKeyedValues(_ value: ASN1, decoder: Decoder) throws -> [String: ASN1]? {

    guard let decoded = try decode(value, decoder: decoder) else { return nil }

    guard let structure = decoded as? [String: ASN1] else {
      fatalError()
    }

    decoder.state.save(container: KeyedContainer(backing: structure), forCodingPath: decoder.codingPath)

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

  mutating func decode(_ value: ASN1) throws -> Any? {

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

        var results = [String: ASN1]()
        var valueIdx = 0

        for (fieldName, fieldSchema) in fields {
          let possibleValue: ASN1? = valueIdx < values.count ? values[valueIdx] : nil

          guard let value = possibleValue else {
            // No value... asign default (if available)
            if fieldSchema.defaultValue != nil {
              var fieldSchemaState = try SchemaState(initial: fieldSchema.unwrapDirectives)
              results[fieldName] = try fieldSchemaState.encode(nil)
            }
            continue
          }

          if let fieldSchemaPossibleTags = fieldSchema.possibleTags, !fieldSchemaPossibleTags.contains(value.anyTag) {
            // No value... assign default (if available)
            if fieldSchema.defaultValue != nil {
              var fieldSchemaState = try SchemaState(initial: fieldSchema.unwrapDirectives)
              results[fieldName] = try fieldSchemaState.encode(nil)
            }
            // value tag not in schema's possible tags... skip to next field and try value again
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

        guard let oid = value.objectIdentifierValue.map({ ObjectIdentifier($0) }) else {
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

        guard let (date, kind) = value.timeValue, requiredKind == kind else {
          // try next possible schema
          continue
        }

        return AnyTime(date, kind: kind)


      case .string(kind: let requiredKind, size: let requiredSize):

        guard let (string, kind) = value.stringValue, requiredKind == kind else {
          // try next possible schema
          continue
        }

        guard requiredSize?.contains(string.count) ?? true else {
          throw DecodingError.valueOutOfRange(value, errorContext("\(kind)String length not allowed by schema"))
        }

        return AnyString(string, kind: kind)


      case .real:

        guard let real = value.realValue else {
          // try next possible schema
          continue
        }

        return real


      case .any:
        return value.unwrapped


      case .implicit(let schemaTag, in: let schemaTagClass, let implicitSchema):

        guard let (tag, bytes) = value.taggedValue, ASN1.Tag.tag(
          from: schemaTag,
          in: schemaTagClass,
          constructed: implicitSchema.isCollection
        ) == tag else {
          // try next possible schema
          continue
        }

        switch implicitSchema {
        case .sequence, .sequenceOf:
          let item = try DERReader.parseItem(bytes, as: ASN1.Tag.sequence.constructed)
          return item.sequenceValue!

        case .setOf:
          let item = try DERReader.parseItem(bytes, as: ASN1.Tag.set.constructed)
          return item.setValue!

        default:
          guard let nextPossibleTags = implicitSchema.possibleTags, nextPossibleTags.count == 1 else {
            throw SchemaError.ambiguousImplicitTag(errorContext("Implicit schema is ambiguous"))
          }

          return try DERReader.parseItem(bytes, as: nextPossibleTags[0]).unwrapped
        }


      case .explicit(let schemaTag, in: let schemaTagClass, let explicitSchema):

        guard let (tag, bytes) = value.taggedValue,
              ASN1.Tag.tag(from: schemaTag, in: schemaTagClass, constructed: true) == tag
        else {
          // try next possible schema
          continue
        }

        let items = try DERReader.parse(data: bytes)
        guard items.count == 1 else {
          if items.count == 0, let defaultValue = explicitSchema.defaultValue {
            return defaultValue.unwrapped
          }
          throw DecodingError.badValue(value, errorContext("Explicit tagged value contains invalid data"))
        }

        return items[0].unwrapped


      case .choiceOf, .optional, .version, .versioned, .type, .dynamic, .nothing:
        fatalError("corrupt schema, should have been expanded")
      }

    }

    throw DecodingError.badValue(
      value.unwrapped as Any,
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
