//
//  YAMLTests.swift
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

  fileprivate let objects = TestValue(
    a: 1,
    b: "2",
    c: [true, false, true],
    d: TestValue(
      a: 1,
      b: "2",
      c: [false, false, true],
      d: TestValue(
        a: 1,
        b: "2",
        c: [true, true, false]
      )
    ),
    e: [
      TestValue(
        a: 5,
        b: "6",
        c: [true]
      ),
      TestValue(
        a: 5,
        b: "6",
        c: [true]
      ),
    ]
  )


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

  func testDecodingChildContainers() throws {
    _ = try YAMLDecoder().decode(TestValue.self, from: yaml)
  }

  func testEncodingChildContainers() throws {
    let yamlText = try YAMLEncoder().encodeTree(objects).description
    XCTAssertEqual(yamlText, values.description)
  }

  func testObjectKeySerializationExplicitOrder() throws {

    let yaml = try YAMLSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ])

    XCTAssertEqual(
      yaml,
      """
      c: 1
      a: 2
      b: 3

      """
    )
  }

  func testObjectKeySerializationSortedOrder() throws {

    let yaml = try YAMLSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ], options: .sortedKeys)

    XCTAssertEqual(
      yaml,
      """
      a: 2
      b: 3
      c: 1

      """
    )
  }

  func testObjectKeyDeserializationOrder() throws {

    let object: YAML = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    let yaml =
      """
      ---
      c: 1
      a: 2
      b: 3
      ...

      """

    XCTAssertEqual(object, try YAMLSerialization.yaml(from: yaml))
  }

  func testDescriptionFormat() throws {

    XCTAssertEqual(YAML.alias("test").description, "*test")

    XCTAssertEqual(YAML.null().description, "null")
    XCTAssertEqual(YAML.null(anchor: "test").description, "&test null")

    XCTAssertEqual(YAML.string("my-string", style: .plain).description,
                   "my-string")
    XCTAssertEqual(YAML.string("my-string", style: .doubleQuoted).description,
                   #""my-string""#)
    XCTAssertEqual(YAML.string("my-string", style: .singleQuoted).description,
                   #"'my-string'"#)
    XCTAssertEqual(YAML.string("my-string", style: .plain, anchor: "test").description,
                   "&test my-string")
    XCTAssertEqual(YAML.string("my-string", style: .plain, tag: .str).description,
                   "!tag:yaml.org,2002:str my-string")
    XCTAssertEqual(YAML.string("my-string", style: .plain, tag: .str, anchor: "test").description,
                   "&test !tag:yaml.org,2002:str my-string")

    XCTAssertEqual(YAML.integer(123).description, "123")
    XCTAssertEqual(YAML.integer(123, anchor: "test").description, "&test 123")
    XCTAssertEqual(YAML.integer(123, anchor: "test").description, "&test 123")

    XCTAssertEqual(YAML.float(1.23).description, "1.23")
    XCTAssertEqual(YAML.float(1.23, anchor: "test").description, "&test 1.23")

    XCTAssertEqual(YAML.bool(false).description, "false")
    XCTAssertEqual(YAML.bool(true, anchor: "test").description, "&test true")

    XCTAssertEqual(YAML.sequence([1, 2, 3]).description,
                   "[1, 2, 3]")
    XCTAssertEqual(YAML.sequence([1, 2, 3], anchor: "test").description,
                   "&test [1, 2, 3]")
    XCTAssertEqual(YAML.sequence([1, 2, 3], tag: .seq).description,
                   "!tag:yaml.org,2002:seq [1, 2, 3]")
    XCTAssertEqual(YAML.sequence([1, 2, 3], tag: .seq, anchor: "test").description,
                   "&test !tag:yaml.org,2002:seq [1, 2, 3]")

    XCTAssertEqual(YAML.mapping(["c": 1, "a": 2, "b": 3]).description,
                   "{c: 1, a: 2, b: 3}")
    XCTAssertEqual(YAML.mapping(["c": 1, "a": 2, "b": 3], anchor: "test").description,
                   "&test {c: 1, a: 2, b: 3}")
    XCTAssertEqual(YAML.mapping(["c": 1, "a": 2, "b": 3], tag: .map).description,
                   "!tag:yaml.org,2002:map {c: 1, a: 2, b: 3}")
    XCTAssertEqual(YAML.mapping(["c": 1, "a": 2, "b": 3], tag: .map, anchor: "test").description,
                   "&test !tag:yaml.org,2002:map {c: 1, a: 2, b: 3}")

  }

  func testDescriptionOrder() throws {

    let yaml: YAML = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(
      yaml.description,
      """
      {c: 1, a: 2, b: 3}
      """
    )
  }

  func testJSONOutput() throws {

    let yaml: YAML = [
      "a": [1, 2, 3],
      "b": "Testing 1.. 2.. 3..",
      "c": 45.678,
      "d": true,
      "e": nil
    ]

    XCTAssertEqual(
      try YAMLSerialization.string(from: yaml, options: [.json]),
      #"""
      {"a": [1, 2, 3], "b": "Testing 1.. 2.. 3..", "c": 45.678, "d": true, "e": null}

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization.string(from: yaml, options: [.json, .pretty]),
      #"""
      {
        "a": [
          1,
          2,
          3
        ],
        "b": "Testing 1.. 2.. 3..",
        "c": 45.678,
        "d": true,
        "e": null
      }

      """#
    )
  }

  func testPreferredStringStyle() {

    XCTAssertEqual(
      try YAMLSerialization.string(from: ["plain": "This should be output plain"]),
      #"""
      plain: This should be output plain

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization.string(from: ["dquoted": "This should be output dquoted"],
                                   preferredStringStyle: .doubleQuoted),
      #"""
      "dquoted": "This should be output dquoted"

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization.string(from: ["squoted": "This should be output squoted"],
                                   preferredStringStyle: .singleQuoted),
      #"""
      'squoted': 'This should be output squoted'

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization.string(from: [.string("plain", style: .plain): "This should be output squoted"],
                                   preferredStringStyle: .singleQuoted),
      #"""
      plain: 'This should be output squoted'

      """#
    )

  }

  func testPreferredCollectionStyle() {

    XCTAssertEqual(
      try YAMLSerialization.string(from: ["block": "This should be output block"]),
      #"""
      block: This should be output block

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization.string(from: ["flow": "This should be output flow"],
                                   preferredCollectionStyle: .flow),
      #"""
      {
        'flow': 'This should be output flow'
      }

      """#
    )

    XCTAssertEqual(
      try YAMLSerialization
        .string(from: .mapping([.init(key: "block", value: "This should be output block")], style: .block),
                preferredCollectionStyle: .flow),
      #"""
      block: This should be output block

      """#
    )

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
