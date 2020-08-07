//
//  Refs.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

/// Provides a static `typeKey` property that `Ref` and `EmbeddedRef`
/// use to determine which key to use when encoding/decoding the Swift
/// type name.
///
public protocol TypeKeyProvider {
  static var typeKey: AnyCodingKey { get }
}

/// Default type key provider using `@type` as the `typeKey`
///
/// - See Also: `TypeKeyProvider`
///
public struct DefaultTypeKey: TypeKeyProvider {
  public static var typeKey: AnyCodingKey = "@type"
}

/// Provides a static `valueKey` property that `Ref` and `EmbeddedRef`
/// use to determine which key to use when encoding/decoding a value.
///
public protocol ValueKeyProvider {
  static var valueKey: AnyCodingKey { get }
}

/// Default value key provider using `value` as the `valueKey`
///
/// - See Also: `ValueKeyProvider`
///
public struct DefaultValueKey: ValueKeyProvider {
  public static var valueKey: AnyCodingKey = "value"
}

/// Provides static functions for looking up types by id for deserialization
/// and generating type ids for types during serialization.
///
public protocol TypeIndex {
  static func findType(id: String) -> Any.Type?
  static func typeId(of: Any.Type) -> String
}

/// Default type index that uses a simple global map that can be updated
/// by clients.
///
/// Type ids are generated as the "simple" type name. E.g. a struct declared as
/// `struct MyType {}` will use the type id `MyType`.
///
/// The list of allowed types can be updated by using the method
/// `mapAllowedTypes(:)` which will generate an appropriate type id for each
/// provided type and assign them to the map of allowed types.
///
/// Note: The initial map of allowed types is empty and must be provided
/// by clients prior to using `Ref` or `EmbeddedRef`.
///
/// - See Also: `TypeIndex`
///
public struct DefaultTypeIndex: TypeIndex {
  
  fileprivate static var allowedTypes: [String: Any.Type] = [:]
  
  public static func mapAllowedTypes(_ types: [Decodable.Type]) {
    Self.allowedTypes = Dictionary(uniqueKeysWithValues: types.map { (key: Self.typeId(of: $0), value: $0) })
  }
  
  public static func findType(id: String) -> Any.Type? { allowedTypes[id] }
  public static func typeId(of type: Any.Type) -> String { "\(type)".split(separator: ".").last.map { String($0) }  ?? "\(type)" }
  
}


/// A decodable type for decoding general polymorphic types.
///
/// `Ref` relies upon the encoded value being wrapped in a keyed container that contains a
/// Swift type name in its key-value pairs. By default the key `@type` is used but this can be
/// customized.
///
/// # Expected Encoded Structure (JSON):
/// ```javascript
/// {"@type" : "MyValue", "value": {"name" : "Foo"}}
/// ```
///
/// Decoding a `Ref` instance will decode the value to its `value` property,
/// which can then be accesed in a number of ways.
///
/// # Example:
///
///     DefaultTypeIndex.mapAllowedTypes([MyValue.self])
///
///     myValue = container.decode(Ref.self).value as! MyValue
///
/// In the example, `MyValue` can be a concrete type or protocol, either works fine. Alternatively, the
/// `Ref.as(: Any.Type)` method can be used to require the value be of a specific
/// type and throw a decoding error if it is not, as in:
///
///     myValue = container.decode(Ref.self).as(MyValue.self)
///
///
/// # Customizing Keys:
/// The key used to store the type name defaults to `@type` and the key used to store the value
/// defaults to `value`. These can be customized by using the implementation type (`CustomRef`)
/// directly, passing a `TypeKeyProvider` and a `ValueKeyProvider` for each of the required keys:
///
///     typealias MyRef = CustomRef<MyTypeKey, MyValueKey>
///     myValue = container.decode(My.self).value
///
/// # Customizing Type Lookup:
/// Types are saved by transforming them into a type id (aka name). During decoding by type ids are
/// transformed back into the requested types. To enable extensability, and ensure security during
/// decoding, type ids are looked up using a type index. A type index simply generates type ids
/// for types and provides the ability to lookup a type for a matching id.
///
/// The default type index, used by `Ref`, is `DefaultTypeIndex`. The index has a simple global map
/// of allowed types to their type ids. `DefaultTypeIndex` uses the simple module local type name
/// for each type (see `DefaultTypeIndex` for specifics).
///
/// - Note: `DefaultTypeIndex`'s map of allowed types is initially empty and will not provide any
///  types during decoding. You must explicitly updated the map of allowed types using
/// `DefaultTypeIndex.mapAllowedTypes(:)`.
///
/// A new type index implementation can be provided by using `CustomRef` explicity and providing a
/// cusom type index:
///
///     typealias MyRef = CustomRef<DefaultTypeKey, DefaultValueKey, MyTypeIndex>
///
///
///
/// - See Also: `Ref.Value`
/// - See Also: `EmbeddedRef`
/// - See Also: `CustomRef<>`
///
public typealias Ref = CustomRef<DefaultTypeKey, DefaultValueKey, DefaultTypeIndex>


/// The implementation type for `Ref` types.
///
/// This type is meant to be used only when the key(s) need to be customized. They are customized
/// by providing custom `KeyProvider` implementations for each required generic parameter.
///
/// - Parameters:
///   - TI: Type parameter that provides type id generation & lookup.
///   - TKP: Type parameter that provides the type key to use.
///   - VKP: Type parameter that provides the value key to use.
///
/// - See Also: `Ref`
/// - See Also: `KeyProvider`
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
  /// related `Ref.Error` if it fails.
  ///
  /// The method is for convenience when decoding to easily retrieve the value
  /// as the required type and throw encoded related errors.
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


  /// An encodable value that wraps a value with the type name for decoding using `Ref`.
  ///
  /// During encoding `EncodedValue` is wrapped in a keyed container that includes the required
  /// Swift type-name value required for decoding by `Ref`. Usage is simple, just wrap your to-be-
  /// encoded value in this type and pass to any encoding container's encode method.
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
  /// - See Also: `Ref`
  /// - See Also: `CustomRef`
  ///
  public struct Value<EncodedValue: Encodable>: Encodable {

    public let value: EncodedValue

    public init(_ value: EncodedValue) {
      self.value = value
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: AnyCodingKey.self)
      try container.encode(TI.self.typeId(of: EncodedValue.self), forKey: TKP.typeKey)
      try container.encode(value, forKey: VKP.valueKey)
    }

  }

}


/// A decodable type for decoding polymorphic types that include an embedded type name value.
///
/// `EmbeddedRef` relies upon the encoded value including a type name embedded in the keyed
/// container it is decoding. By default the key `@type` is used but this can be customized.
///
/// # Expected Encoded Structure (JSON):
/// ```javascript
/// {"@type" : "MyValue", "name" : "Foo"}
/// ```
///
/// Decoding an `EmbeddedRef` instance will decode the value to its `value` property,
/// which can then be accesed in a number of ways.
///
/// # Example:
///
///     DefaultTypeIndex.mapAllowedTypes([MyValue.self])
///
///     myValue = container.decode(EmbeddedRef.self).value as! MyValue
///
/// In the example, `MyValue` can be a concrete type or protocol, either works fine. Alternatively, the
/// `Ref.as(: Any.Type)` method can be used to require the value be of a specific
/// type and throw a decoding error if it is not, as in:
///
///     myValue = container.decode(EmbeddedRef.self).as(MyValue.self)
///
///
/// # Customizing Type Key:
/// The key used to store the type name defaults to `@type`. This can be customized by using the
/// implementation type (`CustomEmbeddedRef`) directly, passing a `KeyProvider`:
///
///     typealias MyRef = CustomEmbeddedRef<MyTypeKey>
///     myValue = container.decode(My.self).value
///
///
/// # Customizing Type Lookup:
/// Types are saved by transforming them into a type id (aka name). During decoding by type ids are
/// transformed back into the requested types. To enable extensability, and ensure security during
/// decoding, type ids are looked up using a type index. A type index simply generates type ids
/// for types and provides the ability to lookup a type for a matching id.
///
/// The default type index, used by `Ref`, is `DefaultTypeIndex`. The index has a simple global map
/// of allowed types to their type ids. `DefaultTypeIndex` uses the simple module local type name
/// for each type (see `DefaultTypeIndex` for specifics).
///
/// - Note: `DefaultTypeIndex`'s map of allowed types is initially empty and will not provide any
///  types during decoding. You must explicitly updated the map of allowed types using
/// `DefaultTypeIndex.mapAllowedTypes(:)`.
///
/// A new type index implementation can be provided by using `CustomRef` explicity and providing a
/// cusom type index:
///
///     typealias MyRef = CustomEmbeddedRef<DefaultTypeKey, MyTypeIndex>
///
///
/// # Requires:
///   Keyed Container
///
///   Due to the type name being embedded in the key-value pairs of, the
///   encoded value **must** be a keyed container, it cannot be an unkeyed or
///   single-value container.
///
///   `Ref` is provided to support encoding/decoding of "general" values of any
///   structure.
///
///
/// - See Also: `EmbeddedRef.Value`
/// - See Also: `Ref`
/// - See Also: `CustomEmbeddedRef<>`
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
/// - See Also: `EmbeddedRef`
/// - See Also: `KeyProvider`
///
public struct CustomEmbeddedRef<TKP: TypeKeyProvider, TI: TypeIndex>: Decodable {

  /// The decoded value
  public let value: Any

  public init(from decoder: Decoder) throws {
    let refType = try Refs.decodeType(from: decoder, forKey: TKP.typeKey, using: TI.self)
    value = try refType.init(from: decoder)
  }

  /// Method attempts a conversion to the provided type `V` and throws a
  /// related `EmbeddedRef.Error` if it fails.
  ///
  /// The method is for convenience when decoding to easily retrieve the value
  /// as the required type and throw encoded related errors.
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
  /// using `EmbeddedRef`.
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
  /// - See Also: `EmbeddedRef`
  /// - See Also: `CustomEmbeddedRef`
  ///
  public struct Value<EncodedValue: Encodable>: Encodable {

    public let value: EncodedValue

    public init(_ value: EncodedValue) {
      self.value = value
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: AnyCodingKey.self)
      try container.encode(TI.self.typeId(of: EncodedValue.self), forKey: TKP.typeKey)
      try value.encode(to: encoder)
    }

  }

}


/// Utilities support `Ref` and `EmbeddedRef`
///
public struct Refs {

  enum Error: Swift.Error {
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
  public static func decodeType(from decoder: Decoder, forKey key: AnyCodingKey, using index: TypeIndex.Type) throws -> Decodable.Type {
    let container = try decoder.container(keyedBy: AnyCodingKey.self)
    let typeId = try container.decode(String.self, forKey: key)
    guard let type = index.findType(id: typeId) else {
      throw Error.typeNotFound("\(typeId) could not be found using index \(index)")
    }
    guard let refType = type as? Decodable.Type else {
      fatalError("Type '\(String(describing: type))' does not conform to Decodable")
    }
    return refType
  }

}
