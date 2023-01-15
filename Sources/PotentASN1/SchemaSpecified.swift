//
//  SchemaSpecified.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// Adopt to announce a type's ability to provide
/// a standalone ASN.1 schema.
///
/// Adopting ``SchemaSpecified``allows using the static utility
/// functions ``ASN1Encoder/encode(_:)`` and ``ASN1Decoder/decode(_:from:)``
/// without having to explicitly provide a schema.
///
/// ``SchemaSpecified`` also provides the default ``SchemaSpecified/encoded()``
/// function for easy encoding of values to `Data`.
///
public protocol SchemaSpecified {

  /// The associated ASN.1 schema for this type
  static var asn1Schema: Schema { get }

}

public extension SchemaSpecified where Self: Encodable {

  /// Encode the value in ASN.1/DER format.
  ///
  /// - Returns: The ASN.1 encoded data for this value.
  func encoded() throws -> Data {
    return try ASN1Encoder.encode(self)
  }

}
