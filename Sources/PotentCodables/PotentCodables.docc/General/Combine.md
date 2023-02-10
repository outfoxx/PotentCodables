# Combine

Integration with Combine Framework.

## Overview

When used on Apple platforms where the Combine framework is available, all the encoders conform to Combine's
`TopLevelEncoder` and all decoders conform to its `TopLevelDecoder`.

In addition to providing compatibility with Swift's Combine framework these protocols are an easy way to allow
interchanging support for data formats or frameworks without rewriting code.

Using `TopLevelDecoder` instead of a specific framework decoder would allow your code to work with whatever framework
you need.

Given the following generic function
```swift

func decodeFromNetwork<T: Decodable, D: TopLevelDecoder>(url: URL, decoder: D) async throws -> T where D.Input == Data {
  let (data, _) = try await URLSession.shared.data(from: url)
  return try decoder.decode(T.self, from: data)
}

```

You can then use any PotentCodables data format decoder to decode values from the network request.
```swift
import PotentCBOR

let engine: Engine = decodeFromNetwork(URL(string: "https://example.com/engine/1.cbor"), CBOR.Decoder.default)
```
```swift
import PotentYAML

let engine: Engine = decodeFromNetwork(URL(string: "https://example.com/engine/1.yaml"), YAML.Decoder.default)
```

Additionally `decodeFromNetwork` can be called with any conforming decoder from other frameworks, like
Foundation's `JSONDecoder`.

```swift
import Foundation

let engine: Engine = decodeFromNetwork(URL(string: "https://example.com/engine/1.json"), JSONDecoder())
```
