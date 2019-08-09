//
//  Errors.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

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

    let debugDescription = "Unable to encode \(valueDescription) directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded."
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

    let debugDescription = "Unable to encode \(valueDescription) directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded."
    return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
  }
}
