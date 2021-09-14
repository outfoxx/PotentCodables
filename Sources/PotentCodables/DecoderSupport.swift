/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
