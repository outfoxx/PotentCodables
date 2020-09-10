//
//  ASN1Tests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentASN1
import XCTest


class ASN1Tests: XCTestCase {

  func testExplicitSchema() throws {
    
    struct TestStruct: Codable, Equatable {
      let a: Int
      let b: String
      let c: [Bool]
    }
    
    let TestStructSchema: Schema =
      .sequence([
        "a": .integer(),
        "b": .string(kind: .utf8),
        "c": .setOf(.boolean()),
      ])

    
    let src = TestStruct(a: 5, b: "BBB", c: [false, true, false])
    let srcData = try ASN1Encoder(schema: TestStructSchema).encode(src)
    let dst = try ASN1Decoder(schema: TestStructSchema).decode(TestStruct.self, from: srcData)

    XCTAssertEqual(src, dst)
  }
  
  func testDecodeASN1Null() throws {
    
    struct TestStruct: Codable, Equatable {
      let a: String
      let b: ASN1
    }
    
    let TestStructSchema: Schema =
      .sequence([
        "a": .string(kind: .utf8),
        "b": .choiceOf([.integer(), .null])
      ])

    let src = TestStruct(a: "test", b: .null)
    let srcData = try ASN1Encoder(schema: TestStructSchema).encode(src)
    let dst = try ASN1Decoder(schema: TestStructSchema).decode(TestStruct.self, from: srcData)
    
    XCTAssertEqual(src, dst)
  }

}
