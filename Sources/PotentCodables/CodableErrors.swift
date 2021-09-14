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


public extension DecodingError {
  /// Returns a `.typeMismatch` error describing the expected type.
  ///
  /// - parameter path: The path of `CodingKey`s taken to decode a value of this type.
  /// - parameter expectation: The type expected to be encountered.
  /// - parameter reality: The value that was encountered instead of the expected type.
  /// - returns: A `DecodingError` with the appropriate path and debug description.
  static func typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
    let description = "Expected to decode \(expectation) but found \(typeDescription(of: reality)) instead."
    return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
  }

  /// Returns a description of the type of `value` appropriate for an error message.
  ///
  /// - parameter value: The value whose type to describe.
  /// - returns: A string describing `value`.
  /// - precondition: `value` is one of the types below.
  static func typeDescription(of value: Any) -> String {
    if value is NSNull {
      return "a null value"
    }
    else if value is NSNumber {
      return "a number"
    }
    else if value is String {
      return "a string/data"
    }
    else if value is [Any] {
      return "an array"
    }
    else if value is [String: Any] {
      return "a dictionary"
    }
    else {
      return "\(type(of: value))"
    }
  }
}
