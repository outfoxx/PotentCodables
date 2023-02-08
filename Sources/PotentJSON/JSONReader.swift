//
//  JSONReader.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

//
//  NOTE:
//  This file is heavily inspired by the JSONReader class found in the JSONSerialization.swift
//  file of the open-souce Swift foundation libraries located at
//  https://github.com/apple/swift-corelibs-foundation.
//
//  Although this work is substantially different enough to be considered a unique work, credit
//  to the inspiring work and its authors is hereby given.
//

import Foundation


internal struct JSONReader {

  public enum Error: Swift.Error {

    public enum InvalidData {
      case invalidString
      case invalidEscapeSequence
      case invalidNumber
      case invalidArray
      case expectedObjectKey
      case expectedObjectSeparator
      case expectedObjectValue
      case expectedArraySeparator
    }

    case unexpectedEndOfStream
    case invalidData(InvalidData, position: Int)
  }

  static let whitespaceASCII: [UInt8] = [
    0x09, // Horizontal tab
    0x0A, // Line feed or New line
    0x0D, // Carriage return
    0x20, // Space
  ]

  enum Structure {
    static let beginArray: UInt8 = 0x5B // [
    static let endArray: UInt8 = 0x5D // ]
    static let beginObject: UInt8 = 0x7B // {
    static let endObject: UInt8 = 0x7D // }
    static let nameSeparator: UInt8 = 0x3A // :
    static let valueSeparator: UInt8 = 0x2C // ,
    static let quotationMark: UInt8 = 0x22 // "
    static let escape: UInt8 = 0x5C // \
  }

  typealias Index = Int
  typealias IndexDistance = Int

  struct UTF8Source {
    let buffer: UnsafeBufferPointer<UInt8>

    init(buffer: UnsafeBufferPointer<UInt8>) {
      self.buffer = buffer
    }

    func takeASCII(_ input: Index) -> (UInt8, Index)? {
      guard hasNext(input) else {
        return nil
      }
      return (buffer[input] < 0x80) ? (buffer[input], input + 1) : nil
    }

    func takeString(_ begin: Index, end: Index) throws -> String {
      let byteLength = begin.distance(to: end)

      guard
        let baseAddress = buffer.baseAddress,
        let chunk = String(data: Data(bytes: baseAddress.advanced(by: begin), count: byteLength), encoding: .utf8)
      else {
        throw Error.invalidData(.invalidString, position: distanceFromStart(begin))
      }
      return chunk
    }

    func hasNext(_ input: Index) -> Bool {
      return input + 1 <= buffer.endIndex
    }

    func distanceFromStart(_ index: Index) -> IndexDistance {
      return buffer.startIndex.distance(to: index)
    }
  }

  let source: UTF8Source

  func consumeWhitespace(_ input: Index) -> Index? {
    var index = input
    while let (char, nextIndex) = source.takeASCII(index), JSONReader.whitespaceASCII.contains(char) {
      index = nextIndex
    }
    return index
  }

  func consumeStructure(_ ascii: UInt8, input: Index) throws -> Index? {
    return try consumeWhitespace(input).flatMap(consumeASCII(ascii)).flatMap(consumeWhitespace)
  }

  func consumeASCII(_ ascii: UInt8) -> (Index) throws -> Index? {
    return { (input: Index) throws -> Index? in
      switch self.source.takeASCII(input) {
      case nil:
        throw Error.unexpectedEndOfStream
      case (let taken, let index)? where taken == ascii:
        return index
      default:
        return nil
      }
    }
  }

  func consumeASCIISequence(_ sequence: String, input: Index) throws -> Index? {
    var index = input
    for scalar in sequence.unicodeScalars {
      guard let nextIndex = try consumeASCII(UInt8(scalar.value))(index) else {
        return nil
      }
      index = nextIndex
    }
    return index
  }

  func takeMatching(_ match: @escaping (UInt8) -> Bool) -> ([Character], Index) -> ([Character], Index)? {
    return { input, index in
      guard let (byte, index) = self.source.takeASCII(index), match(byte) else {
        return nil
      }
      return (input + [Character(UnicodeScalar(byte))], index)
    }
  }

  // MARK: - String Parsing

  func parseString(_ input: Index) throws -> (String, Index)? {
    guard let beginIndex = try consumeWhitespace(input).flatMap(consumeASCII(Structure.quotationMark)) else {
      return nil
    }
    var chunkIndex: Int = beginIndex
    var currentIndex: Int = chunkIndex

    var output: String = ""
    while source.hasNext(currentIndex) {
      guard let (ascii, index) = source.takeASCII(currentIndex) else {
        currentIndex += 1
        continue
      }
      switch ascii {
      case Structure.quotationMark:
        output += try source.takeString(chunkIndex, end: currentIndex)
        return (output, index)
      case Structure.escape:
        output += try source.takeString(chunkIndex, end: currentIndex)
        if let (escaped, nextIndex) = try parseEscapeSequence(index) {
          output += escaped
          chunkIndex = nextIndex
          currentIndex = nextIndex
          continue
        }
        else {
          throw Error.invalidData(.invalidEscapeSequence, position: source.distanceFromStart(currentIndex))
        }
      default:
        currentIndex = index
      }
    }
    throw Error.invalidData(.invalidString, position: beginIndex)
  }

  func parseEscapeSequence(_ input: Index) throws -> (String, Index)? {
    guard let (byte, index) = source.takeASCII(input) else {
      throw Error.invalidData(.invalidEscapeSequence, position: source.distanceFromStart(input))
    }
    let output: String
    switch byte {
    case 0x22: output = "\""
    case 0x5C: output = "\\"
    case 0x2F: output = "/"
    case 0x62: output = "\u{08}" // \b
    case 0x66: output = "\u{0C}" // \f
    case 0x6E: output = "\u{0A}" // \n
    case 0x72: output = "\u{0D}" // \r
    case 0x74: output = "\u{09}" // \t
    case 0x75: return try parseUnicodeSequence(index)
    default: return nil
    }
    return (output, index)
  }

  func parseUnicodeSequence(_ input: Index) throws -> (String, Index)? {

    guard let (codeUnit, index) = parseCodeUnit(input) else {
      return nil
    }

    let isLeadSurrogate = UTF16.isLeadSurrogate(codeUnit)
    let isTrailSurrogate = UTF16.isTrailSurrogate(codeUnit)

    guard isLeadSurrogate || isTrailSurrogate else {
      // The code units that are neither lead surrogates nor trail surrogates
      // form valid unicode scalars.
      guard let scalar = UnicodeScalar(codeUnit) else {
        throw Error.invalidData(.invalidEscapeSequence, position: source.distanceFromStart(input))
      }
      return (String(scalar), index)
    }

    // Surrogates must always come in pairs.
    guard isLeadSurrogate else {
      throw Error.invalidData(.invalidEscapeSequence, position: source.distanceFromStart(input))
    }

    guard
      let (trailCodeUnit, finalIndex) = try consumeASCIISequence("\\u", input: index).flatMap(parseCodeUnit),
      UTF16.isTrailSurrogate(trailCodeUnit)
    else {
      throw Error.invalidData(.invalidEscapeSequence, position: source.distanceFromStart(input))
    }

    return (String(UTF16.decode(UTF16.EncodedScalar([codeUnit, trailCodeUnit]))), finalIndex)
  }

  func isHexChr(_ byte: UInt8) -> Bool {
    return (byte >= 0x30 && byte <= 0x39)
      || (byte >= 0x41 && byte <= 0x46)
      || (byte >= 0x61 && byte <= 0x66)
  }

  func parseCodeUnit(_ input: Index) -> (UTF16.CodeUnit, Index)? {
    let hexParser = takeMatching(isHexChr)
    guard let (result, index) = hexParser([], input).flatMap(hexParser).flatMap(hexParser).flatMap(hexParser),
          let value = Int(String(result), radix: 16)
    else {
      return nil
    }
    return (UTF16.CodeUnit(value), index)
  }

  // MARK: - Number parsing

  private static let zero = UInt8(ascii: "0")
  private static let one = UInt8(ascii: "1")
  private static let nine = UInt8(ascii: "9")
  private static let minus = UInt8(ascii: "-")
  private static let plus = UInt8(ascii: "+")
  private static let lowerExponent = UInt8(ascii: "e")
  private static let upperExponent = UInt8(ascii: "E")
  private static let decimalSeparator = UInt8(ascii: ".")
  private static let allDigits = (zero ... nine)
  private static let oneToNine = (one ... nine)

  private static let numberCodePoints: [UInt8] = {
    var numberCodePoints = Array(zero ... nine)
    numberCodePoints.append(contentsOf: [decimalSeparator, minus, plus, lowerExponent, upperExponent])
    return numberCodePoints
  }()


  func parseNumber(_ input: Index) throws -> (JSON.Number, Index)? {

    var isNegative = false
    var string = ""
    var isInteger = true
    var exponent = 0
    var index = input
    var ascii: UInt8 = 0 // set by nextASCII()

    /// Validate the input is a valid JSON number, also gather the following
    /// about the input: isNegative, isInteger, the exponent and if it is +/-,
    /// and finally the count of digits including excluding an '.'
    ///
    func checkJSONNumber() throws -> Bool {
      // Return true if the next character is any one of the valid JSON number characters
      func nextASCII() -> Bool {
        guard let (char, nextIndex) = source.takeASCII(index),
              JSONReader.numberCodePoints.contains(char) else { return false }

        index = nextIndex
        ascii = char
        string.append(Character(UnicodeScalar(ascii)))
        return true
      }

      // Consume as many digits as possible and return with the next non-digit
      // or nil if end of string.
      func readDigits() -> UInt8? {
        while let (char, nextIndex) = source.takeASCII(index) {
          if !JSONReader.allDigits.contains(char) {
            return char
          }
          string.append(Character(UnicodeScalar(char)))
          index = nextIndex
        }
        return nil
      }

      guard nextASCII() else { return false }

      if ascii == JSONReader.minus {
        isNegative = true
        guard nextASCII() else { return false }
      }

      if JSONReader.oneToNine.contains(ascii) {
        guard let char = readDigits() else { return true }
        ascii = char
        if [JSONReader.decimalSeparator, JSONReader.lowerExponent, JSONReader.upperExponent].contains(ascii) {
          guard nextASCII()
          else { return false } // There should be at least one char as readDigits didn't remove the '.eE'
        }
      }
      else if ascii == JSONReader.zero {
        guard nextASCII() else { return true }
      }
      else {
        throw Error.invalidData(.invalidNumber, position: source.distanceFromStart(input))
      }

      if ascii == JSONReader.decimalSeparator {
        isInteger = false
        guard readDigits() != nil else { return true }
        guard nextASCII() else { return true }
      }
      else if JSONReader.allDigits.contains(ascii) {
        throw Error.invalidData(.invalidNumber, position: source.distanceFromStart(input))
      }

      guard ascii == JSONReader.lowerExponent || ascii == JSONReader.upperExponent else {
        // End of valid number characters
        return true
      }

      // Process the exponent
      isInteger = false
      guard nextASCII() else { return false }
      if ascii == JSONReader.minus || ascii == JSONReader.plus {
        guard nextASCII() else { return false }
      }
      guard JSONReader.allDigits.contains(ascii) else { return false }
      exponent = Int(ascii - JSONReader.zero)
      while nextASCII() {
        guard JSONReader.allDigits.contains(ascii) else { return false } // Invalid exponent character
        exponent = (exponent * 10) + Int(ascii - JSONReader.zero)
        if exponent > 324 {
          // Exponent is too large to store in a Double
          return false
        }
      }
      return true
    }

    guard try checkJSONNumber() else { return nil }

    return (.init(string, isInteger: isInteger, isNegative: isNegative), index)
  }

  // MARK: - Value parsing

  func parseValue(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (JSON, Index)? {
    if let (value, parser) = try parseString(input) {
      return (.string(value), parser)
    }
    else if let parser = try consumeASCIISequence("true", input: input) {
      return (.bool(true), parser)
    }
    else if let parser = try consumeASCIISequence("false", input: input) {
      return (.bool(false), parser)
    }
    else if let parser = try consumeASCIISequence("null", input: input) {
      return (.null, parser)
    }
    else if let (object, parser) = try parseObject(input, options: opt) {
      return (.object(object), parser)
    }
    else if let (array, parser) = try parseArray(input, options: opt) {
      return (.array(array), parser)
    }
    else if let (number, parser) = try parseNumber(input) {
      return (.number(number), parser)
    }
    return nil
  }

  // MARK: - Object parsing

  func parseObject(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (JSON.Object, Index)? {
    guard let beginIndex = try consumeStructure(Structure.beginObject, input: input) else {
      return nil
    }
    var index = beginIndex
    var output: JSON.Object = [:]
    while true {
      if let finalIndex = try consumeStructure(Structure.endObject, input: index) {
        return (output, finalIndex)
      }
      else if let (key, value, nextIndex) = try parseObjectMember(index, options: opt) {
        output[key] = value

        if let finalParser = try consumeStructure(Structure.endObject, input: nextIndex) {
          return (output, finalParser)
        }
        else if let nextIndex = try consumeStructure(Structure.valueSeparator, input: nextIndex) {
          index = nextIndex
          continue
        }
        else {
          throw Error.invalidData(.expectedObjectSeparator, position: nextIndex)
        }
      }
      throw Error.invalidData(.expectedObjectKey, position: index)
    }
  }

  func parseObjectMember(
    _ input: Index,
    options opt: JSONSerialization.ReadingOptions
  ) throws -> (String, JSON, Index)? {
    guard let (name, index) = try parseString(input) else {
      throw Error.invalidData(.expectedObjectKey, position: source.distanceFromStart(input))
    }
    guard let separatorIndex = try consumeStructure(Structure.nameSeparator, input: index) else {
      throw Error.invalidData(.expectedObjectSeparator, position: source.distanceFromStart(index))
    }
    guard let (value, finalIndex) = try parseValue(separatorIndex, options: opt) else {
      throw Error.invalidData(.expectedObjectValue, position: source.distanceFromStart(separatorIndex))
    }

    return (name, value, finalIndex)
  }

  // MARK: - Array parsing

  func parseArray(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (JSON.Array, Index)? {
    guard let beginIndex = try consumeStructure(Structure.beginArray, input: input) else {
      return nil
    }
    var index = beginIndex
    var output: JSON.Array = []
    while true {
      if let finalIndex = try consumeStructure(Structure.endArray, input: index) {
        return (output, finalIndex)
      }

      if let (value, nextIndex) = try parseValue(index, options: opt) {
        output.append(value)

        if let finalIndex = try consumeStructure(Structure.endArray, input: nextIndex) {
          return (output, finalIndex)
        }
        else if let nextIndex = try consumeStructure(Structure.valueSeparator, input: nextIndex) {
          index = nextIndex
          continue
        }
        else {
          throw Error.invalidData(.expectedArraySeparator, position: nextIndex)
        }
      }
      throw Error.invalidData(.invalidArray, position: source.distanceFromStart(index))
    }
  }
}
