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


internal extension EncodingError {
  /// Returns a `.invalidValue` error describing the given invalid floating-point value.
  ///
  ///
  /// - parameter value: The value that was invalid to encode.
  /// - parameter path: The path of `CodingKey`s taken to encode this value.
  /// - returns: An `EncodingError` with the appropriate path and debug description.
  static func invalidFloatingPointValue<T: FloatingPoint>(_ value: T, at codingPath: [CodingKey]) -> EncodingError {
    let valueDescription: String
    if value == T.infinity {
      valueDescription = "\(T.self).infinity"
    }
    else if value == -T.infinity {
      valueDescription = "-\(T.self).infinity"
    }
    else {
      valueDescription = "\(T.self).nan"
    }

    let debugDescription =
      """
      Unable to encode \(valueDescription) directly in JSON. \
      Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
      """
    return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
  }

  /// Returns a `.invalidValue` error describing the given invalid floating-point value.
  ///
  ///
  /// - parameter value: The value that was invalid to encode.
  /// - parameter path: The path of `CodingKey`s taken to encode this value.
  /// - returns: An `EncodingError` with the appropriate path and debug description.
  static func invalidFloatingPointValue(_ value: Decimal, at codingPath: [CodingKey]) -> EncodingError {
    let valueDescription: String
    if value.isInfinite, value.sign == .plus {
      valueDescription = "\(Decimal.self).infinity"
    }
    else if value.isInfinite, value.sign == .minus {
      valueDescription = "-\(Decimal.self).infinity"
    }
    else {
      valueDescription = "\(Decimal.self).nan"
    }

    let debugDescription =
      """
      Unable to encode \(valueDescription) directly in JSON. \
      Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
      """
    return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
  }
}
