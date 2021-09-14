//
//  YAMLSerialization.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

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
