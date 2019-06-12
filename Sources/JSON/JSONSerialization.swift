//
//  JSONSerialization.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/12/19.
//

import Foundation


public struct JSONSerialization {

  public enum Error : Swift.Error {
    case fragmentDisallowed
    case noValue
  }

  public struct ReadingOptions : OptionSet {
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


  public struct WritingOptions : OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let sortedKeys = WritingOptions(rawValue: 1 << 0)
    public static let prettyPrinted = WritingOptions(rawValue: 1 << 1)
  }

  public static func data(from json: JSON, options: WritingOptions = []) throws -> Data {
    var output = String()
    var writer = JSONWriter(pretty: options.contains(.prettyPrinted), sortedKeys: options.contains(.sortedKeys)) {
      guard let str = $0 else { return }
      output.append(str)
    }

    try writer.serialize(json)

    return output.data(using: .utf8)!
  }

  private init() {}

}
