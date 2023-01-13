//
//  JSONWriter.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

//  NOTE:
//  This file is heavily inspired by the JSONWriter class found in the JSONSerialization.swift
//  file of the open-souce Swift foundation libraries located at
//  https://github.com/apple/swift-corelibs-foundation.
//
//  Although this work is substantially different enough to be considered a unique work, credit
//  to the inspiring work and its authors is hereby given.
//

import Foundation


struct JSONWriter {

  enum Error: Swift.Error {
    case invalidNumber(Double)
  }

  var indent = 0
  let pretty: Bool
  let sortedKeys: Bool
  let writer: (String?) -> Void

  init(pretty: Bool = false, sortedKeys: Bool = false, writer: @escaping (String?) -> Void) {
    self.pretty = pretty
    self.sortedKeys = sortedKeys
    self.writer = writer
  }

  mutating func serialize(_ object: JSON) throws {
    switch object {
    case .null:
      try serializeNull()
    case .string(let string):
      try serializeString(string)
    case .bool(let bool):
      writer(bool.description)
    case .number(let number):
      try serializeFloat(number.value)
    case .array(let array):
      try serializeArray(array)
    case .object(let dict):
      try serializeDictionary(dict)
    }
  }

  func serializeString(_ str: String) throws {
    writer("\"")
    for scalar in str.unicodeScalars {
      switch scalar {
      case "\"":
        writer("\\\"") // U+0022 quotation mark
      case "\\":
        writer("\\\\") // U+005C reverse solidus
      case "/":
        writer("\\/") // U+002F solidus
      case "\u{8}":
        writer("\\b") // U+0008 backspace
      case "\u{c}":
        writer("\\f") // U+000C form feed
      case "\n":
        writer("\\n") // U+000A line feed
      case "\r":
        writer("\\r") // U+000D carriage return
      case "\t":
        writer("\\t") // U+0009 tab
      case "\u{0}" ... "\u{f}":
        writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
      case "\u{10}" ... "\u{1f}":
        writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
      default:
        writer(String(scalar))
      }
    }
    writer("\"")
  }

  private func serializeFloat(_ str: String) throws {
    var str = str
    if str.hasSuffix(".0") {
      str.removeLast(2)
    }
    writer(str)
  }

  mutating func serializeArray(_ array: [JSON]) throws {
    writer("[")
    if pretty {
      writer("\n")
      incAndWriteIndent()
    }

    var first = true
    for elem in array {
      if first {
        first = false
      }
      else if pretty {
        writer(",\n")
        writeIndent()
      }
      else {
        writer(",")
      }
      try serialize(elem)
    }
    if pretty {
      writer("\n")
      decAndWriteIndent()
    }
    writer("]")
  }

  mutating func serializeDictionary(_ dict: [String: JSON]) throws {
    writer("{")
    if pretty {
      writer("\n")
      incAndWriteIndent()
    }

    var first = true

    func serializeDictionaryElement(key: String, value: JSON) throws {
      if first {
        first = false
      }
      else if pretty {
        writer(",\n")
        writeIndent()
      }
      else {
        writer(",")
      }

      try serializeString(key)

      writer(pretty ? " : " : ":")

      try serialize(value)
    }

    if sortedKeys {
      let elems = dict.sorted(by: {
        let options: String.CompareOptions = [.numeric, .caseInsensitive, .forcedOrdering]
        let range: Range<String.Index> = $0.key.startIndex ..< $0.key.endIndex

        return $0.key.compare($1.key, options: options, range: range, locale: NSLocale.system) == .orderedAscending
      })
      for elem in elems {
        try serializeDictionaryElement(key: elem.key, value: elem.value)
      }
    }
    else {
      for (key, value) in dict {
        try serializeDictionaryElement(key: key, value: value)
      }
    }

    if pretty {
      writer("\n")
      decAndWriteIndent()
    }
    writer("}")
  }

  func serializeNull() throws {
    writer("null")
  }

  let indentAmount = 2

  mutating func incAndWriteIndent() {
    indent += indentAmount
    writeIndent()
  }

  mutating func decAndWriteIndent() {
    indent -= indentAmount
    writeIndent()
  }

  func writeIndent() {
    for _ in 0 ..< indent {
      writer(" ")
    }
  }

}
