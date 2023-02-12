//
//  Refs.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

/// Provides a static ``typeKey`` property that ``Ref`` and ``EmbeddedRef``
/// use to determine which key to use when encoding/decoding the Swift
/// type name.
///
public protocol TypeKeyProvider {
  static var typeKey: AnyCodingKey { get }
}

/// Default type key provider using `@type` as the ``typeKey``
///
public struct DefaultTypeKey: TypeKeyProvider {
  public static var typeKey: AnyCodingKey = "@type"
}

/// Provides a static ``valueKey`` property that `Ref` and ``EmbeddedRef``
/// use to determine which key to use when encoding/decoding a value.
///
public protocol ValueKeyProvider {
  static var valueKey: AnyCodingKey { get }
}

/// Default value key provider using `value` as the ``valueKey``
///
public struct DefaultValueKey: ValueKeyProvider {
  public static var valueKey: AnyCodingKey = "value"
}

/// Provides static functions for looking up types by id for decoding
/// and generating type ids for types during encoding.
///
public protocol TypeIndex {
  static func findType(id: String) -> Decodable.Type?
  static func typeId(of: Any.Type) -> String
}

/// Default type index that uses a simple global map that can be updated
/// by clients.
///
/// Type ids are generated as the "simple" type name. E.g. a struct declared as
/// `struct MyType {}` will use the type id `MyType`.
///
/// The list of allowed types can be updated by using the method
/// `setAllowedTypes(:)` which will generate an appropriate type id for each
/// provided type and assign them to the map of allowed types.
///
/// Note: The initial map of allowed types is empty and must be provided
/// by clients prior to using ``Ref`` or ``EmbeddedRef``.
///
public struct DefaultTypeIndex: TypeIndex {

  fileprivate static var allowedTypes: [String: Decodable.Type] = [
    typeId(of: Bool.self): Bool.self,
    typeId(of: Int.self): Int.self,
    typeId(of: Int8.self): Int8.self,
    typeId(of: Int16.self): Int16.self,
    typeId(of: Int32.self): Int32.self,
    typeId(of: Int64.self): Int64.self,
    typeId(of: UInt.self): UInt.self,
    typeId(of: UInt8.self): UInt8.self,
    typeId(of: UInt16.self): UInt16.self,
    typeId(of: UInt32.self): UInt32.self,
    typeId(of: UInt64.self): UInt64.self,
    typeId(of: Float16.self): Float16.self,
    typeId(of: Float.self): Float.self,
    typeId(of: Double.self): Double.self,
    typeId(of: Decimal.self): Decimal.self,
    typeId(of: String.self): String.self,
    typeId(of: URL.self): URL.self,
    typeId(of: UUID.self): UUID.self,
    typeId(of: Date.self): Date.self,
    typeId(of: Bool?.self): Bool?.self,
    typeId(of: Int?.self): Int?.self,
    typeId(of: Int8?.self): Int8?.self,
    typeId(of: Int16?.self): Int16?.self,
    typeId(of: Int32?.self): Int32?.self,
    typeId(of: Int64?.self): Int64?.self,
    typeId(of: UInt?.self): UInt?.self,
    typeId(of: UInt8?.self): UInt8?.self,
    typeId(of: UInt16?.self): UInt16?.self,
    typeId(of: UInt32?.self): UInt32?.self,
    typeId(of: UInt64?.self): UInt64?.self,
    typeId(of: Float16?.self): Float16?.self,
    typeId(of: Float?.self): Float?.self,
    typeId(of: Double?.self): Double?.self,
    typeId(of: Decimal?.self): Decimal?.self,
    typeId(of: String?.self): String?.self,
    typeId(of: URL?.self): URL?.self,
    typeId(of: UUID?.self): UUID?.self,
    typeId(of: Date?.self): Date?.self,
    typeId(of: [Bool].self): [Bool].self,
    typeId(of: [Int].self): [Int].self,
    typeId(of: [Int8].self): [Int8].self,
    typeId(of: [Int16].self): [Int16].self,
    typeId(of: [Int32].self): [Int32].self,
    typeId(of: [Int64].self): [Int64].self,
    typeId(of: [UInt].self): [UInt].self,
    typeId(of: [UInt8].self): [UInt8].self,
    typeId(of: [UInt16].self): [UInt16].self,
    typeId(of: [UInt32].self): [UInt32].self,
    typeId(of: [UInt64].self): [UInt64].self,
    typeId(of: [Float16].self): [Float16].self,
    typeId(of: [Float].self): [Float].self,
    typeId(of: [Double].self): [Double].self,
    typeId(of: [Decimal].self): [Decimal].self,
    typeId(of: [String].self): [String].self,
    typeId(of: [URL].self): [URL].self,
    typeId(of: [UUID].self): [UUID].self,
    typeId(of: [Date].self): [Date].self,
    typeId(of: [Bool]?.self): [Bool]?.self,
    typeId(of: [Int]?.self): [Int]?.self,
    typeId(of: [Int8]?.self): [Int8]?.self,
    typeId(of: [Int16]?.self): [Int16]?.self,
    typeId(of: [Int32]?.self): [Int32]?.self,
    typeId(of: [Int64]?.self): [Int64]?.self,
    typeId(of: [UInt]?.self): [UInt]?.self,
    typeId(of: [UInt8]?.self): [UInt8]?.self,
    typeId(of: [UInt16]?.self): [UInt16]?.self,
    typeId(of: [UInt32]?.self): [UInt32]?.self,
    typeId(of: [UInt64]?.self): [UInt64]?.self,
    typeId(of: [Float16]?.self): [Float16]?.self,
    typeId(of: [Float]?.self): [Float]?.self,
    typeId(of: [Double]?.self): [Double]?.self,
    typeId(of: [Decimal]?.self): [Decimal]?.self,
    typeId(of: [String]?.self): [String]?.self,
    typeId(of: [URL]?.self): [URL]?.self,
    typeId(of: [UUID]?.self): [UUID]?.self,
    typeId(of: [Date]?.self): [Date]?.self,
    typeId(of: [String: Bool].self): [String: Bool].self,
    typeId(of: [String: Int].self): [String: Int].self,
    typeId(of: [String: Int8].self): [String: Int8].self,
    typeId(of: [String: Int16].self): [String: Int16].self,
    typeId(of: [String: Int32].self): [String: Int32].self,
    typeId(of: [String: Int64].self): [String: Int64].self,
    typeId(of: [String: UInt].self): [String: UInt].self,
    typeId(of: [String: UInt8].self): [String: UInt8].self,
    typeId(of: [String: UInt16].self): [String: UInt16].self,
    typeId(of: [String: UInt32].self): [String: UInt32].self,
    typeId(of: [String: UInt64].self): [String: UInt64].self,
    typeId(of: [String: Float16].self): [String: Float16].self,
    typeId(of: [String: Float].self): [String: Float].self,
    typeId(of: [String: Double].self): [String: Double].self,
    typeId(of: [String: Decimal].self): [String: Decimal].self,
    typeId(of: [String: String].self): [String: String].self,
    typeId(of: [String: URL].self): [String: URL].self,
    typeId(of: [String: UUID].self): [String: UUID].self,
    typeId(of: [String: Date].self): [String: Date].self,
    typeId(of: [String: Bool]?.self): [String: Bool]?.self,
    typeId(of: [String: Int]?.self): [String: Int]?.self,
    typeId(of: [String: Int8]?.self): [String: Int8]?.self,
    typeId(of: [String: Int16]?.self): [String: Int16]?.self,
    typeId(of: [String: Int32]?.self): [String: Int32]?.self,
    typeId(of: [String: Int64]?.self): [String: Int64]?.self,
    typeId(of: [String: UInt]?.self): [String: UInt]?.self,
    typeId(of: [String: UInt8]?.self): [String: UInt8]?.self,
    typeId(of: [String: UInt16]?.self): [String: UInt16]?.self,
    typeId(of: [String: UInt32]?.self): [String: UInt32]?.self,
    typeId(of: [String: UInt64]?.self): [String: UInt64]?.self,
    typeId(of: [String: Float16]?.self): [String: Float16]?.self,
    typeId(of: [String: Float]?.self): [String: Float]?.self,
    typeId(of: [String: Double]?.self): [String: Double]?.self,
    typeId(of: [String: Decimal]?.self): [String: Decimal]?.self,
    typeId(of: [String: String]?.self): [String: String]?.self,
    typeId(of: [String: URL]?.self): [String: URL]?.self,
    typeId(of: [String: UUID]?.self): [String: UUID]?.self,
    typeId(of: [String: Date]?.self): [String: Date]?.self,
  ]

  /// Set the allowed types to the given array after mapping them using ``DefaultTypeIndex/mapAllowedTypes(_:)``.
  public static func setAllowedTypes(_ types: [Decodable.Type]) {
    Self.allowedTypes = mapAllowedTypes(types)
  }

  /// Set the allowed types to the given array after mapping them using ``DefaultTypeIndex/mapAllowedTypes(_:)``.
  public static func addAllowedTypes(_ types: [Decodable.Type]) {
    Self.allowedTypes = Self.allowedTypes.merging(mapAllowedTypes(types)) { $1 }
  }

  /// Maps the given array of types to their generated type id and returns the dictionary.
  public static func mapAllowedTypes(_ types: [Decodable.Type]) -> [String: Decodable.Type] {
    return Dictionary(uniqueKeysWithValues: types.map { (key: Self.typeId(of: $0), value: $0) })
  }

  /// Find the associated tyoe for the given type id.
  public static func findType(id: String) -> Decodable.Type? { allowedTypes[id] }

  /// Find the type id of the given type.
  public static func typeId(of type: Any.Type) -> String {
    "\(type)".split(separator: ".").last.map { String($0) } ?? "\(type)"
  }

}


/// A decodable type for decoding general polymorphic types.
///
/// ``Ref`` relies upon the encoded value being wrapped in a keyed container that contains a
/// Swift type name in its key-value pairs. By default the key `@type` is used but this can be
/// customized.
///
/// # Expected Encoded Structure (JSON):
/// ```javascript
/// {"@type" : "MyValue", "value": {"name" : "Foo"}}
/// ```
///
/// Decoding a ``Ref`` instance will decode the value to its `value` property,
/// which can then be accesed in a number of ways.
///
/// # Example:
///
///     DefaultTypeIndex.setAllowedTypes([MyValue.self])
///
///     myValue = container.decode(Ref.self).value as! MyValue
///
/// In the example, `MyValue` can be a concrete type or protocol, either works fine. Alternatively, the
/// ``CustomRef/as(_:)`` method can be used to require the value be of a specific type and throw a decoding
/// related error if it is not, as in:
///
///     myValue = container.decode(Ref.self).as(MyValue.self)
///
public typealias Ref = CustomRef<DefaultTypeKey, DefaultValueKey, DefaultTypeIndex>


/// The implementation type for ``Ref`` types.
///
/// This type is meant to be used only when the key(s) need to be customized. They are customized
/// by providing custom ``TypeKeyProvider``, ``ValueKeyProvider`` or ``TypeIndex`` implementations.
///
/// - Parameters:
///   - TI: Type parameter that provides type id generation & lookup.
///   - TKP: Type parameter that provides the type key to use.
///   - VKP: Type parameter that provides the value key to use.
///
public struct CustomRef<TKP: TypeKeyProvider, VKP: ValueKeyProvider, TI: TypeIndex>: Decodable {

  /// The decoded value
  public let value: Any

  public init(from decoder: Decoder) throws {
    let refType = try Refs.decodeType(from: decoder, forKey: TKP.typeKey, using: TI.self)
    let container = try decoder.container(keyedBy: AnyCodingKey.self)
    value = try refType.init(from: KeyedNestedDecoder(key: VKP.valueKey, container: container, decoder: decoder))
  }

  /// Method attempts a conversion to the provided type `V` and throws a
  /// related ``Refs/Error`` if it fails.
  ///
  /// The method is for convenience when decoding to easily retrieve the value
  /// as the required type and throw codable related errors.
  ///
  /// - Parameters:
  ///   - type: The required type to retrieve the decoded value as
  /// - Returns: The value as the required type
  /// - Throws: `invalidValue` if the type cannot be cast to the required value
  ///
  public func `as`<V>(_ type: V.Type) throws -> V {
    guard let value = value as? V else {
      throw Refs.Error.invalidValue("\(self.value) is not of required type \(type)")
    }
    return value
  }


  /// An encodable value that wraps a value with the type name for decoding using ``Ref``.
  ///
  /// During encoding the value is wrapped in a keyed container that includes the required
  /// type id of the Swift type of the value required for decoding by ``Ref``. Usage is simple,
  ///  just wrap your to-be-encoded value in this type and pass to any encoding container's encode method.
  ///
  /// # Example:
  ///
  ///     try container.encode(Ref.Value(myValue))
  ///
  /// # Generated Encoded Structure (JSON):
  /// ```javascript
  /// {"@type" : "MyApp.VyValue", "value": {"name" : "Foo"}}
  /// ```
  ///
  public struct Value: Encodable {

    public let value: Any?

    public init<T>(_ value: T?) {
      precondition(value == nil || value is Encodable)
      self.value = value
    }

    public init(_ value: Any) {
      precondition(value is Encodable)
      self.value = value
    }

    public func encode(to encoder: Encoder) throws {
      if let value = value {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encode(TI.typeId(of: type(of: value)), forKey: TKP.typeKey)
        let encodableValue = (value as? Encodable).unsafelyUnwrapped
        try encodableValue.encode(to: KeyedNestedEncoder(key: VKP.valueKey, container: container, encoder: encoder))
      }
      else {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
      }
    }

  }

}


/// A decodable type for decoding polymorphic types that include an embedded type name value.
///
/// ``EmbeddedRef`` relies upon the encoded value including a type name embedded in the keyed
/// container it is decoding. By default the key `@type` is used but this can be customized.
///
/// # Expected Encoded Structure (JSON):
/// ```javascript
/// {"@type" : "MyValue", "name" : "Foo"}
/// ```
///
/// Decoding an ``EmbeddedRef`` instance will decode the value to its `value` property,
/// which can then be accesed in a number of ways.
///
/// # Example:
///
///     DefaultTypeIndex.setAllowedTypes([MyValue.self])
///
///     myValue = container.decode(EmbeddedRef.self).value as! MyValue
///
/// In the example, `MyValue` can be a concrete type or protocol, either works fine. Alternatively, the
/// ``CustomEmbeddedRef/as(_:)`` method can be used to require the value be of a specific type and throw
///  a decoding related error if it is not, as in:
///
///     myValue = container.decode(EmbeddedRef.self).as(MyValue.self)
///
/// # Requires:
///   Keyed Container
///
///   Due to the type name being embedded in the key-value pairs of value's container, the
///   encoded value **must** be a keyed container, it cannot be an unkeyed or
///   single-value container.
///
///   ``Ref`` is provided to support encoding/decoding of "general" values of any
///   structure.
///
public typealias EmbeddedRef = CustomEmbeddedRef<DefaultTypeKey, DefaultTypeIndex>

/// The implementation type for `EmbeddedRef` types.
///
/// This type is meant to be used only when the type key needs to be customized. It is customized
/// by provided a custom `KeyProvider` implementation as a generic parameter.
///
/// - Parameters:
///   - KP: Type parameter that provides the type key to use.
///
public struct CustomEmbeddedRef<TKP: TypeKeyProvider, TI: TypeIndex>: Decodable {

  /// The decoded value
  public let value: Any

  public init(from decoder: Decoder) throws {
    let refType = try Refs.decodeType(from: decoder, forKey: TKP.typeKey, using: TI.self)
    value = try refType.init(from: decoder)
  }

  /// Method attempts a conversion to the provided type `V` and throws a
  /// related ``Refs/Error`` if it fails.
  ///
  /// The method is for convenience when decoding to easily retrieve the value
  /// as the required type or throw decoding related errors.
  ///
  /// - Parameters:
  ///   - type: The required type to retrieve the decoded value as
  /// - Returns: The value as the required type
  /// - Throws: `invalidValue` if the type cannot be cast to the required value
  ///
  public func `as`<V>(_ type: V.Type) throws -> V {
    guard let value = value as? V else {
      throw Refs.Error.invalidValue("\(self.value) is not of required type \(type)")
    }
    return value
  }


  /// An encodable value that embeds the encoded value with the type name required for decoding
  /// using ``EmbeddedRef``.
  ///
  /// During encoding the Swift type name of `EncodedValue` is embed into the keyed container
  /// produced by `EnncodedValue` allowing it to be decoded with `EmbeddedRef`. Usage is
  /// simple, just wrap your to-be-encoded value in this type and pass to any encoding container's
  /// encode method.
  ///
  /// # Example:
  ///
  ///     try container.encode(Ref.Value(myValue))
  ///
  /// # Generated Encoded Structure (JSON):
  /// ```javascript
  /// {"@type" : "MyApp.VyValue", "name" : "Foo"}
  /// ```
  ///
  public struct Value: Encodable {

    public let value: Any?

    public init<T>(_ value: T?) {
      precondition(value == nil || value is Encodable)
      self.value = value
    }

    public init(_ value: Any) {
      precondition(value is Encodable)
      self.value = value
    }

    public func encode(to encoder: Encoder) throws {
      if let value = value {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encode(TI.typeId(of: type(of: value)), forKey: TKP.typeKey)
        try (value as? Encodable).unsafelyUnwrapped.encode(to: encoder)
      }
      else {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
      }
    }

  }

}


/// Utilities support ``Ref`` and ``EmbeddedRef``
///
public enum Refs {

  public enum Error: Swift.Error {
    case typeNotFound(String)
    case invalidValue(String)
  }

  /// Decodes a type from the `decoder` using the `key`
  ///
  /// - Parameters:
  ///   - decoder: `Decoder` to decode the `key` from
  ///   - key: CodingKey used to decode the type name
  ///   - using: Type index to use for type lookup
  /// - Returns: A `Decodable` type reference
  ///
  public static func decodeType(
    from decoder: Decoder,
    forKey key: AnyCodingKey,
    using index: TypeIndex.Type
  ) throws -> Decodable.Type {
    let container = try decoder.container(keyedBy: AnyCodingKey.self)
    let typeId = try container.decode(String.self, forKey: key)
    guard let type = index.findType(id: typeId) else {
      throw Error.typeNotFound("\(typeId) could not be found using index \(index)")
    }
    return type
  }

}
