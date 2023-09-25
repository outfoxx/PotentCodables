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

  mutating func decodeContents(_ type: Bool.Type) throws -> [Bool] {
    var elements: [Bool] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: String.Type) throws -> [String] {
    var elements: [String] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int8.Type) throws -> [Int8] {
    var elements: [Int8] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int16.Type) throws -> [Int16] {
    var elements: [Int16] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int32.Type) throws -> [Int32] {
    var elements: [Int32] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int64.Type) throws -> [Int64] {
    var elements: [Int64] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }


  mutating func decodeContents(_ type: UInt8.Type) throws -> [UInt8] {
    var elements: [UInt8] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt16.Type) throws -> [UInt16] {
    var elements: [UInt16] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt32.Type) throws -> [UInt32] {
    var elements: [UInt32] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt64.Type) throws -> [UInt64] {
    var elements: [UInt64] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Float.Type) throws -> [Float] {
    var elements: [Float] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Double.Type) throws -> [Double] {
    var elements: [Double] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents<Value: Decodable>(_ type: Value.Type) throws -> [Value] {
    var elements: [Value] = []
    while !self.isAtEnd {
      elements.append(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Bool.Type) throws -> Set<Bool> {
    var elements: Set<Bool> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: String.Type) throws -> Set<String> {
    var elements: Set<String> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int8.Type) throws -> Set<Int8> {
    var elements: Set<Int8> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int16.Type) throws -> Set<Int16> {
    var elements: Set<Int16> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int32.Type) throws -> Set<Int32> {
    var elements: Set<Int32> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Int64.Type) throws -> Set<Int64> {
    var elements: Set<Int64> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }


  mutating func decodeContents(_ type: UInt8.Type) throws -> Set<UInt8> {
    var elements: Set<UInt8> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt16.Type) throws -> Set<UInt16> {
    var elements: Set<UInt16> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt32.Type) throws -> Set<UInt32> {
    var elements: Set<UInt32> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: UInt64.Type) throws -> Set<UInt64> {
    var elements: Set<UInt64> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Float.Type) throws -> Set<Float> {
    var elements: Set<Float> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents(_ type: Double.Type) throws -> Set<Double> {
    var elements: Set<Double> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents<Value: Decodable & Hashable>(_ type: Value.Type) throws -> Set<Value> {
    var elements: Set<Value> = []
    while !self.isAtEnd {
      elements.insert(try decode(type))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Bool {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == String {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Int8 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Int16 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Int32 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Int64 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == UInt8 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == UInt16 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == UInt32 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == UInt64 {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Float {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source == Double {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> [Transformer.Target] where Transformer.Source: Decodable {
    var elements: [Transformer.Target] = []
    while !self.isAtEnd {
      elements.append(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Bool {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == String {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Int8 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Int16 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Int32 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Int64 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == UInt8 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == UInt16 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == UInt32 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == UInt64 {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Float {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source == Double {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

  mutating func decodeContents<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws
  -> Set<Transformer.Target> where Transformer.Source: Decodable {
    var elements: Set<Transformer.Target> = []
    while !self.isAtEnd {
      elements.insert(try decode(using: transformer))
    }
    return elements
  }

}

public extension SingleValueDecodingContainer {

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Bool {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == String {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Int64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt8 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt16 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt32 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == UInt64 {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Float {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
    .Target where Transformer.Source == Double {
    return try transformer.decode(decode(Transformer.Source.self))
  }

  func decode<Transformer: ValueDecodingTransformer>(using transformer: Transformer) throws -> Transformer
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

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Bool, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == String, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Int, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Int8, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Int16, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Int32, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Int64, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt8, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt16, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt32, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == UInt64, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Float, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source == Double, S.Element == Transformer.Target {
    try encode(contentsOf: values.map { try transformer.encode($0) })
  }

  mutating func encode<S: Sequence, Transformer: ValueEncodingTransformer>(
    contentsOf values: S,
    using transformer: Transformer
  ) throws where Transformer.Source: Encodable, S.Element == Transformer.Target {
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


// MARK: Top Level Support

public extension TopLevelDecoder {

  func decode<Transformer: ValueDecodingTransformer>(from input: Input, using transformer: Transformer) throws
    -> Transformer.Target where Transformer.Source: Decodable {
    return try transformer.decode(decode(Transformer.Source.self, from: input))
  }

}

public extension TopLevelEncoder {

  func encode<Transformer: ValueEncodingTransformer>(_ value: Transformer.Target, using transformer: Transformer) throws
    -> Output where Transformer.Source: Encodable {
    return try encode(transformer.encode(value))
  }

}
