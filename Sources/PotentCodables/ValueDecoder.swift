//
//  ValueDecoder.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import OrderedCollections


/// Decoder options that will be passed through the decoding process
public protocol InternalDecoderOptions {

  var keyDecodingStrategy: KeyDecodingStrategy { get }
  var userInfo: [CodingUserInfoKey: Any] { get }

}


public protocol InternalValueDeserializer {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalDecoderOptions

  static func value(from: Data, options: Options) throws -> Value

}

public protocol InternalValueParser {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalDecoderOptions

  static func value(from: String, options: Options) throws -> Value

}


/// A decoder transform provides required functionality to unbox instances of
/// `Value` into Swift/Foundation primitives.
///
/// Implementing this protocol is all that is required to translate instances of
/// `Value` into `Decodable` instances.
public protocol InternalDecoderTransform {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalDecoderOptions
  associatedtype State

  static var nilValue: Value { get }

  typealias IVD = InternalValueDecoder<Value, Self>
  typealias UnkeyedValues = [Value]
  typealias KeyedValues = OrderedDictionary<String, Value>

  static func unbox(_ value: Value, as type: Bool.Type, decoder: IVD) throws -> Bool?
  static func unbox(_ value: Value, as type: Int.Type, decoder: IVD) throws -> Int?
  static func unbox(_ value: Value, as type: Int8.Type, decoder: IVD) throws -> Int8?
  static func unbox(_ value: Value, as type: Int16.Type, decoder: IVD) throws -> Int16?
  static func unbox(_ value: Value, as type: Int32.Type, decoder: IVD) throws -> Int32?
  static func unbox(_ value: Value, as type: Int64.Type, decoder: IVD) throws -> Int64?
  static func unbox(_ value: Value, as type: UInt.Type, decoder: IVD) throws -> UInt?
  static func unbox(_ value: Value, as type: UInt8.Type, decoder: IVD) throws -> UInt8?
  static func unbox(_ value: Value, as type: UInt16.Type, decoder: IVD) throws -> UInt16?
  static func unbox(_ value: Value, as type: UInt32.Type, decoder: IVD) throws -> UInt32?
  static func unbox(_ value: Value, as type: UInt64.Type, decoder: IVD) throws -> UInt64?
  static func unbox(_ value: Value, as type: Float.Type, decoder: IVD) throws -> Float?
  static func unbox(_ value: Value, as type: Double.Type, decoder: IVD) throws -> Double?
  static func unbox(_ value: Value, as type: String.Type, decoder: IVD) throws -> String?

  static func intercepts(_ type: Decodable.Type) -> Bool
  static func unbox(_ value: Value, interceptedType: Decodable.Type, decoder: IVD) throws -> Any?

  static func unbox(_ value: Value, otherType: Decodable.Type, decoder: IVD) throws -> Any?

  static func valueToUnkeyedValues(_ value: Value, decoder: IVD) throws -> UnkeyedValues?
  static func valueToKeyedValues(_ value: Value, decoder: IVD) throws -> KeyedValues?

}


/// `ValueDecoder` facilitates the decoding of`Value` values into semantic `Decodable` types.
open class ValueDecoder<Value, Transform> where Transform: InternalDecoderTransform, Value == Transform.Value {

  public typealias Options = Transform.Options

  /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
  open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

  /// Contextual user-provided information for use during decoding.
  open var userInfo: [CodingUserInfoKey: Any] = [:]

  /// The options set on the top-level decoder.
  open var options: Transform.Options { fatalError() }

  open var state: Transform.State!

  // MARK: - Decoding Values

  /// Decodes a top-level value of the given type from the given value.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The value to decode from.
  /// - returns: A value of the requested type.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: `DecodingError.valueNotFound` if source contains a `null` value.
  /// - throws: An error if any value throws an error during decoding.
  open func decodeTree<T: Decodable>(_ type: T.Type, from value: Value) throws -> T {
    guard let value = try decodeTreeIfPresent(type, from: value) as T? else {
      throw DecodingError.valueNotFound(
        T.self,
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Value contained null when attempting to decode non-optional type"
        )
      )
    }
    return value
  }

  /// Decodes a top-level value of the given type from the given value or
  /// nil if the value contains a `null`.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The value to decode from.
  /// - returns: A value of the requested type or nil.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: An error if any value throws an error during decoding.
  open func decodeTreeIfPresent<T: Decodable>(_ type: T.Type, from value: Value) throws -> T? {
    guard !value.isNull else { return nil }
    let decoder = InternalValueDecoder<Value, Transform>(referencing: value, options: options)
    guard let value = try decoder.unbox(value, as: type) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value.")
      )
    }
    return value
  }

  public init() {}

}

extension ValueDecoder where Transform: InternalValueDeserializer {

  /// Decodes a top-level value of the given type from the given data.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The value to decode from.
  /// - returns: A value of the requested type.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: `DecodingError.valueNotFound` if source contains a `null` value.
  /// - throws: An error if any value throws an error during decoding.
  public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let value = try Transform.value(from: data, options: options)
    guard let result = try decodeTreeIfPresent(type, from: value) as T? else {
      throw DecodingError.valueNotFound(
        T.self,
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Value contained null when attempting to decode non-optional type"
        )
      )
    }
    return result
  }

  /// Decodes a top-level value of the given type from the given value or
  /// nil if the value contains a `null`.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The value to decode from.
  /// - returns: A value of the requested type or nil.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: An error if any value throws an error during decoding.
  public func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: Data) throws -> T? {
    let value = try Transform.value(from: data, options: options)
    guard !value.isNull else { return nil }
    let decoder = InternalValueDecoder<Value, Transform>(referencing: value, options: options)
    guard let result = try decoder.unbox(value, as: type) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value.")
      )
    }
    return result
  }

}

extension ValueDecoder where Transform: InternalValueParser {

  /// Decodes a top-level value of the given type from the given string.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The string to decode from.
  /// - returns: A value of the requested type.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: `DecodingError.valueNotFound` if source contains a `null` value.
  /// - throws: An error if any value throws an error during decoding.
  public func decode<T: Decodable>(_ type: T.Type, from data: String) throws -> T {
    let value = try Transform.value(from: data, options: options)
    guard let result = try decodeTreeIfPresent(type, from: value) as T? else {
      throw DecodingError.valueNotFound(
        T.self,
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Value contained null when attempting to decode non-optional type"
        )
      )
    }
    return result
  }

  /// Decodes a top-level value of the given type from the given string or
  /// nil if the value contains a `null`.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter value: The string to decode from.
  /// - returns: A value of the requested type or nil.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted.
  /// - throws: An error if any value throws an error during decoding.
  public func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: String) throws -> T? {
    let value = try Transform.value(from: data, options: options)
    guard !value.isNull else { return nil }
    let decoder = InternalValueDecoder<Value, Transform>(referencing: value, options: options)
    guard let result = try decoder.unbox(value, as: type) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value.")
      )
    }
    return result
  }

}


// MARK: - InternalValueDecoder

/// `InternalValueDocoder` is the `Decoder` implementation that is passed to `Decodable` objects to allow them to perform decoding
///
/// Although the type represents an implementation of the public API for `Decodable` it can also be used by implementations of
/// `InternalDecoderTransform` as the instance is also passed to all members of the transform.
public class InternalValueDecoder<Value, Transform>: Decoder where Transform: InternalDecoderTransform,
  Value == Transform.Value {

  // MARK: Properties

  /// The decoder's storage.
  fileprivate var storage: ValueDecodingStorage<Value>

  public let options: Transform.Options

  public var state: Transform.State?

  /// The path to the current point in encoding.
  public fileprivate(set) var codingPath: [CodingKey]

  /// Contextual user-provided information for use during encoding.
  open var userInfo: [CodingUserInfoKey: Any] {
    return options.userInfo
  }

  // MARK: - Initialization

  /// Initializes `self` with the given top-level container and options.
  fileprivate init(referencing container: Value, at codingPath: [CodingKey] = [], options: Transform.Options) {
    storage = ValueDecodingStorage()
    storage.push(container: container)
    self.codingPath = codingPath
    self.options = options
  }

  fileprivate init(referencing container: Value, from decoder: InternalValueDecoder<Value, Transform>) {
    storage = decoder.storage
    codingPath = decoder.codingPath
    options = decoder.options
    state = decoder.state
  }

  // MARK: - Decoder Methods

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
    guard let topContainer = try Transform.valueToKeyedValues(storage.topContainer, decoder: self) else {
      throw DecodingError.valueNotFound(
        KeyedDecodingContainer<Key>.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get keyed decoding container -- found null value instead."
        )
      )
    }

    let container = try ValueKeyedDecodingContainer<Key, Value, Transform>(referencing: self, wrapping: topContainer)
    return KeyedDecodingContainer(container)
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    guard !storage.topContainer.isNull else {
      throw DecodingError.valueNotFound(
        UnkeyedDecodingContainer.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get unkeyed decoding container -- found null value instead."
        )
      )
    }

    guard let topContainer = try Transform.valueToUnkeyedValues(storage.topContainer, decoder: self) else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: [Value].self, reality: storage.topContainer)
    }

    return ValueUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return self
  }

  public func subDecode<T>(with value: Value, block: (Decoder) throws -> T) throws -> T {
    storage.push(container: value)
    defer { self.storage.popContainer() }
    return try block(self)
  }
}

// MARK: - Decoding Storage

private struct ValueDecodingStorage<Value> where Value: PotentCodables.Value {
  // MARK: Properties

  /// The container stack.
  fileprivate private(set) var containers: [Value] = []

  // MARK: - Initialization

  /// Initializes `self` with no containers.
  fileprivate init() {}

  // MARK: - Modifying the Stack

  fileprivate var count: Int {
    return containers.count
  }

  fileprivate var topContainer: Value {
    precondition(containers.count > 0, "Empty container stack.")
    return containers.last!
  }

  fileprivate mutating func push(container: Value) {
    containers.append(container)
  }

  fileprivate mutating func popContainer() {
    precondition(containers.count > 0, "Empty container stack.")
    containers.removeLast()
  }
}

// MARK: Decoding Containers

private struct ValueKeyedDecodingContainer<K: CodingKey, Value, Transform>: KeyedDecodingContainerProtocol
  where Transform: InternalDecoderTransform, Value == Transform.Value {
  typealias Key = K
  typealias InternalValueDecoder = PotentCodables.InternalValueDecoder<Value, Transform>

  // MARK: Properties

  /// A reference to the decoder we're reading from.
  private let decoder: InternalValueDecoder

  /// A reference to the container we're reading from.
  private let container: OrderedDictionary<String, Value>

  /// The path of coding keys taken to get to this point in decoding.
  public private(set) var codingPath: [CodingKey]

  // MARK: - Initialization

  /// Initializes `self` by referencing the given decoder and container.
  fileprivate init(referencing decoder: InternalValueDecoder, wrapping container: OrderedDictionary<String, Value>) throws {
    self.decoder = decoder
    switch decoder.options.keyDecodingStrategy {
    case .convertFromSnakeCase:
      // Convert the snake case keys in the container to camel case.
      // If we hit a duplicate key after conversion, then we'll use the first one we saw. Effectively an undefined behavior with dictionaries.
      self.container = try OrderedDictionary(
        container.map {
          (KeyDecodingStrategy.convertFromSnakeCase($0.key), $0.value)
        }, uniquingKeysWith: { _, _ in
          throw DecodingError.dataCorrupted(.init(
            codingPath: decoder.codingPath,
            debugDescription: "Container has duplicate keys"
          ))
        })
    case .custom(let converter):
      self.container = try OrderedDictionary(
        container.map { key, value in (
          converter(decoder.codingPath + [AnyCodingKey(stringValue: key, intValue: nil)]).stringValue,
          value)
        }, uniquingKeysWith: { _, _ in
          throw DecodingError.dataCorrupted(.init(
            codingPath: decoder.codingPath,
            debugDescription: "Container has duplicate keys"
          ))
        })
    case .useDefaultKeys:
      fallthrough
    @unknown default:
      self.container = container
    }
    codingPath = decoder.codingPath
  }

  // MARK: - KeyedDecodingContainerProtocol Methods

  public var allKeys: [Key] {
    return container.keys.compactMap { Key(stringValue: $0) }
  }

  public func contains(_ key: Key) -> Bool {
    return container[key.stringValue] != nil
  }

  internal func notFoundError(key: Key) -> DecodingError {
    return DecodingError.keyNotFound(
      key,
      DecodingError
        .Context(
          codingPath: decoder.codingPath,
          debugDescription: "No value associated with key \(errorDescription(of: key))."
        )
    )
  }

  internal func nullFoundError<T>(type: T.Type) -> DecodingError {
    return DecodingError.valueNotFound(
      type,
      DecodingError
        .Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead.")
    )
  }

  private func errorDescription(of key: CodingKey) -> String {
    switch decoder.options.keyDecodingStrategy {
    case .convertFromSnakeCase:
      // In this case we can attempt to recover the original value by reversing the transform
      let original = key.stringValue
      let converted = KeyEncodingStrategy.convertToSnakeCase(original)
      if converted == original {
        return #""\#(original)""#
      }
      else {
        return #""\#(original)" (\#(converted))"#
      }
    default:
      // Otherwise, just report the converted string
      return #""\#(key.stringValue)""#
    }
  }

  public func decodeNil(forKey key: Key) throws -> Bool {
    guard let entry = container[key.stringValue] else {
      throw notFoundError(key: key)
    }

    return entry.isNull
  }

  internal func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
    guard let entry = container[key.stringValue] else {
      throw notFoundError(key: key)
    }

    decoder.codingPath.append(key)
    defer { self.decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: type) else {
      throw nullFoundError(type: type)
    }

    return value
  }

  public func nestedContainer<NestedKey>(
    keyedBy type: NestedKey.Type,
    forKey key: Key
  ) throws -> KeyedDecodingContainer<NestedKey> {
    decoder.codingPath.append(key)
    defer { self.decoder.codingPath.removeLast() }

    guard let value = self.container[key.stringValue] else {
      throw DecodingError.keyNotFound(
        key,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(errorDescription(of: key))"
        )
      )
    }

    guard let dictionary = try Transform.valueToKeyedValues(value, decoder: decoder) else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: [String: Value].self, reality: value)
    }

    let nestedDecoder = InternalValueDecoder(referencing: value, from: decoder)
    let container = try ValueKeyedDecodingContainer<NestedKey, Value, Transform>(
      referencing: nestedDecoder,
      wrapping: dictionary
    )
    return KeyedDecodingContainer(container)
  }

  public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    decoder.codingPath.append(key)
    defer { self.decoder.codingPath.removeLast() }

    guard let value = container[key.stringValue] else {
      throw DecodingError.keyNotFound(
        key,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(errorDescription(of: key))"
        )
      )
    }

    guard let array = try Transform.valueToUnkeyedValues(value, decoder: decoder) else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: [Value].self, reality: value)
    }

    let nestedDecoder = InternalValueDecoder(referencing: value, from: decoder)
    return ValueUnkeyedDecodingContainer(referencing: nestedDecoder, wrapping: array)
  }

  private func superDecoder(forKey key: CodingKey) throws -> Decoder {
    decoder.codingPath.append(key)
    defer { self.decoder.codingPath.removeLast() }

    let value: Value = container[key.stringValue] ?? Transform.nilValue
    return InternalValueDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
  }

  public func superDecoder() throws -> Decoder {
    return try superDecoder(forKey: AnyCodingKey.super)
  }

  public func superDecoder(forKey key: Key) throws -> Decoder {
    return try superDecoder(forKey: key as CodingKey)
  }
}

private struct ValueUnkeyedDecodingContainer<Value, Transform>: UnkeyedDecodingContainer
  where Transform: InternalDecoderTransform, Value == Transform.Value {
  typealias InternalValueDecoder = PotentCodables.InternalValueDecoder<Value, Transform>

  // MARK: Properties

  /// A reference to the decoder we're reading from.
  private let decoder: InternalValueDecoder

  /// A reference to the container we're reading from.
  private let container: [Value]

  /// The path of coding keys taken to get to this point in decoding.
  public private(set) var codingPath: [CodingKey]

  /// The index of the element we're about to decode.
  public private(set) var currentIndex: Int

  // MARK: - Initialization

  /// Initializes `self` by referencing the given decoder and container.
  fileprivate init(referencing decoder: InternalValueDecoder, wrapping container: [Value]) {
    self.decoder = decoder
    self.container = container
    codingPath = decoder.codingPath
    currentIndex = 0
  }

  // MARK: - UnkeyedDecodingContainer Methods

  public var count: Int? {
    return container.count
  }

  public var isAtEnd: Bool {
    return currentIndex >= count!
  }

  public mutating func decodeNil() throws -> Bool {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        Any?.self,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    if container[currentIndex].isNull {
      currentIndex += 1
      return true
    }
    else {
      return false
    }
  }

  public mutating func decode(_ type: Bool.Type) throws -> Bool {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Bool.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Int.Type) throws -> Int {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Int.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Int8.Type) throws -> Int8 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Int8.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Int16.Type) throws -> Int16 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Int16.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Int32.Type) throws -> Int32 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Int32.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Int64.Type) throws -> Int64 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Int64.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: UInt.Type) throws -> UInt {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: UInt.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: UInt8.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: UInt16.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: UInt32.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: UInt64.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Float.Type) throws -> Float {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Float.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: Double.Type) throws -> Double {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: Double.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode(_ type: String.Type) throws -> String {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: String.self) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Unkeyed container is at end."
          )
      )
    }

    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex], as: type) else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(
            codingPath: decoder.codingPath + [AnyCodingKey(index: currentIndex)],
            debugDescription: "Expected \(type) but found null instead."
          )
      )
    }

    currentIndex += 1
    return decoded
  }

  public mutating func nestedContainer<NestedKey>(
    keyedBy type: NestedKey
      .Type
  ) throws -> KeyedDecodingContainer<NestedKey> {
    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        KeyedDecodingContainer<NestedKey>.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
        )
      )
    }

    let value = self.container[currentIndex]
    guard let dictionary = try Transform.valueToKeyedValues(value, decoder: decoder) else {
      throw DecodingError.valueNotFound(
        KeyedDecodingContainer<NestedKey>.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get keyed decoding container -- found null value instead."
        )
      )
    }

    currentIndex += 1
    let nestedDecoder = InternalValueDecoder(referencing: value, from: decoder)
    let container = try ValueKeyedDecodingContainer<NestedKey, Value, Transform>(
      referencing: nestedDecoder,
      wrapping: dictionary
    )
    return KeyedDecodingContainer(container)
  }

  public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        UnkeyedDecodingContainer.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
        )
      )
    }

    let value = container[currentIndex]
    guard !value.isNull else {
      throw DecodingError.valueNotFound(
        UnkeyedDecodingContainer.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get keyed decoding container -- found null value instead."
        )
      )
    }

    guard let array = try Transform.valueToUnkeyedValues(value, decoder: decoder) else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: [Value].self, reality: value)
    }

    currentIndex += 1
    let nestedDecoder = InternalValueDecoder(referencing: value, from: decoder)
    return ValueUnkeyedDecodingContainer(referencing: nestedDecoder, wrapping: array)
  }

  public mutating func superDecoder() throws -> Decoder {
    decoder.codingPath.append(AnyCodingKey(index: currentIndex))
    defer { self.decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      throw DecodingError.valueNotFound(
        Decoder.self,
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."
        )
      )
    }

    let value = container[currentIndex]
    currentIndex += 1
    return InternalValueDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
  }
}

extension InternalValueDecoder: SingleValueDecodingContainer {
  // MARK: SingleValueDecodingContainer Methods

  private func expectNonNull<T>(_ type: T.Type) throws {
    guard !decodeNil() else {
      throw DecodingError.valueNotFound(
        type,
        DecodingError
          .Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead.")
      )
    }
  }

  private func unwrap<T>(_ value: T?) throws -> T {
    guard let value = value else {
      throw DecodingError.valueNotFound(
        T.self,
        DecodingError
          .Context(codingPath: codingPath, debugDescription: "Expected \(T.self) but found null value instead.")
      )
    }
    return value
  }

  public func decodeNil() -> Bool {
    return storage.topContainer.isNull
  }

  public func decode(_ type: Bool.Type) throws -> Bool {
    try expectNonNull(Bool.self)
    return try unwrap(unbox(storage.topContainer, as: Bool.self))
  }

  public func decode(_ type: Int.Type) throws -> Int {
    try expectNonNull(Int.self)
    return try unwrap(unbox(storage.topContainer, as: Int.self))
  }

  public func decode(_ type: Int8.Type) throws -> Int8 {
    try expectNonNull(Int8.self)
    return try unwrap(unbox(storage.topContainer, as: Int8.self))
  }

  public func decode(_ type: Int16.Type) throws -> Int16 {
    try expectNonNull(Int16.self)
    return try unwrap(unbox(storage.topContainer, as: Int16.self))
  }

  public func decode(_ type: Int32.Type) throws -> Int32 {
    try expectNonNull(Int32.self)
    return try unwrap(unbox(storage.topContainer, as: Int32.self))
  }

  public func decode(_ type: Int64.Type) throws -> Int64 {
    try expectNonNull(Int64.self)
    return try unwrap(unbox(storage.topContainer, as: Int64.self))
  }

  public func decode(_ type: UInt.Type) throws -> UInt {
    try expectNonNull(UInt.self)
    return try unwrap(unbox(storage.topContainer, as: UInt.self))
  }

  public func decode(_ type: UInt8.Type) throws -> UInt8 {
    try expectNonNull(UInt8.self)
    return try unwrap(unbox(storage.topContainer, as: UInt8.self))
  }

  public func decode(_ type: UInt16.Type) throws -> UInt16 {
    try expectNonNull(UInt16.self)
    return try unwrap(unbox(storage.topContainer, as: UInt16.self))
  }

  public func decode(_ type: UInt32.Type) throws -> UInt32 {
    try expectNonNull(UInt32.self)
    return try unwrap(unbox(storage.topContainer, as: UInt32.self))
  }

  public func decode(_ type: UInt64.Type) throws -> UInt64 {
    try expectNonNull(UInt64.self)
    return try unwrap(unbox(storage.topContainer, as: UInt64.self))
  }

  public func decode(_ type: Float.Type) throws -> Float {
    try expectNonNull(Float.self)
    return try unwrap(unbox(storage.topContainer, as: Float.self))
  }

  public func decode(_ type: Double.Type) throws -> Double {
    try expectNonNull(Double.self)
    return try unwrap(unbox(storage.topContainer, as: Double.self))
  }

  public func decode(_ type: String.Type) throws -> String {
    try expectNonNull(String.self)
    return try unwrap(unbox(storage.topContainer, as: String.self))
  }

  public func decode<T: Decodable>(_ type: T.Type) throws -> T {
    try expectNonNull(type)
    return try unwrap(unbox(storage.topContainer, as: type))
  }
}

// MARK: - Concrete Value Representations

private extension InternalValueDecoder {
  func unbox(_ value: Value, as type: Bool.Type) throws -> Bool? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Int.Type) throws -> Int? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Int8.Type) throws -> Int8? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Int16.Type) throws -> Int16? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Int32.Type) throws -> Int32? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Int64.Type) throws -> Int64? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: UInt.Type) throws -> UInt? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: UInt8.Type) throws -> UInt8? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: UInt16.Type) throws -> UInt16? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: UInt32.Type) throws -> UInt32? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: UInt64.Type) throws -> UInt64? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Float.Type) throws -> Float? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: Double.Type) throws -> Double? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox(_ value: Value, as type: String.Type) throws -> String? {
    return try Transform.unbox(value, as: type, decoder: self)
  }

  func unbox<T>(_ value: Value, as type: ValueStringDictionaryDecodableMarker.Type) throws -> T? {
    guard !value.isNull else { return nil }

    var result = [String: Any]()
    guard let dict = try Transform.valueToKeyedValues(value, decoder: self) else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: type, reality: value)
    }
    let elementType = type.elementType
    for (key, value) in dict {
      codingPath.append(AnyCodingKey(stringValue: key, intValue: nil))
      defer { self.codingPath.removeLast() }

      result[key] = try unbox(value: value, as: elementType)
    }

    return result as? T
  }

  func unbox<T: Decodable>(_ value: Value, as type: T.Type) throws -> T? {
    guard let unboxed = try unbox(value: value, as: type) else {
      return nil
    }
    guard let result = unboxed as? T else {
      throw DecodingError.typeMismatch(at: codingPath, expectation: type, reality: unboxed)
    }
    return result
  }

}

public extension InternalValueDecoder {

  func unbox(value: Value, as type: Decodable.Type) throws -> Any? {
    if type == Value.self {
      return value
    }
    else if Transform.intercepts(type) {
      return try Transform.unbox(value, interceptedType: type, decoder: self)
    }
    else if let stringKeyedDictType = type as? ValueStringDictionaryDecodableMarker.Type {
      return try unbox(value, as: stringKeyedDictType)
    }
    else {
      return try Transform.unbox(value, otherType: type, decoder: self)
    }
  }

}


/// A marker protocol used to determine whether a value is a `String`-keyed `Dictionary`
/// containing `Decodable` values (in which case it should be exempt from key conversion strategies).
///
/// The marker protocol also provides access to the type of the `Decodable` values,
/// which is needed for the implementation of the key conversion strategy exemption.
///
public protocol ValueStringDictionaryDecodableMarker {
  static var elementType: Decodable.Type { get }
}

extension Dictionary: ValueStringDictionaryDecodableMarker where Key == String, Value: Decodable {
  public static var elementType: Decodable.Type { return Value.self }
}

private enum NullCodingKeys: CodingKey {}



public extension InternalDecoderTransform {

  static func intercepts(_ type: Decodable.Type) -> Bool {
    return false
  }

  static func unbox(_ value: Value, interceptedType: Decodable.Type, decoder: IVD) throws -> Any? {
    fatalError("abstract")
  }

  static func unbox(_ value: Value, otherType: Decodable.Type, decoder: IVD) throws -> Any? {
    return try decoder.subDecode(with: value) { decoder in try otherType.init(from: decoder) }
  }

}
