//
//  JSONSerialization.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public enum JSONSerialization {

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

    case invalidData(InvalidData, position: Int)
    case unexpectedEndOfStream
    case fragmentDisallowed
    case noValue
  }

  public struct ReadingOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let allowFragments = ReadingOptions(rawValue: 1 << 0)
  }

  public static func json(from data: Data, options: ReadingOptions = []) throws -> JSON {
    return try data.withUnsafeBytes { ptr in
      let source = JSONReader.UTF8Source(buffer: ptr.bindMemory(to: UInt8.self))
      guard let (json, _) = try JSONReader(source: source).parseValue(0, options: options) else {
        throw Error.noValue
      }

      switch json {
      case .object: return json
      case .array: return json
      case let json where options.contains(.allowFragments): return json
      default: throw Error.fragmentDisallowed
      }
    }
  }

  public static func json(from data: String, options: ReadingOptions = []) throws -> JSON {
    var data = data
    return try data.withUTF8 { ptr in
      let source = JSONReader.UTF8Source(buffer: ptr)
      guard let (json, _) = try JSONReader(source: source).parseValue(0, options: options) else {
        throw Error.noValue
      }

      switch json {
      case .object: return json
      case .array: return json
      case let json where options.contains(.allowFragments): return json
      default: throw Error.fragmentDisallowed
      }
    }
  }


  public struct WritingOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let sortedKeys = WritingOptions(rawValue: 1 << 0)
    public static let prettyPrinted = WritingOptions(rawValue: 1 << 1)
    public static let escapeSlashes = WritingOptions(rawValue: 1 << 2)
  }

  public static func data(from json: JSON, options: WritingOptions = []) throws -> Data {
    guard let data = try string(from: json, options: options).data(using: .utf8) else {
      throw DecodingError
        .dataCorrupted(
          DecodingError
            .Context(codingPath: [], debugDescription: "String cannot be decoded as UTF-8", underlyingError: nil)
        )
    }
    return data
  }

  public static func string(from json: JSON, options: WritingOptions = []) throws -> String {
    var output = String()
    var writer = JSONWriter(escapeSlashes: options.contains(.escapeSlashes),
                            pretty: options.contains(.prettyPrinted),
                            sortedKeys: options.contains(.sortedKeys)) {
      output.append($0)
    }

    try writer.serialize(json)

    return output
  }

}
