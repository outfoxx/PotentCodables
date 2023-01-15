//
//  AnyString.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// Allows encoding _any_ ASN.1 string value while allowing control of the
/// specific ASN.1 tag.
///
public struct AnyString: Equatable, Hashable {

  /// Kind of ASN.1 string.
  ///
  /// Controls the specific ASN.1 tag used in encoded form.
  public enum Kind: Int, Equatable, Hashable, Codable {
    /// UTF-8 String.
    case utf8
    /// ASCII subset with the following allowed characters:
    /// * Digits (`0-9`)
    /// * Space (` `)
    case numeric
    /// ASCII subset with the following allowed characters:
    /// * Latin Uppercase (`A-Z`)
    /// * Latin Lowercase (`a-z`)
    /// * Digits (`0-9`)
    /// * Space (` `)
    /// * Apostrophe (`'`)
    /// * Parenthesis (`(`, `)`)
    /// * Plus (`+`)
    /// * Comma (`,`)
    /// * Minus (`-`)
    /// * Full Stop (aka Period) (`.`),
    /// * Solidus (`/`)
    /// * Colon (`:`)
    /// * Equal (`=`)
    /// * Question Mark (`?`)
    case printable
    /// CCIT's T61 String character, space and delete.
    case teletex
    /// CCIT's T.100/T.101 String character, space and delete.
    case videotex
    /// Internation Alphabet 5 (Internaional ASCII).
    case ia5
    /// All registered graphic character sets.
    case graphic
    /// Printing character sets of international ASCII, and space.
    case visible
    /// All registered graphic and character sets.
    case general
    /// ISO646 character set.
    case universal
    /// All registered graphic character sets.
    case character
    /// BMP subset (aka UCS-2) codepoints 0-65535.
    case bmp
  }

  /// Specifies the exact ``Kind`` of string.
  ///
  /// When encoding, selects the specific kind when the schema allows
  /// for multiple kinds of strings.
  ///
  /// When decoding, reports the specific kind of string that was decoded.
  ///
  public var kind: Kind?
  /// String value
  public var storage: String

  /// Initialize with a Swift String and explicit ASN.1 kind.
  public init(_ value: String, kind: Kind? = nil) {
    self.kind = kind
    storage = value
  }

}


extension AnyString: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    storage = try container.decode(String.self)
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
    kind = nil
    storage = value
  }

  public init(_ value: String) {
    kind = nil
    storage = value
  }

  public init<C, Encoding>(decoding codeUnits: C, as sourceEncoding: Encoding.Type) where C: Collection,
    Encoding: _UnicodeEncoding, C.Element == Encoding.CodeUnit {
    kind = nil
    storage = String(decoding: codeUnits, as: sourceEncoding)
  }

  public init(cString nullTerminatedUTF8: UnsafePointer<CChar>) {
    kind = nil
    storage = String(cString: nullTerminatedUTF8)
  }

  public init<Encoding>(
    decodingCString nullTerminatedCodeUnits: UnsafePointer<Encoding.CodeUnit>,
    as sourceEncoding: Encoding.Type
  ) where Encoding: _UnicodeEncoding {
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

  public func withCString<Result, Encoding>(
    encodedAs targetEncoding: Encoding.Type,
    _ body: (UnsafePointer<Encoding.CodeUnit>) throws -> Result
  ) rethrows -> Result where Encoding: _UnicodeEncoding {
    return try storage.withCString(encodedAs: targetEncoding, body)
  }

  public subscript(position: String.Index) -> Character {
    return storage[position]
  }

  public subscript(bounds: Range<String.Index>) -> Substring {
    return storage[bounds]
  }

  public func index(before index: String.Index) -> String.Index {
    return storage.index(before: index)
  }

  public func index(after index: String.Index) -> String.Index {
    return storage.index(after: index)
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

  public func write<Target>(to target: inout Target) where Target: TextOutputStream {
    storage.write(to: &target)
  }

  public var description: String {
    return storage.description
  }

}
