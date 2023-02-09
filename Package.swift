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
 let pcDeps: [Target.Dependency] = ["BigInt", .byName(name: "Float16", condition: .when(platforms: [.macOS, .linux]))]
 #else
 let pcDeps: [Target.Dependency] = ["BigInt", "Float16"]
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
    .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.3.0")),
    .package(url: "https://github.com/SusanDoggie/Float16.git", .upToNextMinor(from: "1.1.1")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.0.4"))
  ],
  targets: [
    .target(
      name: "PotentCodables",
      dependencies: pcDeps
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
        .define("HAVE_CONFIG_H")
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

#if swift(>=5.6)

package.dependencies.append(
  .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
)

#endif
