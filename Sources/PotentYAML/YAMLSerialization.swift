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
public enum YAMLSerialization {

  /// Errors throws during serialization and deserialization
  ///
  /// + Note: These are informational only, all errors are
  /// fatal and represent corrupted data; no recovery is
  /// possible
  public enum Error: Swift.Error {
    case unableToCreateEmitter
    case emitError(message: String)
    case unableToCreateParser
    case parserError(message: String, line: Int, column: Int)
    case unexpectedEOF
    case unexpectedEvent
    case invalidToken
    case invalidTaggedBool
  }

  /// Deserialize YAML encoded `Data`.
  ///
  /// - Parameters:
  ///     - from: The `Data` value containing YAML encoded data
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

  /// Deserialize YAML encoded `String`.
  ///
  /// - Parameters:
  ///     - from: The `String` value containing YAML data.
  /// - Throws:
  ///     - `YAMLSerialization.Error`: if any corrupted data is encountered
  ///     - 'Swift.Error`: if any stream I/O error is encountered
  public static func yaml(from string: String) throws -> YAML {
    guard let data = string.data(using: .utf8) else {
      throw DecodingError
        .dataCorrupted(
          DecodingError
            .Context(codingPath: [], debugDescription: "String cannot be encoded as UTF-8", underlyingError: nil)
        )
    }
    return try yaml(from: data)
  }

  public struct WritingOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let sortedKeys = WritingOptions(rawValue: 1 << 0)
    public static let pretty = WritingOptions(rawValue: 1 << 1)
    public static let json = WritingOptions(rawValue: 1 << 3)
    public static let explictDocumentMarkers = WritingOptions(rawValue: 1 << 4)
  }

  public static func data(from yaml: YAML,
                          preferredCollectionStyle: YAML.CollectionStyle = .any,
                          preferredStringStyle: YAML.StringStyle = .any,
                          options: WritingOptions = []) throws -> Data {
    guard
      let data = try string(from: yaml,
                            preferredCollectionStyle: preferredCollectionStyle,
                            preferredStringStyle: preferredStringStyle,
                            options: options).data(using: .utf8)
    else {
      throw DecodingError
        .dataCorrupted(
          DecodingError
            .Context(codingPath: [], debugDescription: "String cannot be decoded as UTF-8", underlyingError: nil)
        )
    }
    return data
  }

  public static func string(from yaml: YAML,
                            preferredCollectionStyle: YAML.CollectionStyle = .any,
                            preferredStringStyle: YAML.StringStyle = .any,
                            options: WritingOptions = []) throws -> String {

    var output = String()

    let writerOptions = YAMLWriter.Options(
      writingOptions: options,
      preferredCollectionStyle: preferredCollectionStyle,
      preferredStringStyle: preferredStringStyle
    )

    try YAMLWriter.write([yaml], options: writerOptions) {
      guard let str = $0 else { return }
      output.append(str)
    }

    return output
  }

}

extension YAMLWriter.Options {

  init(
    writingOptions: YAMLSerialization.WritingOptions,
    preferredCollectionStyle: YAML.CollectionStyle,
    preferredStringStyle: YAML.StringStyle
  ) {
    self.preferredCollectionStyle = preferredCollectionStyle
    self.preferredStringStyle = preferredStringStyle
    self.json = writingOptions.contains(.json)
    self.pretty = writingOptions.contains(.pretty)
    self.width = writingOptions.contains(.pretty) ? .normal : .infinite
    self.sortedKeys = writingOptions.contains(.sortedKeys)
    self.explicitDocumentMarkers = writingOptions.contains(.explictDocumentMarkers)
  }

}
