//
//  JSONReaderTests.swift
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


class JSONReaderTests: XCTestCase {

  func testParsesEmptyObjects() throws {

    let json = "{}"

    XCTAssertEqual(try JSONSerialization.json(from: json.data(using: .utf8)!), .object([:]))
  }

  func testParsesEmptyArrays() throws {

    let json = "[]"

    XCTAssertEqual(try JSONSerialization.json(from: json.data(using: .utf8)!), .array([]))
  }

  func testReportsGoodPositionForObjectsMissingComma() throws {

    let json =
    """
    {
      "a": 1,
      "b": 2,
      "c": 3,
      "d": 4
      "e": 5
    }
    """

    XCTAssertThrowsError(try JSONSerialization.json(from: json)) { error in
      guard case JSONReader.Error.invalidData(let exp, let pos) = error else {
        return XCTFail("expected invalidData error")
      }
      XCTAssertEqual(exp, .expectedObjectSeparator)
      XCTAssertEqual(pos, 40)
    }
  }

  func testReportsGoodPositionForArraysMissingComma() throws {

    let json =
    """
    [
      1,
      2,
      3,
      4
      5
    ]
    """

    XCTAssertThrowsError(try JSONSerialization.json(from: json)) { error in
      guard case JSONReader.Error.invalidData(let exp, let pos) = error else {
        return XCTFail("expected invalidData error")
      }
      XCTAssertEqual(exp, .expectedArraySeparator)
      XCTAssertEqual(pos, 20)
    }
  }

  func testParsesScientificFloats() throws {

    let json = #"{"float":1.0e+3}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["float"]?.floatValue, 1000.0)
  }

  func testParsingTooLargeScientificFloatsThrowsError() throws {

    let json = #"{"float":1.0e+400}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }
  }

  func testParsingScientificFloatsWithInvalidCharsThrowsError() throws {

    let json = #"{"float":1.0e++4}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }
  }

  func testUnescapesQuotes() throws {

    let json = #"{"bs":"\""}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["bs"]?.stringValue, #"""#)
  }

  func testUnescapesForwardSlashes() throws {

    let json = #"{"url":"https:\/\/example.com\/some\/thing"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["url"]?.stringValue, "https://example.com/some/thing")
  }

  func testUnescapesBackwardSlashes() throws {

    let json = #"{"path":"c:\\a\\windows\\file"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["path"]?.stringValue, #"c:\a\windows\file"#)
  }

  func testUnescapesBackspace() throws {

    let json = #"{"bs":"\b"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["bs"]?.stringValue, "\u{08}")
  }

  func testUnescapesFormFeed() throws {

    let json = #"{"ff":"\f"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["ff"]?.stringValue, "\u{0C}")
  }

  func testUnescapesNewLine() throws {

    let json = #"{"nl":"\n"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["nl"]?.stringValue, "\u{0A}")
  }

  func testUnescapesCarriageReturn() throws {

    let json = #"{"cr":"\r"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["cr"]?.stringValue, "\u{0D}")
  }

  func testUnescapesTab() throws {

    let json = #"{"tab":"\t"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["tab"]?.stringValue, "\u{09}")
  }

  func testUnescapingInvalidCodeThrowsError() throws {

    let json = #"{"invalid":"\s"}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }
  }

  func testUnescapesUnicode() throws {

    let json = #"{"uni":"15\u00B0C"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["uni"]?.stringValue, "15\u{00B0}C")
  }

  func testUnescapesUnicodeSurrogatePairs() throws {

    let json = #"{"uni":"\ud83c\udf09"}"#

    let value = try JSONSerialization.json(from: json.data(using: .utf8)!)
    XCTAssertEqual(value["uni"]?.stringValue, "🌉")
  }

  func testUnescapingInvalidUnicodeSurrogatePairsThrowsError() throws {

    let json = #"{"uni":"\ud83c\u00B0"}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }

    let json2 = #"{"uni":"\ud83c"}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json2.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }

    let json3 = #"{"uni":"\ud"}"#

    XCTAssertThrowsError(try JSONSerialization.json(from: json3.data(using: .utf8)!)) { error in
      AssertJSONErrorInvalidData(error)
    }
  }

}
