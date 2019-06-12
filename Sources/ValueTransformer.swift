//
//  ValueTransformer.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/14/19.
//

import Foundation


public typealias ValueCodingTransformer = ValueEncodingTransformer & ValueDecodingTransformer


// MARK: Decoding Transformer

public protocol ValueDecodingTransformer {

  associatedtype Source
  associatedtype Target

  func decode(_ value: Source) throws -> Target

}

extension KeyedDecodingContainer {

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Bool {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == String {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int8 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int16 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int32 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int64 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt8 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt16 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt32 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt64 {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Float {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Double {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decode<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                            using transformer: Transformer) throws -> Transformer.Target where Transformer.Source : Decodable {
    return try transformer.decode(self.decode(Transformer.Source.self, forKey: key))
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Bool {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == String {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int8 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int16 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int32 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int64 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt8 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt16 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt32 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt64 {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Float {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Double {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

  public func decodeIfPresent<Transformer: ValueDecodingTransformer>(forKey key: Key,
                                                                     using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source : Decodable {
    try self.decodeIfPresent(Transformer.Source.self, forKey: key).flatMap { try transformer.decode($0) }
  }

}

extension UnkeyedDecodingContainer {

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Bool {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == String {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int8 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int16 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int32 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int64 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt8 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt16 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt32 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt64 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Float {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Double {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source : Decodable {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Bool {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == String {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int8 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int16 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int32 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Int64 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt8 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt16 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt32 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == UInt64 {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Float {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source == Double {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

  public mutating func decodeIfPresent<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target? where Transformer.Source : Decodable {
    try self.decodeIfPresent(Transformer.Source.self).flatMap { try transformer.decode($0) }
  }

}

extension SingleValueDecodingContainer {

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Bool {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == String {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int8 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int16 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int32 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Int64 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt8 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt16 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt32 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == UInt64 {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Float {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source == Double {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

  public mutating func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer.Target where Transformer.Source : Decodable {
    return try transformer.decode(self.decode(Transformer.Source.self))
  }

}



// MARK: Encoding Transformer

public protocol ValueEncodingTransformer {

  associatedtype Source
  associatedtype Target

  func encode(_ value: Target) throws -> Source

}


extension KeyedEncodingContainer {

  public mutating func encodeConditional<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                                forKey key: Key,
                                                                                using transformer: Transformer) throws where Transformer.Target : AnyObject, Transformer.Source : AnyObject & Encodable {
    try self.encodeConditional(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Bool {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == String {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int8 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int16 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int32 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int64 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt8 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt16 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt32 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt64 {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Float {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source == Double {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     forKey key: Key,
                                                                     using transformer: Transformer) throws where Transformer.Source : Encodable {
    try self.encode(transformer.encode(value), forKey: key)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Bool {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == String {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Int8 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Int16 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Int32 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Int64 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == UInt8 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == UInt16 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == UInt32 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == UInt64 {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Float {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source == Double {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

  public mutating func encodeIfPresent<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target?,
                                                                              forKey key: Key,
                                                                              using transformer: Transformer) throws where Transformer.Source : Encodable {
    guard let value = value else {
      try self.encodeIfPresent(nil as Transformer.Source?, forKey: key)
      return
    }

    try self.encode(value, forKey: key, using: transformer)
  }

}

extension UnkeyedEncodingContainer {

  public mutating func encodeConditional<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                                using transformer: Transformer) throws where Transformer.Target : AnyObject, Transformer.Source : AnyObject & Encodable {
    try self.encodeConditional(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Bool {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == String {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int8 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int16 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int32 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int64 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt8 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt16 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt32 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt64 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Float {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Double {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source : Encodable {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Bool {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == String {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Int8 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Int16 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Int32 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Int64 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt8 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt16 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt32 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt64 {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Float {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source == Double {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(contentsOf values: [Transformer.Target],
                                                                     using transformer: Transformer) throws where Transformer.Source : Encodable {
    try self.encode(contentsOf: values.map { try transformer.encode($0) })
  }

}

extension SingleValueEncodingContainer {

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Bool {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     transformer: Transformer) throws where Transformer.Source == String {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int8 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int16 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int32 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Int64 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt8 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt16 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt32 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == UInt64 {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Float {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source == Double {
    try self.encode(transformer.encode(value))
  }

  public mutating func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target,
                                                                     using transformer: Transformer) throws where Transformer.Source : Encodable {
    try self.encode(transformer.encode(value))
  }

}
