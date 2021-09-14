//
//  EncoderSupport.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// All encoders support encoding to their native values.
///
public protocol EncodesToTree {

  associatedtype Value: PotentCodables.Value

  /// Encodes the value  to a native value.
  ///
  /// - Parameters:
  ///   - value: Value to encode
  /// - Returns: Encoded value tree.
  ///
  func encodeTree<T: Encodable>(_ value: T) throws -> Value

}

/// Encoders that target binary formats support encoding to data.
///
public protocol EncodesToData: EncodesToTree {

  /// Encodes the value to binary data.
  ///
  /// - Parameters:
  ///   - value: Value to encode
  /// - Returns: Encoded binary data.
  ///
  func encode<T: Encodable>(_ value: T) throws -> Data

}

/// Encoders that target text formats support encoding to strings
/// and encoding to data using a default string encoding.
///
public protocol EncodesToString: EncodesToData {

  /// Encodes the encodable `value` to a string.
  ///
  /// - Parameters:
  ///   - value: Value to encode
  /// - Returns: Encoded text.
  ///
  func encodeString<T: Encodable>(_ value: T) throws -> String

}
