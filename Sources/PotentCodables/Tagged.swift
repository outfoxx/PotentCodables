//
//  Tagged.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// Keys for requesting tagged values.
///
/// For formats that support tagged values (YAML, CBOR, ASN1, etc.) encoders & decoders _may_
/// support accessing the values as a destructured into a keyed container with the `tag` and `value`
/// keys. Using `TaggedItemKeys` allows clients to unambiguously access the destructured
/// components to determine how they should treat the value.
///
/// # Note:
/// Use of `TaggedItemKeys` do not require specific support by Encoders/Decoders. Although,
/// using it without explicit support will require the keyed containers to be present in data being
/// decoded and will produce them explicitly when encoding. Formats with explicit support will
/// use a more efficient encoding.
///
public enum TaggedItemKeys: String, CodingKey {
  case tag = "@tag"
  case value = "@value"
}



public extension KeyedDecodingContainerProtocol where Key == TaggedItemKeys {

  /// Decodes an expected tag value.
  ///
  /// Decodes a tag value and throws an error if the tag is not of the expected value.
  ///
  func decode<D: Decodable, Tag: Equatable & Decodable>(_ type: D.Type, expectingTag tag: Tag) throws -> D {
    let foundTag = try decode(Tag.self, forKey: .tag)
    guard foundTag == tag else {
      let desc = "Expected \(tag), found \(foundTag)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try decode(type, forKey: .value)
  }

  /// Decodes an expected tag value.
  ///
  /// Decodes a tag value and throws an error if the tag is not of the expected value.
  ///
  func decode<D: Decodable, Tag: Equatable & Decodable & RawRepresentable>(
    _ type: D.Type,
    expectingTag tag: Tag
  ) throws -> D where Tag.RawValue: Equatable & Decodable {
    let foundTagValue = try decode(Tag.RawValue.self, forKey: .tag)
    guard foundTagValue == tag.rawValue else {
      let foundTagName = Tag(rawValue: foundTagValue).map { String(describing: $0) } ?? "\(tag)"
      let desc = "Expected \(tag), found \(foundTagName)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try decode(type, forKey: .value)
  }

  /// Decodes an expected tag value.
  ///
  /// Decodes a tag value and throws an error if the tag is not of the expected value.
  ///
  func decodeIfPresent<D: Decodable, Tag: Equatable & Decodable>(
    _ type: D.Type,
    expectingTag tag: Tag,
    nullTag: Tag
  ) throws -> D? {
    let foundTag = try decode(Tag.self, forKey: .tag)
    if foundTag == nullTag {
      return nil
    }
    return try decode(type, expectingTag: tag)
  }

  /// Decodes an expected tag value.
  ///
  /// Decodes a tag value and throws an error if the tag is not of the expected value.
  ///
  func decodeIfPresent<D: Decodable, Tag: Equatable & Decodable & RawRepresentable>(
    _ type: D.Type,
    expectingTag tag: Tag,
    nullTag: Tag
  ) throws -> D? where Tag.RawValue: Equatable & Decodable {
    let foundTag = try decode(Tag.self, forKey: .tag)
    if foundTag == nullTag {
      return nil
    }
    return try decode(type, expectingTag: tag)
  }

  /// Retrieves a nested keyed container for an expected tag value.
  ///
  func nestedContainer<Key: CodingKey, Tag: Equatable & Decodable>(
    keyedBy type: Key.Type,
    expectingTag tag: Tag
  ) throws -> KeyedDecodingContainer<Key> {
    let foundTag = try decode(Tag.self, forKey: .tag)
    guard foundTag == tag else {
      let desc = "Expected \(tag), found \(foundTag)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try nestedContainer(keyedBy: type, forKey: .value)
  }

  /// Retrieves a nested keyed container for an expected tag value.
  ///
  func nestedContainer<Key: CodingKey, Tag: Equatable & Decodable & RawRepresentable>(
    keyedBy type: Key.Type,
    expectingTag tag: Tag
  ) throws -> KeyedDecodingContainer<Key> where Tag.RawValue: Equatable & Decodable {
    let foundTagValue = try decode(Tag.RawValue.self, forKey: .tag)
    guard foundTagValue == tag.rawValue else {
      let foundTagName = Tag(rawValue: foundTagValue).map { String(describing: $0) } ?? "\(tag)"
      let desc = "Expected \(tag), found \(foundTagName)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try nestedContainer(keyedBy: type, forKey: .value)
  }

  /// Retrieves a nested unkeyed container for an expected tag value.
  ///
  func nestedUnkeyedContainer<Tag: Equatable & Decodable>(expectingTag tag: Tag) throws -> UnkeyedDecodingContainer {
    let foundTag = try decode(Tag.self, forKey: .tag)
    guard foundTag == tag else {
      let desc = "Expected \(tag), found \(foundTag)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try nestedUnkeyedContainer(forKey: .value)
  }

  /// Retrieves a nested unkeyed container for an expected tag value.
  ///
  func nestedUnkeyedContainer<Tag: Equatable & Decodable & RawRepresentable>(expectingTag tag: Tag) throws
    -> UnkeyedDecodingContainer where Tag.RawValue: Equatable & Decodable {
    let foundTagValue = try decode(Tag.RawValue.self, forKey: .tag)
    guard foundTagValue == tag.rawValue else {
      let foundTagName = Tag(rawValue: foundTagValue).map { String(describing: $0) } ?? "\(tag)"
      let desc = "Expected \(tag), found \(foundTagName)"
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: desc
      ))
    }
    return try nestedUnkeyedContainer(forKey: .value)
  }

}



public extension KeyedEncodingContainerProtocol where Key == TaggedItemKeys {

  /// Encodes a value with an associated tag value.
  ///
  mutating func encode<E: Encodable, Tag: Encodable>(_ value: E, withTag tag: Tag) throws {
    try encode(tag, forKey: .tag)
    try encode(value, forKey: .value)
  }

  /// Encodes a value with an associated tag value.
  ///
  mutating func encode<E: Encodable, Tag: Encodable & RawRepresentable>(_ value: E, withTag tag: Tag) throws
    where Tag.RawValue: Encodable {
    try encode(tag.rawValue, forKey: .tag)
    try encode(value, forKey: .value)
  }

  /// Retrieves a nested keyed container for an expected tag value.
  ///
  mutating func nestedContainer<NestedKey: CodingKey, Tag: Equatable & Encodable>(
    keyedBy type: NestedKey.Type,
    withTag tag: Tag
  ) throws -> KeyedEncodingContainer<NestedKey> {
    try encode(tag, forKey: .tag)
    return nestedContainer(keyedBy: type, forKey: .value)
  }

  /// Retrieves a nested keyed container for an expected tag value.
  ///
  mutating func nestedContainer<
    NestedKey: CodingKey,
    Tag: Equatable & Encodable & RawRepresentable
  >(
    keyedBy type: NestedKey.Type,
    withTag tag: Tag
  ) throws -> KeyedEncodingContainer<NestedKey> where Tag.RawValue: Equatable & Encodable {
    try encode(tag.rawValue, forKey: .tag)
    return nestedContainer(keyedBy: type, forKey: .value)
  }

  /// Retrieves a nested unkeyed container for an expected tag value.
  ///
  mutating func nestedUnkeyedContainer<Tag: Equatable & Encodable>(withTag tag: Tag) throws
    -> UnkeyedEncodingContainer {
    try encode(tag, forKey: .tag)
    return nestedUnkeyedContainer(forKey: .value)
  }

  /// Retrieves a nested unkeyed container for an expected tag value.
  ///
  mutating func nestedUnkeyedContainer<Tag: Equatable & Encodable & RawRepresentable>(withTag tag: Tag) throws
    -> UnkeyedEncodingContainer where Tag.RawValue: Equatable & Encodable {
    try encode(tag, forKey: .tag)
    return nestedUnkeyedContainer(forKey: .value)
  }

}
