//
//  NestedDecoder.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public class KeyedNestedDecoder<K: CodingKey>: Decoder, SingleValueDecodingContainer {

  typealias Key = K

  let key: K
  let container: KeyedDecodingContainer<K>
  let decoder: Decoder

  public init(key: K, container: KeyedDecodingContainer<K>, decoder: Decoder) {
    self.key = key
    self.container = container
    self.decoder = decoder
  }

  public var userInfo: [CodingUserInfoKey: Any] { decoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    return try container.nestedContainer(keyedBy: type, forKey: key)
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    return try container.nestedUnkeyedContainer(forKey: key)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return self
  }

  // Single value container

  public var codingPath: [CodingKey] { container.codingPath + [key] }

  public func decodeNil() -> Bool {
    guard let isNil = try? container.decodeNil(forKey: key) else {
      return true
    }
    return isNil
  }

  public func decode(_ type: Bool.Type) throws -> Bool {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: String.Type) throws -> String {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Float.Type) throws -> Float {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Double.Type) throws -> Double {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Int.Type) throws -> Int {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Int8.Type) throws -> Int8 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Int16.Type) throws -> Int16 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Int32.Type) throws -> Int32 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: Int64.Type) throws -> Int64 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: UInt.Type) throws -> UInt {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try container.decode(type, forKey: key)
  }

  public func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try container.decode(type, forKey: key)
  }

  public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
    return try container.decode(type, forKey: key)
  }

}


public class UnkeyedNestedDecoder: Decoder, SingleValueDecodingContainer {

  var container: UnkeyedDecodingContainer
  let decoder: Decoder

  public init(container: UnkeyedDecodingContainer, decoder: Decoder) {
    self.container = container
    self.decoder = decoder
  }

  public var userInfo: [CodingUserInfoKey: Any] { decoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    return try container.nestedContainer(keyedBy: type)
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    return try container.nestedUnkeyedContainer()
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return self
  }

  // Single value container

  public var codingPath: [CodingKey] { container.codingPath + [AnyCodingKey(index: container.currentIndex)] }

  public func decodeNil() -> Bool {
    guard let isNil = try? container.decodeNil() else {
      return true
    }
    return isNil
  }

  public func decode(_ type: Bool.Type) throws -> Bool {
    return try container.decode(type)
  }

  public func decode(_ type: String.Type) throws -> String {
    return try container.decode(type)
  }

  public func decode(_ type: Float.Type) throws -> Float {
    return try container.decode(type)
  }

  public func decode(_ type: Double.Type) throws -> Double {
    return try container.decode(type)
  }

  public func decode(_ type: Int.Type) throws -> Int {
    return try container.decode(type)
  }

  public func decode(_ type: Int8.Type) throws -> Int8 {
    return try container.decode(type)
  }

  public func decode(_ type: Int16.Type) throws -> Int16 {
    return try container.decode(type)
  }

  public func decode(_ type: Int32.Type) throws -> Int32 {
    return try container.decode(type)
  }

  public func decode(_ type: Int64.Type) throws -> Int64 {
    return try container.decode(type)
  }

  public func decode(_ type: UInt.Type) throws -> UInt {
    return try container.decode(type)
  }

  public func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try container.decode(type)
  }

  public func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try container.decode(type)
  }

  public func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try container.decode(type)
  }

  public func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try container.decode(type)
  }

  public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
    return try container.decode(type)
  }

}
