//
//  Tagged.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// Adopting ``Tagged`` allows customization of a
/// type's ASN.1 encoded value.
///
/// When encoding a value supporting adopting this protocol
/// the ``ASN1Encoder`` will call ``encode(schema:)`` to
/// retrieve the ``ASN1`` value it should ultimately encode.
///
/// During decoding ``ASN1Decoder`` calls ``init(tag:value:)``
/// with the tag and value it decoded. The initializer implementation
/// can further process the provided value if needed.
///
public protocol Tagged {

  var tag: ASN1.AnyTag { get }
  var value: Any? { get }

  /// Encode the value according to the provided schema.
  func encode(schema: Schema) throws -> ASN1

  /// Decoded tag and value.
  init?(tag: ASN1.AnyTag, value: Any?)

}
