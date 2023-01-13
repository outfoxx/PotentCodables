// swift-tools-version:5.1
//
//  Package.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import PackageDescription

let package = Package(
  name: "PotentCodables",
  platforms: [
    .iOS(.v10),
    .macOS(.v10_12),
    .watchOS(.v3),
    .tvOS(.v10),
  ],
  products: [
    .library(
      name: "PotentCodables",
      targets: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1", "PotentYAML", "Cfyaml"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.3.0")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.0.4"))
  ],
  targets: [
    .target(
      name: "PotentCodables"
    ),
    .target(
      name: "PotentJSON",
      dependencies: [
        "PotentCodables",
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .target(
      name: "PotentCBOR",
      dependencies: [
        "PotentCodables",
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .target(
      name: "PotentASN1",
      dependencies: [
        "PotentCodables",
        "BigInt",
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .target(    
      name: "Cfyaml",
      sources: [
        "src/lib/",
        "src/xxhash/"
      ],
      cSettings: [
        .headerSearchPath("."),
        .headerSearchPath("include"),
        .headerSearchPath("src/lib"),
        .headerSearchPath("src/valgrind"),
        .headerSearchPath("src/xxhash"),
        .define("HAVE_CONFIG_H"),
        .unsafeFlags(["-w"])
      ]
    ),
    .target(
      name: "PotentYAML",
      dependencies: ["Cfyaml", "PotentCodables"]
    ),
    .testTarget(
      name: "PotentCodablesTests",
      dependencies: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1", "PotentYAML"],
      path: "./Tests"
    )
  ]
)
