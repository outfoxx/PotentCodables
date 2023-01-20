//
//  YAMLWriterTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentYAML
import XCTest


class YAMLWriterTests: XCTestCase {

  func testWriteMultipleDocuments() throws {

    var output = ""
    try YAMLWriter.write([.bool(true), .integer(123)]) { output += $0 ?? "" }

    XCTAssertEqual(
      output,
      """
      --- true
      ...
      --- 123
      ...

      """
    )
  }

  func testWriteAliases() throws {

    XCTAssertEqual(
      try YAMLSerialization.string(from: .alias("num")),
      """
      --- *num
      ...

      """
    )
  }

}
