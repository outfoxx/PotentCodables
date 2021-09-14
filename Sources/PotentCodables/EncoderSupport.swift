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
