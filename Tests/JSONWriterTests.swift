//
//  JSONWriterTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentJSON
import XCTest


class JSONWriterTests: XCTestCase {

  func testEscapesQuotes() throws {

    let json = try JSONSerialization.string(from: .string(#""test""#), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\"test\"""#)
  }

  func testEscapesForwardSlashes() throws {

    let json = try JSONSerialization.string(from: .string("http://example.com/some/thing"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""http:\/\/example.com\/some\/thing""#)
  }

  func testEscapesBackwardSlashes() throws {

    let json = try JSONSerialization.string(from: .string(#"c:\a\file"#), options: [.escapeSlashes])
    XCTAssertEqual(json, #""c:\\a\\file""#)
  }

  func testEscapesBackspace() throws {

    let json = try JSONSerialization.string(from: .string("\u{08}"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\b""#)
  }

  func testEscapesFormFeed() throws {

    let json = try JSONSerialization.string(from: .string("\u{0c}"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\f""#)
  }

  func testEscapesNewLine() throws {

    let json = try JSONSerialization.string(from: .string("\n"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\n""#)
  }

  func testEscapesCarriageReturn() throws {

    let json = try JSONSerialization.string(from: .string("\r"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\r""#)
  }

  func testEscapesTab() throws {

    let json = try JSONSerialization.string(from: .string("\t"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\t""#)
  }

  func testEscapesUnicodeFormatInLongForm() throws {

    let json = try JSONSerialization.string(from: .string("\u{0}"), options: [.escapeSlashes])
    XCTAssertEqual(json, #""\u0000""#)

    let json2 = try JSONSerialization.string(from: .string("\u{10}"), options: [.escapeSlashes])
    XCTAssertEqual(json2, #""\u0010""#)
  }

  func testRewritesIntegerFloats() throws {

    let json = try JSONSerialization.string(from: .number("100.0"), options: [.escapeSlashes])
    XCTAssertEqual(json, #"100"#)
  }

}
