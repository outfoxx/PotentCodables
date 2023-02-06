//
//  Schema.swift
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


/// ASN.1 schema specification DSL.
///
/// The most common usage of ASN.1 encoding and decoding requires following a schema.
/// ``Schema`` provides a simple DSL to specify ASN.1 schemas that provides the same
/// capabilities as the official ASN.1 syntax.
///
/// For example, the following is the ``Schema`` for RFC-5280's `TBSCertificate`:
/// ```swift
///   let TBSCertificateSchema: Schema =
///     .sequence([
///       "version": .version(.explicit(0, Version)),
///       "serialNumber": CertificateSerialNumber,
///       "signature": AlgorithmIdentifier(SignatureAlgorithms),
///       "issuer": Name,
///       "validity": Validity,
///       "subject": Name,
///       "subjectPublicKeyInfo": SubjectPublicKeyInfo,
///       "issuerUniqueID": .versioned(range: 1...2, .implicit(1, UniqueIdentifier)),
///       "subjectUniqueID": .versioned(range: 1...2, .implicit(2, UniqueIdentifier)),
///       "extensions": .versioned(range: 2...2, .explicit(3, Extensions))
///     ])
/// ```
///
/// When encoding an `Encodable` type to ASN.1, the ``ASN1Encoder`` is initialized with a
/// ``Schema`` to direct its or encoding. Likewise, when decoding a `Decodable` type from ASN.1
/// the ``ASN1Decoder`` is initialized with a ``Schema``.
///
/// Decode an example `TBSCertificate` type using the above schema as follows:
/// ```swift
/// ASNDecoder(schema: TBSCertificateSchema)
///   .decode(TBSCertificate.self, from: data)
/// ```
///
public indirect enum Schema: Equatable, Hashable {

  public typealias DynamicMap = [ASN1: Schema]
  public typealias StructureSequenceMap = OrderedDictionary<String, Schema>

  public enum Size: Equatable, Hashable {
    case min(Int)
    case max(Int)
    case `is`(Int)
    case range(Int, Int)

    public func contains(_ value: Int) -> Bool {
      switch self {
      case .min(let min): return value >= min
      case .max(let max): return value <= max
      case .is(let size): return value == size
      case .range(let min, let max): return value >= min && value <= max
      }
    }

    public static func `in`(_ range: ClosedRange<Int>) -> Size {
      return .range(range.lowerBound, range.upperBound)
    }

  }

  case sequence(StructureSequenceMap = [:])

  case sequenceOf(Schema, size: Size? = nil)
  case setOf(Schema, size: Size? = nil)
  case choiceOf([Schema])

  case any
  case type(Schema)
  case dynamic(unknownTypeSchema: Schema? = nil, DynamicMap)

  case version(Schema)
  case versioned(range: ClosedRange<BigInt>, Schema)

  case optional(Schema)

  case implicit(UInt8, in: ASN1.Tag.Class = .contextSpecific, Schema)
  case explicit(UInt8, in: ASN1.Tag.Class = .contextSpecific, Schema)

  case boolean(default: Bool? = nil)
  case integer(allowed: Swift.Range<BigInt>? = nil, default: BigInt? = nil)
  case real
  case bitString(size: Size? = nil)
  case octetString(size: Size? = nil)
  case objectIdentifier(allowed: Set<OID>? = nil)
  case string(kind: AnyString.Kind, size: Size? = nil)
  case time(kind: AnyTime.Kind)
  case null
  case nothing

  public var possibleTags: [ASN1.AnyTag]? {
    switch self {
    case .sequence, .sequenceOf:
      return [ASN1.Tag.sequence.universal]
    case .setOf:
      return [ASN1.Tag.set.universal]
    case .choiceOf(let schemas):
      return schemas.flatMap { $0.possibleTags ?? [] }
    case .type(let schema):
      return schema.possibleTags
    case .version(let schema):
      return schema.possibleTags
    case .versioned(_, let schema):
      return schema.possibleTags
    case .optional(let schema):
      return schema.possibleTags
    case .implicit(let tag, let tagClass, let schema):
      return [ASN1.Tag.tag(from: tag, in: tagClass, constructed: schema.isCollection)]
    case .explicit(let tag, let tagClass, _):
      return [ASN1.Tag.tag(from: tag, in: tagClass, constructed: true)]
    case .boolean:
      return [ASN1.Tag.boolean.universal]
    case .integer:
      return [ASN1.Tag.integer.universal]
    case .real:
      return [ASN1.Tag.real.universal]
    case .bitString:
      return [ASN1.Tag.bitString.universal]
    case .octetString:
      return [ASN1.Tag.octetString.universal]
    case .objectIdentifier:
      return [ASN1.Tag.objectIdentifier.universal]
    case .string(let kind, _):
      return kind.possibleTags
    case .time(let kind):
      return kind.possibleTags
    case .null:
      return [ASN1.Tag.null.universal]
    case .any, .dynamic, .nothing:
      return nil
    }
  }

  public var defaultValue: ASN1? {
    switch self {
    case .type(let schema): return schema.defaultValue
    case .version(let schema): return schema.defaultValue
    case .versioned(_, let schema): return schema.defaultValue
    case .optional(let schema): return schema.defaultValue
    case .implicit(_, _, let schema): return schema.defaultValue
    case .explicit(_, _, let schema): return schema.defaultValue
    case .boolean(let defaultValue): return defaultValue.map { .boolean($0) }
    case .integer(_, let defaultValue): return defaultValue.map { .integer(BigInt($0)) }
    default: return nil
    }
  }

  public func defaultValueEncoded() throws -> ASN1? {
    guard defaultValue != nil else {
      return nil
    }
    return try SchemaState(initial: unwrapDirectives).encode(nil)
  }

  public var unwrapDirectives: Schema {
    switch self {
    case .type(let schema): return schema.unwrapDirectives
    case .version(let schema): return schema.unwrapDirectives
    case .versioned(range: _, let schema): return schema.unwrapDirectives
    default: return self
    }
  }

  public var isVersioned: Bool {
    guard case .versioned = self else { return false }
    return true
  }

  public var isDynamic: Bool {
    guard case .dynamic = self else { return false }
    return true
  }

  public var isOptional: Bool {
    switch self {
    case .type(let schema): return schema.isOptional
    case .version(let schema): return schema.isOptional
    case .versioned(_, let schema): return schema.isOptional
    case .optional: return true
    case .implicit(_, _, let schema): return schema.isOptional
    case .explicit(_, _, let schema): return schema.isOptional
    default: return false
    }
  }

  public var isBoolean: Bool {
    guard case .boolean = self else { return false }
    return true
  }

  public var isInteger: Bool {
    guard case .integer = self else { return false }
    return true
  }

  public var isReal: Bool {
    guard case .real = self else { return false }
    return true
  }

  public var isBitString: Bool {
    guard case .bitString = self else { return false }
    return true
  }

  public var isOctetString: Bool {
    guard case .octetString = self else { return false }
    return true
  }

  public var isObjectIdentifier: Bool {
    guard case .objectIdentifier = self else { return false }
    return true
  }

  public var isString: Bool {
    guard case .string = self else { return false }
    return true
  }

  public var isTime: Bool {
    guard case .time = self else { return false }
    return true
  }

  public var isNull: Bool {
    guard case .null = self else { return false }
    return true
  }

  public var isSequence: Bool {
    guard case .sequence = self else { return false }
    return true
  }

  public var isSequenceOf: Bool {
    guard case .sequenceOf = self else { return false }
    return true
  }

  public var isSetOf: Bool {
    guard case .setOf = self else { return false }
    return true
  }

  public var isCollection: Bool {
    return isSequence || isSequenceOf || isSetOf
  }

}

extension Schema: CustomStringConvertible {

  public var description: String {
    var output = FormattedOutput()
    switch self {
    case .nothing:
      break

    case .sequence(let fields):
      sequenceDescription(&output, fields)

    case .sequenceOf(let schema, size: let size):
      sequenceOfDescription(&output, size, schema)

    case .setOf(let schema, size: let size):
      setOfDescription(&output, size, schema)

    case .choiceOf(let schemas):
      choiceOfDescription(&output, schemas)

    case .optional(let schema):
      output.write("\(schema.description) OPTIONAL")

    case .implicit(let tag, let inClass, let schema):
      let tagPrefix = inClass != .contextSpecific ? String(describing: inClass).uppercased() : ""
      output.write("[\(tagPrefix)\(tag)] IMPLICIT \(schema.description)")

    case .explicit(let tag, let inClass, let schema):
      let tagPrefix = inClass != .contextSpecific ? String(describing: inClass).uppercased() : ""
      output.write("[\(tagPrefix)\(tag)] EXPLICIT \(schema.description)")

    case .boolean(let def):
      output.write("BOOLEAN")
      if let def = def {
        output.write(" DEFAULT \(String(def).uppercased())")
      }

    case .integer(let allowed, let def):
      integerDescription(&output, allowed, def)

    case .bitString(let size):
      output.write("BIT STRING")
      if let size = size {
        output.write(" (\(size))")
      }

    case .octetString(let size):
      output.write("OCTET STRING")
      if let size = size {
        output.write(" (\(size))")
      }

    case .objectIdentifier(let allowed):
      output.write("OBJECT IDENTIFIER")
      if let allowed = allowed {
        output.write(" { \(allowed.map { $0.description }.sorted().joined(separator: " , ")) }")
      }

    case .real:
      output.write("REAL")

    case .string(let type, let size):
      output.write("\(String(describing: type).uppercased())String")
      if let size = size {
        output.write(" (\(size))")
      }

    case .time(kind: let kind):
      timeDescription(&output, kind)

    case .null:
      output.write("NULL")

    case .any:
      output.write("ANY")

    case .dynamic(let unknownSchema, let map):
      dynamicDescription(&output, map, unknownSchema)

    case .versioned(let versionRange, let versionedSchema):
      output.write(
        "\(versionedSchema.description) -- for version (\(versionRange.lowerBound)..\(versionRange.upperBound))"
      )

    case .type(let schema), .version(let schema):
      output.write(schema.description)
    }

    return output.string
  }

  private func sequenceDescription(_ output: inout FormattedOutput, _ fields: Schema.StructureSequenceMap) {
    output.indented(prefix: "SEQUENCE ::= {", suffix: "\n}") { writer in

      for (field, fieldSchema) in fields {
        writer("\n\(field) \(fieldSchema.description)")
      }

    }
  }

  private func sequenceOfDescription(_ output: inout FormattedOutput, _ size: Schema.Size?, _ schema: Schema) {
    output.indented(prefix: "SEQUENCE ") { writer in

      if let size = size {
        writer("SIZE (\(size)) ")
      }

      writer("OF\n\(schema.description)")
    }
  }

  private func setOfDescription(_ output: inout FormattedOutput, _ size: Schema.Size?, _ schema: Schema) {
    output.indented(prefix: "SET ") { writer in

      if let size = size {
        writer("SIZE (\(size)) ")
      }

      writer("OF\n\(schema.description)")
    }
  }

  private func choiceOfDescription(_ output: inout FormattedOutput, _ schemas: ([Schema])) {
    output.indented(prefix: "CHOICE ::= {", suffix: "\n}") { writer in

      for schema in schemas {
        writer("\n\(schema.description)")
      }
    }
  }

  private func integerDescription(_ output: inout FormattedOutput, _ allowed: Range<BigInt>?, _ def: BigInt?) {
    output.write("INTEGER")
    if let allowed = allowed {
      output.write(" { \(allowed.map { String($0) }.joined(separator: ", ")) }")
    }
    if let def = def {
      output.write(" DEFAULT \(String(def).uppercased())")
    }
  }

  private func timeDescription(_ output: inout FormattedOutput, _ kind: AnyTime.Kind) {
    switch kind {
    case .utc:
      output.write("UTCTime")
    case .generalized:
      output.write("GeneralizedTime")
    }
  }

  private func dynamicDescription(_ output: inout FormattedOutput, _ map: Schema.DynamicMap, _ unknownSchema: Schema?) {
    output.indented(prefix: "DYNAMIC {", suffix: "\n}") { writer in

      for (key, schema) in map {
        writer("\nCASE \(key.unwrapped ?? key) (\(key.tagName)): \(schema.description)")
      }

      if let unknownSchema = unknownSchema {
        writer("\nELSE: \(unknownSchema.description)")
      }
    }
  }

}

private struct FormattedOutput: TextOutputStream {
  var string: String = ""
  private var indent: String = ""

  mutating func write(_ string: String) {
    self.string.append(string.replacingOccurrences(of: "\n", with: "\n\(indent)"))
  }

  mutating func indented(prefix: String = "", suffix: String = "", _ block: ((String) -> Void) -> Void) {
    write(prefix)

    let prevIndent = self.indent
    self.indent.append("  ")

    defer {
      self.indent = prevIndent
      write(suffix)
    }

    block { write($0) }
  }

}

extension Schema.Size: CustomStringConvertible {

  public var description: String {
    switch self {
    case .min(let min): return "\(min)..MAX"
    case .max(let max): return "0..\(max)"
    case .is(let size): return "\(size)"
    case .range(let min, let max): return "\(min)..\(max)"
    }
  }

}

extension AnyString.Kind {

  var possibleTags: [ASN1.AnyTag] {
    switch self {
    case .utf8: return [ASN1.Tag.utf8String.universal]
    case .numeric: return [ASN1.Tag.numericString.universal]
    case .printable: return [ASN1.Tag.printableString.universal]
    case .teletex: return [ASN1.Tag.teletexString.universal]
    case .videotex: return [ASN1.Tag.videotexString.universal]
    case .ia5: return [ASN1.Tag.ia5String.universal]
    case .graphic: return [ASN1.Tag.graphicString.universal]
    case .visible: return [ASN1.Tag.visibleString.universal]
    case .general: return [ASN1.Tag.generalString.universal]
    case .universal: return [ASN1.Tag.universalString.universal]
    case .character: return [ASN1.Tag.characterString.universal]
    case .bmp: return [ASN1.Tag.bmpString.universal]
    }
  }

}

extension AnyTime.Kind {

  var possibleTags: [ASN1.AnyTag] {
    switch self {
    case .utc: return [ASN1.Tag.utcTime.universal]
    case .generalized: return [ASN1.Tag.generalizedTime.universal]
    }
  }

}
