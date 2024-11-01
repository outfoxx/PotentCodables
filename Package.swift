// swift-tools-version:5.4
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

// Limit Float16 to x86_64 on macOS or Linux
 #if swift(>=5.5)
 let pcDeps: [Target.Dependency] = [
  "BigInt",
  .product(name: "Collections", package: "swift-collections"),
  .byName(name: "Float16", condition: .when(platforms: [.macOS, .macCatalyst, .linux])),
  .product(name: "Regex", package: "regex"),
 ]
 #else
 let pcDeps: [Target.Dependency] = [
  "BigInt",
  .product(name: "Collections", package: "swift-collections"),
  "Float16",
  .product(name: "Regex", package: "regex"),
 ]
 #endif

let package = Package(
  name: "PotentCodables",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .watchOS(.v7),
    .tvOS(.v14),
  ],
  products: [
    .library(
      name: "PotentCodables",
      targets: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1", "PotentYAML", "Cfyaml"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(url: "https://github.com/SusanDoggie/Float16.git", from: "1.1.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
    .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.1")
  ],
  targets: [
    .target(
      name: "PotentCodables",
      dependencies: pcDeps,
      resources: [
        .process("PotentCodables.docc")
      ]
    ),
    .target(
      name: "PotentJSON",
      dependencies: [
        "PotentCodables",
        "BigInt",
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .target(
      name: "PotentCBOR",
      dependencies: [
        "PotentCodables",
        "BigInt",
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
        "src/util/",
        "src/xxhash/"
      ],
      cSettings: [
        .headerSearchPath("."),
        .headerSearchPath("include"),
        .headerSearchPath("src/lib"),
        .headerSearchPath("src/util"),
        .headerSearchPath("src/valgrind"),
        .headerSearchPath("src/xxhash"),
        .define("HAVE_CONFIG_H")
      ]
    ),
    .target(
      name: "PotentYAML",
      dependencies: [
        "PotentCodables",
        "BigInt",
        "Cfyaml",
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Regex", package: "regex")
      ]
    ),
    .testTarget(
      name: "PotentCodablesTests",
      dependencies: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1", "PotentYAML"],
      path: "./Tests"
    )
  ]
)

#if swift(>=5.6)

package.dependencies.append(
  .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
)

#endif
