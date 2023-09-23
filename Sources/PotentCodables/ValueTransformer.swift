//
//  ValueTransformer.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public typealias ValueCodingTransformer = ValueEncodingTransformer & ValueDecodingTransformer


// MARK: Decoding Transformer

public protocol ValueDecodingTransformer {

  associatedtype Source: Decodable
  associatedtype Target

  func decode(_ value: Source) throws -> Target

}

public extension KeyedDecodingContainer {

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Bool {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == String {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Int8 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Int16 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Int32 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Int64 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == UInt8 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == UInt16 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == UInt32 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == UInt64 {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Float {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source == Double {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decode<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target where Transformer.Source: Decodable {
    return try transformer.decode(decode(Transformer.Source.self, forKey: key))
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Bool {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == String {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Int8 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Int16 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Int32 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Int64 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == UInt8 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == UInt16 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == UInt32 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == UInt64 {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Float {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source == Double {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  func decodeIfPresent<Transformer: ValueDecodingTransformer>(
    forKey key: Key,
    using transformer: Transformer
  ) throws -> Transformer.Target? where Transformer.Source: Decodable {
    try decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

}

public extension UnkeyedDecodingContainer {

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Bool {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == String {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Float {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Double {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source: Decodable {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Bool {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == String {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Int8 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Int16 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Int32 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Int64 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == UInt8 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == UInt16 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == UInt32 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == UInt64 {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Float {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source == Double {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
    -> Transformer.Target? where Transformer.Source: Decodable {
    try decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

}

public extension SingleValueDecodingContainer {

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Bool {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == String {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Float {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Double {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source: Decodable {
    return try transformer.decode(decode(Transformer.Source.self))
  }

}



// MARK: Encoding Transformer

public protocol ValueEncodingTransformer {

  associatedtype Source: Codable
  associatedtype Target

  func encode(_ value: Target) throws -> Source

}


public extension KeyedEncodingContainer {

  mutating func encodeConditional<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Target: AnyObject, Transformer.Source: AnyObject & Encodable {
    try encodeConditional(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Bool {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == String {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int8 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int16 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int32 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int64 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64 {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Float {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Double {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable {
    try encode(transformer.encode(value), forKey: key)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Bool {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == String {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int8 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int16 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int32 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Int64 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64 {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Float {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source == Double {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

  mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    forKey key: Key,
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable {
    guard let value = value else {
      try encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try encode(value, forKey: key, using: transformer)
  }

}

public extension UnkeyedEncodingContainer {

  mutating func encodeConditional<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Target: AnyObject, Transformer.Source: AnyObject & Encodable {
    try encodeConditional(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Bool {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == String {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Int8 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Int16 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Int32 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Int64 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64 {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Float {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source == Double {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target?,
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable {
    if let value = try value.map({ try transformer.encode($0) }) {
      try encode(value)
    }
    else {
      try encodeNil()
    }
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Bool {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == String {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Int {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Int8 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Int16 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Int32 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Int64 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == UInt {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64 {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Float {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source == Double {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    contentsOf values: [Transformer.Target],
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

}

public extension SingleValueEncodingContainer {

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Bool {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == String {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Int {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Int8 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Int16 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Int32 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Int64 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64 {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Float {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source == Double {
    try encode(transformer.encode(value))
  }

  mutating func encode<Transformer: ValueEncodingTransformer>(
    _ value: Transformer.Target,
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable {
    try encode(transformer.encode(value))
  }

}
