//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/17/19.
//

import Foundation


public class KeyedNestedEncoder<K: CodingKey>: Encoder, SingleValueEncodingContainer {

  typealias Key = K

  let key: K
  var container: KeyedEncodingContainer<K>
  let encoder: Encoder

  public init(key: K, container: KeyedEncodingContainer<K>, encoder: Encoder) {
    self.key = key
    self.container = container
    self.encoder = encoder
  }

  public var userInfo: [CodingUserInfoKey : Any] { encoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return container.nestedContainer(keyedBy: type, forKey: key)
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    return container.nestedUnkeyedContainer(forKey: key)
  }

  public func singleValueContainer() -> SingleValueEncodingContainer {
    return self
  }

  // Single value container

  public var codingPath: [CodingKey] {
    return container.codingPath + [key]
  }

  public func encodeNil() throws {
    try container.encodeNil(forKey: key)
  }

  public func encode(_ value: String) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Double) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Float) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Int) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Int8) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Int16) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Int32) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Int64) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: UInt) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: UInt8) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: UInt16) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: UInt32) throws {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: UInt64) throws {
    try container.encode(value, forKey: key)
  }

  public func encode<T>(_ value: T) throws where T : Encodable {
    try container.encode(value, forKey: key)
  }

  public func encode(_ value: Bool) throws {
    try container.encode(value, forKey: key)
  }

}


public class UnkeyedNestedEncoder: Encoder, SingleValueEncodingContainer {

  var container: UnkeyedEncodingContainer
  let encoder: Encoder

  public init(container: UnkeyedEncodingContainer, encoder: Encoder) {
    self.container = container
    self.encoder = encoder
  }

  public var userInfo: [CodingUserInfoKey : Any] { encoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return container.nestedContainer(keyedBy: type)
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    return container.nestedUnkeyedContainer()
  }

  public func singleValueContainer() -> SingleValueEncodingContainer {
    return self
  }

  // Single value container

  public var codingPath: [CodingKey] {
    return container.codingPath + [AnyCodingKey(index: container.count)]
  }

  public func encodeNil() throws {
    try container.encodeNil()
  }

  public func encode(_ value: String) throws {
    try container.encode(value)
  }

  public func encode(_ value: Double) throws {
    try container.encode(value)
  }

  public func encode(_ value: Float) throws {
    try container.encode(value)
  }

  public func encode(_ value: Int) throws {
    try container.encode(value)
  }

  public func encode(_ value: Int8) throws {
    try container.encode(value)
  }

  public func encode(_ value: Int16) throws {
    try container.encode(value)
  }

  public func encode(_ value: Int32) throws {
    try container.encode(value)
  }

  public func encode(_ value: Int64) throws {
    try container.encode(value)
  }

  public func encode(_ value: UInt) throws {
    try container.encode(value)
  }

  public func encode(_ value: UInt8) throws {
    try container.encode(value)
  }

  public func encode(_ value: UInt16) throws {
    try container.encode(value)
  }

  public func encode(_ value: UInt32) throws {
    try container.encode(value)
  }

  public func encode(_ value: UInt64) throws {
    try container.encode(value)
  }

  public func encode<T>(_ value: T) throws where T : Encodable {
    try container.encode(value)
  }

  public func encode(_ value: Bool) throws {
    try container.encode(value)
  }

}
