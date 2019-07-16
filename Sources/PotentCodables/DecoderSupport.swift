//
//  DecoderSupport.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// All encoders support decoding from their native values.
///
public protocol DecodesFromTree {

  associatedtype Value: PotentCodables.Value

  /// Decodes a value from a native value tree.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: Native value tree to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decodeTree<T: Decodable>(_ type: T.Type, from value: Value) throws -> T

  /// Decodes a value from a native value tree if a non-nil value is represented.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: Native value tree to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decodeTreeIfPresent<T: Decodable>(_ type: T.Type, from value: Value) throws -> T?

}

/// Decoders for binary formats support decoding from data.
///
public protocol DecodesFromData: DecodesFromTree {

  /// Decodes a value from binary data.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: Data to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T

  /// Decodes a value from binary data if a non-nil value is represented.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: Data to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: Data) throws -> T?

}

/// Decoders for text formats support decoding from strings and from
/// data using a string encoding.
///
/// # String Encoding
/// For text formats where the specification allows supporting multiple string encodings,
/// the string-encoding in use must be detectable during the decode.
///
public protocol DecodesFromString: DecodesFromData {

  /// Decodes a value from a string.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: String to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decode<T: Decodable>(_ type: T.Type, from data: String) throws -> T

  /// Decodes a value from a string if a non-nil value is represented.
  ///
  /// - Parameters:
  ///   - type: Decodable type to decode an instance of.
  ///   - value: String to decode from.
  /// - Returns: Instace of `type` decoded from `value`.
  ///
  func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: String) throws -> T?

}
