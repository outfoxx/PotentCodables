//
//  KeyStrategy.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

/// The strategy to use for automatically changing the value of keys before encoding.
public enum KeyEncodingStrategy {
  /// Use the keys specified by each type. This is the default strategy.
  case useDefaultKeys

  /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to the payload.
  ///
  /// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
  /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
  ///
  /// Converting from camel case to snake case:
  /// 1. Splits words at the boundary of lower-case to upper-case
  /// 2. Inserts `_` between words
  /// 3. Lowercases the entire string
  /// 4. Preserves starting and ending `_`.
  ///
  /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
  ///
  /// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
  case convertToSnakeCase

  /// Provide a custom conversion to the encoded key from the keys specified by the encoded types.
  /// The full path to the current encoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before encoding.
  /// If the result of the conversion is a duplicate key, then only one value will be present in the result.
  case custom((_ codingPath: [CodingKey]) -> CodingKey)

  internal static func _convertToSnakeCase(_ stringKey: String) -> String {
    guard stringKey.count > 0 else { return stringKey }

    var words: [Range<String.Index>] = []
    // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
    //
    // myProperty -> my_property
    // myURLProperty -> my_url_property
    //
    // We assume, per Swift naming conventions, that the first character of the key is lowercase.
    var wordStart = stringKey.startIndex
    var searchRange = stringKey.index(after: wordStart) ..< stringKey.endIndex

    // Find next uppercase character
    while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
      let untilUpperCase = wordStart ..< upperCaseRange.lowerBound
      words.append(untilUpperCase)

      // Find next lowercase character
      searchRange = upperCaseRange.lowerBound ..< searchRange.upperBound
      guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
        // There are no more lower case letters. Just end here.
        wordStart = searchRange.lowerBound
        break
      }

      // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
      let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
      if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
        // The next character after capital is a lower case character and therefore not a word boundary.
        // Continue searching for the next upper case for the boundary.
        wordStart = upperCaseRange.lowerBound
      }
      else {
        // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
        let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
        words.append(upperCaseRange.lowerBound ..< beforeLowerIndex)

        // Next word starts at the capital before the lowercase we just found
        wordStart = beforeLowerIndex
      }
      searchRange = lowerCaseRange.upperBound ..< searchRange.upperBound
    }
    words.append(wordStart ..< searchRange.upperBound)
    let result = words.map { range in
      stringKey[range].lowercased()
    }.joined(separator: "_")
    return result
  }
}


/// The strategy to use for automatically changing the value of keys before decoding.
public enum KeyDecodingStrategy {

  /// Use the keys specified by each type. This is the default strategy.
  case useDefaultKeys

  /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
  ///
  /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
  ///
  /// Converting from snake case to camel case:
  /// 1. Capitalizes the word starting after each `_`
  /// 2. Removes all `_`
  /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
  /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
  ///
  /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
  case convertFromSnakeCase

  /// Provide a custom conversion from the key in the encoded `Value` to the keys specified by the decoded types.
  /// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
  /// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
  case custom(([CodingKey]) -> CodingKey)


  static func _convertFromSnakeCase(_ stringKey: String) -> String {
    guard !stringKey.isEmpty else { return stringKey }

    // Find the first non-underscore character
    guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
      // Reached the end without finding an _
      return stringKey
    }

    // Find the last non-underscore character
    var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
    while lastNonUnderscore > firstNonUnderscore, stringKey[lastNonUnderscore] == "_" {
      stringKey.formIndex(before: &lastNonUnderscore)
    }

    let keyRange = firstNonUnderscore ... lastNonUnderscore
    let leadingUnderscoreRange = stringKey.startIndex ..< firstNonUnderscore
    let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore) ..< stringKey.endIndex

    let components = stringKey[keyRange].split(separator: "_")
    let joinedString: String
    if components.count == 1 {
      // No underscores in key, leave the word as is - maybe already camel cased
      joinedString = String(stringKey[keyRange])
    }
    else {
      joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
    }

    // Do a cheap isEmpty check before creating and appending potentially empty strings
    let result: String
    if leadingUnderscoreRange.isEmpty, trailingUnderscoreRange.isEmpty {
      result = joinedString
    }
    else if !leadingUnderscoreRange.isEmpty, !trailingUnderscoreRange.isEmpty {
      // Both leading and trailing underscores
      result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
    }
    else if !leadingUnderscoreRange.isEmpty {
      // Just leading
      result = String(stringKey[leadingUnderscoreRange]) + joinedString
    }
    else {
      // Just trailing
      result = joinedString + String(stringKey[trailingUnderscoreRange])
    }
    return result
  }

}
