//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/14/19.
//

import Foundation
import PotentCodables


/// Allows encoding _any_ ASN.1 string value while controlling the specific ASN.1 type.
///
public struct AnyString: Equatable, Hashable {


  public enum Kind: Int, Equatable, Hashable, Codable {
    case utf8
    case numeric
    case printable
    case teletex
    case videotex
    case ia5
    case graphic
    case visible
    case general
    case universal
    case character
    case bmp
  }


  public var kind: Kind?
  public var storage: String

  public init(_ value: String, kind: Kind) {
    self.kind = kind
    self.storage = value
  }

}


extension AnyString: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.storage = try container.decode(String.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(storage)
  }

}


extension AnyString: StringProtocol {

  public typealias UTF8View = String.UTF8View
  public typealias UTF16View = String.UTF16View
  public typealias UnicodeScalarView = String.UnicodeScalarView

  public init(stringLiteral value: String) {
    self.kind = nil
    self.storage = value
  }

  public init(_ value: String) {
    self.kind = nil
    self.storage = value
  }

  public init<C, Encoding>(decoding codeUnits: C, as sourceEncoding: Encoding.Type) where C : Collection, Encoding : _UnicodeEncoding, C.Element == Encoding.CodeUnit {
    kind = nil
    storage = String(decoding: codeUnits, as: sourceEncoding)
  }

  public init(cString nullTerminatedUTF8: UnsafePointer<CChar>) {
    kind = nil
    storage = String(cString: nullTerminatedUTF8)
  }

  public init<Encoding>(decodingCString nullTerminatedCodeUnits: UnsafePointer<Encoding.CodeUnit>, as sourceEncoding: Encoding.Type) where Encoding : _UnicodeEncoding {
    kind = nil
    storage = String(decodingCString: nullTerminatedCodeUnits, as: sourceEncoding)
  }

  public func uppercased() -> String {
    return storage.uppercased()
  }

  public func lowercased() -> String {
    return storage.lowercased()
  }

  public var utf8: String.UTF8View {
    return storage.utf8
  }

  public var utf16: String.UTF16View {
    return storage.utf16
  }

  public var unicodeScalars: String.UnicodeScalarView {
    return storage.unicodeScalars
  }

  public func withCString<Result>(_ body: (UnsafePointer<CChar>) throws -> Result) rethrows -> Result {
    return try storage.withCString(body)
  }

  public func withCString<Result, Encoding>(encodedAs targetEncoding: Encoding.Type, _ body: (UnsafePointer<Encoding.CodeUnit>) throws -> Result) rethrows -> Result where Encoding : _UnicodeEncoding {
    return try storage.withCString(encodedAs: targetEncoding, body)
  }

  public subscript(position: String.Index) -> Character {
    return storage[position]
  }

  public func index(before i: String.Index) -> String.Index {
    return storage.index(before: i)
  }

  public func index(after i: String.Index) -> String.Index {
    return storage.index(after: i)
  }

  public var startIndex: String.Index {
    return storage.startIndex
  }

  public var endIndex: String.Index {
    return storage.endIndex
  }

  public mutating func write(_ string: String) {
    storage.write(string)
  }

  public func write<Target>(to target: inout Target) where Target : TextOutputStream {
    storage.write(to: &target)
  }

  public var description: String {
    return storage.description
  }

}
