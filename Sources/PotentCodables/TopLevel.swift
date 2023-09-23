//
//  TopLevel.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

#if canImport(Combine)

@_exported import protocol Combine.TopLevelDecoder
@_exported import protocol Combine.TopLevelEncoder

#else

public protocol TopLevelDecoder {

  /// The type this decoder accepts.
  associatedtype Input

  /// Decodes an instance of the indicated type.
  func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T: Decodable
}

/// A type that defines methods for encoding.
public protocol TopLevelEncoder {

  /// The type this encoder produces.
  associatedtype Output

  /// Encodes an instance of the indicated type.
  ///
  /// - Parameter value: The instance to encode.
  func encode<T>(_ value: T) throws -> Self.Output where T: Encodable
}

#endif
