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


/// Convenience API for serializing and deserialization YAML items.
///
public struct YAMLSerialization {

  /// Errors throws during serialization and deserialization
  ///
  /// + Note: These are informational only, all errors are
  /// fatal and represent corrupted data; no recovery is
  /// possible
  public enum Error: Swift.Error {}

  /// Deserialize YAML encoded `Data` object.
  ///
  /// - Parameters:
  ///     - from: The `Data` value containing YAML encoded bytes
  /// - Throws:
  ///     - `YAMLSerialization.Error`: if any corrupted data is encountered
  ///     - 'Swift.Error`: if any stream I/O error is encountered
  public static func yaml(from data: Data) throws -> YAML {
    let yamls = try YAMLReader.read(data: data)
    if yamls.count == 1 {
      return yamls[0]
    }
    return .sequence(yamls, style: .any, tag: nil, anchor: nil)
  }


  public struct WritingOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let sortedKeys = WritingOptions(rawValue: 1 << 0)
  }

  public static func data(from yaml: YAML, options: WritingOptions = []) throws -> Data {
    return try string(from: yaml, options: options).data(using: .utf8)!
  }

  public static func string(from yaml: YAML, options: WritingOptions = []) throws -> String {

    var output = String()

    try YAMLWriter.write([yaml], sortedKeys: options.contains(.sortedKeys)) {
      guard let str = $0 else { return }
      output.append(str)
    }

    return output
  }

  private init() {}

}
