//
//  ASN1Serialization.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// ASN.1 encoded data reading/writing.
///
public enum ASN1Serialization {

  /// ASN.1 Data Errors
  public enum Error: Swift.Error {
    /// Unexpectedly encounted end of data.
    case unexpectedEOF
    /// Invalid or unsupported string.
    case invalidStringEncoding
    /// Invalid characters for string.
    case invalidStringCharacters
    /// Unsupported non-constructed collection
    case nonConstructedCollection
    /// Incorrectly formatted UTC time.
    case invalidUTCTime
    /// Incorrectly formatted generalized time.
    case invalidGeneralizedTime
    /// Unsupported REAL type.
    case unsupportedReal
    /// Encoded value length could not be stored.
    case lengthOverflow
    /// Number of fields in OID is invalid
    case invalidObjectIdentifierLength
  }

  /// Read ASN.1/DER encoded data as a collection of ``ASN1`` values.
  public static func asn1(fromDER data: Data) throws -> [ASN1] {
    return try ASN1DERReader.parse(data: data)
  }

  /// Write ``ASN1`` value as ASN.1/DER encoded data.
  public static func der(from value: ASN1) throws -> Data {
    return try ASN1DERWriter.write(value)
  }

  /// Write collection of ``ASN1`` values as ASN.1/DER encoded data.
  public static func der(from values: [ASN1]) throws -> Data {
    return try ASN1DERWriter.write(values)
  }

}
