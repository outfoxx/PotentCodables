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


public struct JSONSerialization {

  public enum Error: Swift.Error {
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
  }

  public static func data(from json: JSON, options: WritingOptions = []) throws -> Data {
    return try string(from: json, options: options).data(using: .utf8)!
  }

  public static func string(from json: JSON, options: WritingOptions = []) throws -> String {
    var output = String()
    var writer = JSONWriter(pretty: options.contains(.prettyPrinted), sortedKeys: options.contains(.sortedKeys)) {
      guard let str = $0 else { return }
      output.append(str)
    }

    try writer.serialize(json)

    return output
  }

  private init() {}

}
