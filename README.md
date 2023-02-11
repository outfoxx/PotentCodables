# 🧪 PotentCodables
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/outfoxx/PotentCodables/ci.yml?branch=main)
![Coverage](https://sonarcloud.io/api/project_badges/measure?project=outfoxx_PotentCodables&metric=coverage)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Foutfoxx%2FPotentCodables%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/outfoxx/PotentCodables)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Foutfoxx%2FPotentCodables%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/outfoxx/PotentCodables)

## A potent set of implementations and extension to the Swift `Codable` system

### Why?
The framework aims to solve three major pain points experienced with Swift's `Codable` system:

* Allow decoding and/or encoding values of unknown structure (e.g. any encoded value)
* Support polymorphic type encoding/decoding while still allowing Swift to implement `Codable` 
* Reduce the complexity and amount of code required to implement and test new serialization formats
* Provide a library of fully featured implementations of popular serialization formats

## Integration

### Swift Package Manager 
PotentCodables currently supports Swift Package Manager for project integration. Add a package dependency similar to the following:  
```swift
  .package(url: "https://github.com/outfoxx/PotentCodables.git", from: "1.0.0")
```

## Documentation

### [View Package Documentation](https://outfoxx.github.io/PotentCodables/main/documentation/potentcodables)
