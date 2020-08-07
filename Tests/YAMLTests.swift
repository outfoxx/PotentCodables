//
//  File.swift
//  
//
//  Created by Kevin Wooten on 4/11/20.
//

import Foundation
import XCTest
@testable import PotentYAML


class YAMLTests: XCTestCase {
  
  func testParse() throws {
    
    let data = """
    test1: null
    test2: ~
    test3:
    test4: false
    test5: true
    test6: 123
    test7: 123.456
    test8: "a string"
    test9:
      - null
      - false
      - 123
      - 123.456
      - "a string in an array"
    test10:
      a: null
      b: false
      c: 123
      d: 123.456
      e: "a string in a map"
    """.data(using: .utf8)!
    
    guard let yaml = try YAMLReader.read(data: data).first else {
      XCTFail("No document in stream")
      return
    }
    
    XCTAssertEqual(yaml["test1"]!, nil)
    XCTAssertEqual(yaml["test2"]!, nil)
    XCTAssertEqual(yaml["test3"]!, nil)
    XCTAssertEqual(yaml["test4"]!, false)
    XCTAssertEqual(yaml["test5"]!, true)
    XCTAssertEqual(yaml["test6"]!, 123)
    XCTAssertEqual(yaml["test7"]!, 123.456)
    XCTAssertEqual(yaml["test8"]!, "a string")
    XCTAssertEqual(yaml["test9"]!, [nil, false, 123, 123.456, "a string in an array"])
    XCTAssertEqual(yaml["test10"]!, ["a": nil, "b": false, "c": 123, "d": 123.456, "e": "a string in a map"])
  }
  
  let yaml =
      """
      {
        "a": 1,
        "b": "2",
        "c": [true, false, true],
        "d": {
          "a": 1,
          "b": "2",
          "c": [false, false, true],
          "d": {
            "a": 1,
            "b": "2",
            "c": [true, true, false]
          }
        },
        "e": [
          {
            "a": 5,
            "b": "6",
            "c": [true]
          },
          {
            "a": 5,
            "b": "6",
            "c": [true]
          }
        ]
      }
      """
  
  fileprivate let objects = TestValue(a: 1,
                                      b: "2",
                                      c: [true, false, true],
                                      d: TestValue(a: 1,
                                                   b: "2",
                                                   c: [false, false, true],
                                                   d: TestValue(a: 1,
                                                                b: "2",
                                                                c: [true, true, false])),
                                      e: [
                                        TestValue(a: 5,
                                                  b: "6",
                                                  c: [true]),
                                        TestValue(a: 5,
                                                  b: "6",
                                                  c: [true]),
                                      ])
  
  
  let values: YAML = [
    "a": 1,
    "b": "2",
    "c": [true, false, true],
    "d": [
      "a": 1,
      "b": "2",
      "c": [false, false, true],
      "d": [
        "a": 1,
        "b": "2",
        "c": [true, true, false],
      ],
    ],
    "e": [
      [
        "a": 5,
        "b": "6",
        "c": [true],
      ],
      [
        "a": 5,
        "b": "6",
        "c": [true],
      ],
    ],
  ]

  func testDecodingChildContainers() {
    _ = try! YAMLDecoder().decode(TestValue.self, from: yaml)
  }
  
  func testEncodingChildContainers() {
    let yamlText = try! YAMLEncoder().encodeTree(objects).stableText
    XCTAssertEqual(yamlText, values.stableText)
  }
  
}


private class TestValue: Codable {
  let a: Int
  let b: String
  let c: [Bool]
  let d: TestValue?
  let e: [TestValue]?
  
  init(a: Int, b: String, c: [Bool], d: TestValue? = nil, e: [TestValue]? = nil) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = e
  }
  
}
