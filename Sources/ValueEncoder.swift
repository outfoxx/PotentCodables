//
//  ValueEncoder.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// Encoder options that will be passed through the encoding process
public protocol InternalEncoderOptions {

  var keyEncodingStrategy: KeyEncodingStrategy { get }
  var userInfo: [CodingUserInfoKey: Any] { get }

}


public protocol InternalValueSerializer {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalEncoderOptions

  static func data(from: Value, options: Options) throws -> Data

}

public protocol InternalValueStringifier {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalEncoderOptions

  static func string(from: Value, options: Options) throws -> String

}

/// An encoder transform provides required functionality to box instances of
/// Swift/Foundation primitives into instances of `Value`.
///
/// Implementing this protocol is all that is required to translate `Encodable`
/// values into a tree of `Value` instances.
public protocol InternalEncoderTransform {

  associatedtype Value: PotentCodables.Value
  associatedtype Options: InternalEncoderOptions

  static var nilValue: Value { get }
  static var emptyKeyedContainer: Value { get }

  static func box(_ value: Bool, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Int, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Int8, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Int16, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Int32, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Int64, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UInt, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UInt8, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UInt16, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UInt32, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UInt64, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: String, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Float, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Double, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Decimal, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Data, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: URL, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: UUID, encoder: InternalValueEncoder<Value, Self>) throws -> Value
  static func box(_ value: Date, encoder: InternalValueEncoder<Value, Self>) throws -> Value

  static func unkeyedValuesToValue(_ values: [Value]) -> Value
  static func keyedValuesToValue(_ values: [String: Value]) -> Value

}


/// `ValueEncoder` facilitates the encoding of `Encodable` values into  values.
open class ValueEncoder<Value, Transform> where Transform: InternalEncoderTransform, Value == Transform.Value {
  // MARK: Options

  /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
  open var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys

  /// Contextual user-provided information for use during encoding.
  open var userInfo: [CodingUserInfoKey: Any] = [:]

  /// The options set on the top-level encoder.
  open var options: Transform.Options { fatalError() }

  // MARK: - Constructing a Value Encoder

  /// Initializes `self` with default strategies.
  public init() {}

  // MARK: - Encoding Values

  /// Encodes the given top-level value and returns its representation.
  ///
  /// - parameter value: The value to encode.
  /// - returns: A new value containing the encoded data.
  /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
  /// - throws: An error if any value throws an error during encoding.
  open func encodeTree<T: Encodable>(_ value: T) throws -> Value {
    let encoder = InternalValueEncoder<Value, Transform>(options: options)

    guard let topLevel = try encoder.box_(value) else {
      throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
    }

    return topLevel
  }

}

extension ValueEncoder where Transform: InternalValueSerializer {

  /// Encodes the given top-level value and returns its data.
  ///
  /// - parameter value: The value to encode.
  /// - returns: A new value containing the encoded data.
  /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
  /// - throws: An error if any value throws an error during encoding.
  open func encode<T: Encodable>(_ value: T) throws -> Data {
    let tree = try encodeTree(value)
    return try Transform.data(from: tree, options: options)
  }

}

extension ValueEncoder where Transform: InternalValueStringifier {

  /// Encodes the given top-level value and returns its stringified form.
  ///
  /// - parameter value: The value to encode.
  /// - returns: A new value containing the stringified value.
  /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
  /// - throws: An error if any value throws an error during encoding.
  open func encodeString<T: Encodable>(_ value: T) throws -> String {
    let tree = try encodeTree(value)
    return try Transform.string(from: tree, options: options)
  }

}


// MARK: - InternalValueEncoder

/// `InternalValueEncoder` is the `Encoder` implementation that is passed to `Encodable` objects to allow them to perform encoding
///
/// Although the type represents an implementation of the public API for `Encodable` it can also be used by implementations of
/// `InternalEncoderTransform` as the instance is also passed to all members of the transform.
public class InternalValueEncoder<Value, Transform>: Encoder where Transform: InternalEncoderTransform, Value == Transform.Value {
  private typealias ValueEncoder = PotentCodables.ValueEncoder<Value, Transform>
  private typealias KeyedContainer = PotentCodables.KeyedContainer<Value, Transform>

  // MARK: Properties

  /// The encoder's storage.
  fileprivate var storage: ValueEncodingStorage<Value, Transform>

  /// Options set on the top-level encoder.
  public let options: Transform.Options

  /// The path to the current point in encoding.
  public var codingPath: [CodingKey]

  /// Contextual user-provided information for use during encoding.
  public var userInfo: [CodingUserInfoKey: Any] {
    return options.userInfo
  }

  // MARK: - Initialization

  /// Initializes `self` with the given top-level encoder options.
  fileprivate init(options: Transform.Options, codingPath: [CodingKey] = []) {
    self.options = options
    storage = ValueEncodingStorage()
    self.codingPath = codingPath
  }

  /// Returns whether a new element can be encoded at this coding path.
  ///
  /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
  fileprivate var canEncodeNewValue: Bool {
    // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
    // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
    // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
    //
    // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
    // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
    return storage.count == codingPath.count
  }

  // MARK: - Encoder Methods

  public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
    // If an existing keyed container was already requested, return that one.
    let topContainer: KeyedContainer
    if canEncodeNewValue {
      // We haven't yet pushed a container at this level; do so here.
      topContainer = storage.pushKeyedContainer()
    }
    else {
      guard let container = self.storage.containers.last?.container as? KeyedContainer else {
        preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
      }

      topContainer = container
    }

    let container = ValueKeyedEncodingContainer<Key, Value, Transform>(referencing: self, codingPath: codingPath, wrapping: topContainer)
    return KeyedEncodingContainer(container)
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    // If an existing unkeyed container was already requested, return that one.
    let topContainer: UnkeyedContainer<Value, Transform>
    if canEncodeNewValue {
      // We haven't yet pushed a container at this level; do so here.
      topContainer = storage.pushUnkeyedContainer()
    }
    else {
      guard let container = self.storage.containers.last?.container as? UnkeyedContainer<Value, Transform> else {
        preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
      }

      topContainer = container
    }

    return ValueUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
  }

  public func singleValueContainer() -> SingleValueEncodingContainer {
    return self
  }

  public func subEncode(_ block: (Encoder) throws -> Void) throws -> Value {
    let depth = storage.count
    do {
      try block(self)
    }
    catch {
      // If the value pushed a container before throwing, pop it back off to restore state.
      if storage.count > depth {
        _ = storage.popContainer()
      }
      throw error
    }

    guard storage.count > depth else {
      // The block didn't encode anything. Return the default keyed container.
      return Transform.emptyKeyedContainer
    }

    return storage.popContainer().value
  }

}

// MARK: - Encoding Storage and Containers

private struct ValueEncodingStorage<Value, Transform> where Transform: InternalEncoderTransform, Value == Transform.Value {
  // MARK: Properties

  /// The container stack.
  /// Elements may be any one of the containers.
  fileprivate private(set) var containers: [AnyContainer<Value>] = []

  // MARK: - Initialization

  /// Initializes `self` with no containers.
  fileprivate init() {}

  // MARK: - Modifying the Stack

  fileprivate var count: Int {
    return containers.count
  }

  fileprivate mutating func pushKeyedContainer() -> KeyedContainer<Value, Transform> {
    let container = KeyedContainer<Value, Transform>()
    containers.append(AnyContainer(container))
    return container
  }

  fileprivate mutating func pushUnkeyedContainer() -> UnkeyedContainer<Value, Transform> {
    let container = UnkeyedContainer<Value, Transform>()
    containers.append(AnyContainer(container))
    return container
  }

  fileprivate mutating func push(container: Value) {
    containers.append(AnyContainer(ValueContainer(value: container)))
  }

  fileprivate mutating func popContainer() -> AnyContainer<Value> {
    precondition(containers.count > 0, "Empty container stack.")
    return containers.popLast()!
  }
}

// MARK: - Encoding Containers

private struct ValueKeyedEncodingContainer<K: CodingKey, Value, Transform>: KeyedEncodingContainerProtocol where Transform: InternalEncoderTransform, Value == Transform.Value {
  typealias Key = K
  typealias InternalValueEncoder = PotentCodables.InternalValueEncoder<Value, Transform>

  // MARK: Properties

  /// A reference to the encoder we're writing to.
  private let encoder: InternalValueEncoder

  /// A reference to the container we're writing to.
  private var container: KeyedContainer<Value, Transform>

  /// The path of coding keys taken to get to this point in encoding.
  public private(set) var codingPath: [CodingKey]

  // MARK: - Initialization

  /// Initializes `self` with the given references.
  fileprivate init(referencing encoder: InternalValueEncoder, codingPath: [CodingKey], wrapping container: KeyedContainer<Value, Transform>) {
    self.encoder = encoder
    self.codingPath = codingPath
    self.container = container
  }

  // MARK: - Coding Path Operations

  private func _converted(_ key: CodingKey) -> CodingKey {
    switch encoder.options.keyEncodingStrategy {
    case .useDefaultKeys:
      return key
    case .convertToSnakeCase:
      let newKeyString = KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
      return AnyCodingKey(stringValue: newKeyString, intValue: key.intValue)
    case .custom(let converter):
      return converter(codingPath + [key])
    }
  }

  // MARK: - KeyedEncodingContainerProtocol Methods

  public mutating func encodeNil(forKey key: Key) throws {
    container[_converted(key).stringValue] = Transform.nilValue
  }

  public mutating func encode(_ value: Bool, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Int, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Int8, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Int16, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Int32, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Int64, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: UInt, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: UInt8, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: UInt16, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: UInt32, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: UInt64, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: String, forKey key: Key) throws {
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Float, forKey key: Key) throws {
    // Since the float may be invalid and throw, the coding path needs to contain this key.
    encoder.codingPath.append(key)
    defer { self.encoder.codingPath.removeLast() }
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode(_ value: Double, forKey key: Key) throws {
    // Since the double may be invalid and throw, the coding path needs to contain this key.
    encoder.codingPath.append(key)
    defer { self.encoder.codingPath.removeLast() }
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    encoder.codingPath.append(key)
    defer { self.encoder.codingPath.removeLast() }
    container[_converted(key).stringValue] = try encoder.box(value)
  }

  public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
    let keyed = NestedKeyedContainer<KeyedNesting<Value, Transform>, Value, Transform>(KeyedNesting(self.container, _converted(key).stringValue))
    self.container[keyed.nesting.key] = keyed.currentValue

    codingPath.append(key)
    defer { self.codingPath.removeLast() }

    let container = ValueKeyedEncodingContainer<NestedKey, Value, Transform>(referencing: encoder, codingPath: codingPath, wrapping: keyed)
    return KeyedEncodingContainer(container)
  }

  public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    let unkeyed = NestedUnkeyedContainer<KeyedNesting<Value, Transform>, Value, Transform>(KeyedNesting(container, _converted(key).stringValue))
    container[unkeyed.nesting.key] = unkeyed.currentValue

    codingPath.append(key)
    defer { self.codingPath.removeLast() }
    return ValueUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: unkeyed)
  }

  public mutating func superEncoder() -> Encoder {
    return ValueReferencingEncoder(referencing: encoder, key: AnyCodingKey.super, convertedKey: _converted(AnyCodingKey.super), wrapping: container)
  }

  public mutating func superEncoder(forKey key: Key) -> Encoder {
    return ValueReferencingEncoder(referencing: encoder, key: key, convertedKey: _converted(key), wrapping: container)
  }
}

private struct ValueUnkeyedEncodingContainer<Value, Transform>: UnkeyedEncodingContainer where Transform: InternalEncoderTransform, Value == Transform.Value {
  // MARK: Properties

  /// A reference to the encoder we're writing to.
  private let encoder: InternalValueEncoder<Value, Transform>

  /// A reference to the container we're writing to.
  private var container: UnkeyedContainer<Value, Transform>

  /// The path of coding keys taken to get to this point in encoding.
  public private(set) var codingPath: [CodingKey]

  /// The number of elements encoded into the container.
  public var count: Int {
    return container.count
  }

  // MARK: - Initialization

  /// Initializes `self` with the given references.
  fileprivate init(referencing encoder: InternalValueEncoder<Value, Transform>, codingPath: [CodingKey], wrapping container: UnkeyedContainer<Value, Transform>) {
    self.encoder = encoder
    self.codingPath = codingPath
    self.container = container
  }

  // MARK: - UnkeyedEncodingContainer Methods

  public mutating func encodeNil() throws { container.append(Transform.nilValue) }
  public mutating func encode(_ value: Bool) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: Int) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: Int8) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: Int16) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: Int32) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: Int64) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: UInt) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: UInt8) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: UInt16) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: UInt32) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: UInt64) throws { container.append(try encoder.box(value)) }
  public mutating func encode(_ value: String) throws { container.append(try encoder.box(value)) }

  public mutating func encode(_ value: Float) throws {
    // Since the float may be invalid and throw, the coding path needs to contain this key.
    encoder.codingPath.append(AnyCodingKey(intValue: count))
    defer { self.encoder.codingPath.removeLast() }
    container.append(try encoder.box(value))
  }

  public mutating func encode(_ value: Double) throws {
    // Since the double may be invalid and throw, the coding path needs to contain this key.
    encoder.codingPath.append(AnyCodingKey(index: count))
    defer { self.encoder.codingPath.removeLast() }
    container.append(try encoder.box(value))
  }

  public mutating func encode<T: Encodable>(_ value: T) throws {
    encoder.codingPath.append(AnyCodingKey(index: count))
    defer { self.encoder.codingPath.removeLast() }
    container.append(try encoder.box(value))
  }

  public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
    codingPath.append(AnyCodingKey(index: count))
    defer { self.codingPath.removeLast() }

    let keyed = NestedKeyedContainer<UnkeyedNesting, Value, Transform>(UnkeyedNesting(self.container, self.container.count))
    self.container.append(keyed.currentValue)

    let container = ValueKeyedEncodingContainer<NestedKey, Value, Transform>(referencing: encoder, codingPath: codingPath, wrapping: keyed)
    return KeyedEncodingContainer(container)
  }

  public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    codingPath.append(AnyCodingKey(index: count))
    defer { self.codingPath.removeLast() }

    let unkeyed = NestedUnkeyedContainer<UnkeyedNesting, Value, Transform>(UnkeyedNesting(container, container.count))
    container.append(unkeyed.currentValue)

    return ValueUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: unkeyed)
  }

  public mutating func superEncoder() -> Encoder {
    return ValueReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
  }
}

extension InternalValueEncoder: SingleValueEncodingContainer {
  // MARK: - SingleValueEncodingContainer Methods

  fileprivate func assertCanEncodeNewValue() {
    precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
  }

  public func encodeNil() throws {
    assertCanEncodeNewValue()
    storage.push(container: Transform.nilValue)
  }

  public func encode(_ value: Bool) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Int) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Int8) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Int16) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Int32) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Int64) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: UInt) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: UInt8) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: UInt16) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: UInt32) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: UInt64) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: String) throws {
    assertCanEncodeNewValue()
    storage.push(container: try box(value))
  }

  public func encode(_ value: Float) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }

  public func encode(_ value: Double) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }

  public func encode<T: Encodable>(_ value: T) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }
}

// MARK: - Concrete Value Representations

extension InternalValueEncoder {

  /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
  fileprivate func box(_ value: Bool) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Int) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Int8) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Int16) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Int32) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Int64) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UInt) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UInt8) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UInt16) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UInt32) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UInt64) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: String) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Float) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Double) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Decimal) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Data) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: URL) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: UUID) throws -> Value { return try Transform.box(value, encoder: self) }
  fileprivate func box(_ value: Date) throws -> Value { return try Transform.box(value, encoder: self) }

  fileprivate func box(_ dict: [String: Encodable]) throws -> Value? {
    let depth = storage.count
    let result = storage.pushKeyedContainer()
    do {
      for (key, value) in dict {
        codingPath.append(AnyCodingKey(stringValue: key, intValue: nil))
        defer { self.codingPath.removeLast() }
        result[key] = try box(value)
      }
    }
    catch {
      // If the value pushed a container before throwing, pop it back off to restore state.
      if storage.count > depth {
        _ = storage.popContainer()
      }

      throw error
    }

    // The top container should be a new container.
    guard storage.count > depth else {
      return nil
    }

    return storage.popContainer().value
  }

  fileprivate func box(_ value: Encodable) throws -> Value {
    return try box_(value) ?? Transform.emptyKeyedContainer
  }

  // This method is called "box_" instead of "box" to disambiguate it from the overloads. Because the return type here is different from all of the "box" overloads (and is more general), any "box" calls in here would call back into "box" recursively instead of calling the appropriate overload, which is not what we want.
  fileprivate func box_(_ value: Encodable) throws -> Value? {
    let type = Swift.type(of: value)
    if type == Date.self || type == NSDate.self {
      // Respect Date encoding strategy
      return try box(value as! Date)
    }
    else if type == Data.self || type == NSData.self {
      // Respect Data encoding strategy
      return try box(value as! Data)
    }
    else if type == URL.self || type == NSURL.self {
      // Encode URLs as single strings.
      return try box((value as! URL).absoluteString)
    }
    else if type == Decimal.self || type == NSDecimalNumber.self {
      // Encode Decimals as doubles.
      return try box(NSDecimalNumber(decimal: value as! Decimal).doubleValue)
    }
    else if value is ValueStringDictionaryEncodableMarker {
      return try box(value as! [String: Encodable])
    }

    // The value should request a container from the InternalValueEncoder.
    let depth = storage.count
    do {
      try value.encode(to: self)
    }
    catch {
      // If the value pushed a container before throwing, pop it back off to restore state.
      if storage.count > depth {
        _ = storage.popContainer()
      }

      throw error
    }

    // The top container should be a new container.
    guard storage.count > depth else {
      return nil
    }

    return storage.popContainer().value
  }
}

// MARK: - ValueReferencingEncoder

/// ValueReferencingEncoder is a special subclass of InternalValueEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
private class ValueReferencingEncoder<Value, Transform>: InternalValueEncoder<Value, Transform> where Transform: InternalEncoderTransform, Value == Transform.Value {
  typealias InternalValueEncoder = PotentCodables.InternalValueEncoder<Value, Transform>
  typealias UnkeyedContainer = PotentCodables.UnkeyedContainer<Value, Transform>
  typealias KeyedContainer = PotentCodables.KeyedContainer<Value, Transform>

  // MARK: Reference types.

  /// The type of container we're referencing.
  private enum Reference {
    /// Referencing a specific index in an array container.
    case unkeyed(UnkeyedContainer, Int)

    /// Referencing a specific key in a dictionary container.
    case keyed(KeyedContainer, String)
  }

  // MARK: - Properties

  /// The encoder we're referencing.
  fileprivate let encoder: InternalValueEncoder

  /// The container reference itself.
  private var reference: Reference

  // MARK: - Initialization

  /// Initializes `self` by referencing the given array container in the given encoder.
  fileprivate init(referencing encoder: InternalValueEncoder, at index: Int, wrapping unkeyed: UnkeyedContainer) {
    self.encoder = encoder
    reference = .unkeyed(unkeyed, index)
    super.init(options: encoder.options, codingPath: encoder.codingPath)

    codingPath.append(AnyCodingKey(index: index))
  }

  /// Initializes `self` by referencing the given dictionary container in the given encoder.
  fileprivate init(referencing encoder: InternalValueEncoder,
                   key: CodingKey, convertedKey: CodingKey, wrapping keyed: KeyedContainer) {
    self.encoder = encoder
    reference = .keyed(keyed, convertedKey.stringValue)
    super.init(options: encoder.options, codingPath: encoder.codingPath)

    codingPath.append(key)
  }

  // MARK: - Coding Path Operations

  fileprivate override var canEncodeNewValue: Bool {
    // With a regular encoder, the storage and coding path grow together.
    // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
    // We have to take this into account.
    return storage.count == codingPath.count - encoder.codingPath.count - 1
  }

  // MARK: - Deinitialization

  // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
  deinit {
    let value: Value
    switch self.storage.count {
    case 0: value = Transform.emptyKeyedContainer
    case 1: value = self.storage.popContainer().value
    default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
    }

    switch self.reference {
    case .unkeyed(let unkeyed, let index):
      unkeyed.insert(value, at: index)

    case .keyed(let keyed, let key):
      keyed[key] = value
    }
  }
}


private struct AnyContainer<Value> {

  fileprivate let container: Any
  private let valueAccessor: () -> Value

  fileprivate init<Container>(_ container: Container) where Container: PotentCodables.Container, Container.Value == Value {
    valueAccessor = { container.value }
    self.container = container
  }

  fileprivate var value: Value {
    return valueAccessor()
  }

}

private protocol Container {

  associatedtype Value: PotentCodables.Value

  var value: Value { get }
}

private struct ValueContainer<Value>: Container where Value: PotentCodables.Value {

  fileprivate var value: Value

}

private class KeyedContainer<Value, Transform>: Container where Transform: InternalEncoderTransform, Value == Transform.Value {

  fileprivate var backing: [String: Value] = [:]

  fileprivate subscript(key: String) -> Value? {
    get {
      return backing[key]
    }
    set {
      backing[key] = newValue
    }
  }

  fileprivate var value: Value { return Transform.keyedValuesToValue(backing) }

}

private protocol Nesting {

  associatedtype Value: PotentCodables.Value

  func finalize(_ value: Value)

}

private class UnkeyedContainer<Value, Transform>: Container where Transform: InternalEncoderTransform, Value == Transform.Value {

  fileprivate var backing: [Value] = []

  fileprivate var count: Int { return backing.count }

  fileprivate func append(_ newElement: Value) {
    backing.append(newElement)
  }

  fileprivate func insert(_ newElement: Value, at: Int) {
    backing.insert(newElement, at: at)
  }

  fileprivate subscript(index: Int) -> Value {
    get {
      return backing[index]
    }
    set {
      backing[index] = newValue
    }
  }

  fileprivate var value: Value { return Transform.unkeyedValuesToValue(backing) }

}

private struct KeyedNesting<Value, Transform>: Nesting where Transform: InternalEncoderTransform, Value == Transform.Value {

  fileprivate let parent: KeyedContainer<Value, Transform>
  fileprivate let key: String

  fileprivate init(_ parent: KeyedContainer<Value, Transform>, _ key: String) {
    self.parent = parent
    self.key = key
  }

  func finalize(_ value: Value) {
    parent[key] = value
  }

}

private struct UnkeyedNesting<Value, Transform>: Nesting where Transform: InternalEncoderTransform, Value == Transform.Value {

  fileprivate let parent: UnkeyedContainer<Value, Transform>
  fileprivate let index: Int

  fileprivate init(_ parent: UnkeyedContainer<Value, Transform>, _ index: Int) {
    self.parent = parent
    self.index = index
  }

  func finalize(_ value: Value) {
    parent[index] = value
  }

}

private class NestedKeyedContainer<N: Nesting, Value, Transform>: KeyedContainer<Value, Transform> where Transform: InternalEncoderTransform, Value == Transform.Value, N.Value == Value {

  fileprivate let nesting: N

  required init(_ nesting: N) {
    self.nesting = nesting
    super.init()
  }

  var currentValue: Value {
    return super.value
  }

  override var value: Value {
    let value = super.value
    nesting.finalize(value)
    return value
  }

}

private class NestedUnkeyedContainer<N: Nesting, Value, Transform>: UnkeyedContainer<Value, Transform> where Transform: InternalEncoderTransform, Value == Transform.Value, N.Value == Value {

  fileprivate let nesting: N

  required init(_ nesting: N) {
    self.nesting = nesting
    super.init()
  }

  var currentValue: Value {
    return super.value
  }

  override var value: Value {
    let value = super.value
    nesting.finalize(value)
    return value
  }

}

/// A marker protocol used to determine whether a value is a `String`-keyed `Dictionary`
/// containing `Encodable` values (in which case it should be exempt from key conversion strategies).
///
private protocol ValueStringDictionaryEncodableMarker {}

extension Dictionary: ValueStringDictionaryEncodableMarker where Key == String, Value: Encodable {}
