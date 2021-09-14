/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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

  public var userInfo: [CodingUserInfoKey: Any] { encoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
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

  public func encode<T>(_ value: T) throws where T: Encodable {
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

  public var userInfo: [CodingUserInfoKey: Any] { encoder.userInfo }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
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

  public func encode<T>(_ value: T) throws where T: Encodable {
    try container.encode(value)
  }

  public func encode(_ value: Bool) throws {
    try container.encode(value)
  }

}
