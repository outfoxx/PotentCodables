//
//  ValueTransformerProviding.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public protocol InitializableValueEncodingTransformer: ValueEncodingTransformer {
  init() throws
}

public protocol ValueEncodingTransformerProviding {

  associatedtype EncodingTransformer: InitializableValueEncodingTransformer where EncodingTransformer.Target == Self

}


public protocol InitializableValueDecodingTransformer: ValueDecodingTransformer {
  init() throws
}

public protocol ValueDecodingTransformerProviding {

  associatedtype DecodingTransformer: InitializableValueDecodingTransformer where DecodingTransformer.Target == Self

}


public typealias InitializableValueCodingTransformer = InitializableValueEncodingTransformer & InitializableValueDecodingTransformer

public protocol ValueCodingTransformerProviding: ValueEncodingTransformerProviding, ValueDecodingTransformerProviding
 where EncodingTransformer == CodingTransformer, DecodingTransformer == CodingTransformer {

  associatedtype CodingTransformer: InitializableValueCodingTransformer where CodingTransformer.Target == Self

}


public extension KeyedDecodingContainer {

  func decode<Value: ValueDecodingTransformerProviding>(_ type: Value.Type, forKey key: Key) throws -> Value {
    return try decode(forKey: key, using: Value.DecodingTransformer())
  }

}

public extension UnkeyedDecodingContainer {

  mutating func decode<Value: ValueDecodingTransformerProviding>(_ type: Value.Type) throws -> Value {
    return try decode(using: Value.DecodingTransformer())
  }

  mutating func decodeContents<Value: ValueDecodingTransformerProviding>(_ type: Value.Type) throws -> [Value] {
    return try decodeContents(using: Value.DecodingTransformer())
  }

}

public extension SingleValueDecodingContainer {

  mutating func decode<Value: ValueDecodingTransformerProviding>(_ type: Value.Type) throws -> Value {
    return try decode(using: Value.DecodingTransformer())
  }

}

public extension KeyedEncodingContainer {

  mutating func encode<Value: ValueEncodingTransformerProviding>(_ value: Value, forKey key: Key) throws {
    return try encode(value, forKey: key, using: Value.EncodingTransformer())
  }

}

public extension UnkeyedEncodingContainer {

  mutating func encode<Value: ValueEncodingTransformerProviding>(_ value: Value) throws {
    return try encode(value, using: Value.EncodingTransformer())
  }

  mutating func encode<S: Sequence>(contentsOf values: S) throws where S.Element: ValueEncodingTransformerProviding {
    return try encode(contentsOf: values, using: S.Element.EncodingTransformer())
  }

}

public extension SingleValueEncodingContainer {

  mutating func encode<Value: ValueEncodingTransformerProviding>(_ value: Value) throws {
    return try encode(value, using: Value.EncodingTransformer())
  }

}

public extension TopLevelDecoder {

  func decode<Value: ValueDecodingTransformerProviding>(_ type: Value.Type, from input: Input) throws -> Value {
    return try decode(from: input, using: Value.DecodingTransformer())
  }

}

public extension TopLevelEncoder {

  func encode<Value: ValueEncodingTransformerProviding>(_ value: Value) throws -> Output {
    return try encode(value, using: Value.EncodingTransformer())
  }

}
