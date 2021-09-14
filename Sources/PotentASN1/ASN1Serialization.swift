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


public enum ASN1Serialization {

  public static func asn1(fromDER data: Data) throws -> [ASN1] {
    return try DERReader.parse(data: data)
  }

  public static func der(from value: ASN1) throws -> Data {
    return try DERWriter.write(value)
  }

  public static func der(from values: [ASN1]) throws -> Data {
    return try DERWriter.write(values)
  }

}
