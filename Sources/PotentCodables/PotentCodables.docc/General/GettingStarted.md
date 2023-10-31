# Getting Started with Potent Codables

Get started using the powerful potent data formats **JSON**, **YAML**, **CBOR** & **ASN.1**.

## Overview

PotentCodables provide standard `Encoder`s and `Decoder`s for the Swift `Codable` framework. Additionally all
of the `Encoder`s and `Decoder`s provide enhanced capabilities to make working with data formats easier and more
powerful.

### Standard Encoders/Decoders


If you are looking to use one of the powerful PotentCodables provided formats for encoding & decoding you only
need to import the format you want to use and use the familiar `Encoder` and `Decoder` APIs as you would for
any other `Codable` framework.

For example encoding to YAML is essentially the same as encoding with Swift's standard `JSONEncoder`. You just need
to use ``PotentYAML/YAMLEncoder``

```swift
import PotentYAML

struct Engine {
  var name: String
  var cylinders: Int
}

let v8Engine = Engine(name: "V8", cylinders: 8)

let yamlData = try YAML.Encoder.default.encode(v8Engine)
print(String(data: yamlData, encoding: .utf8)!)
```
Produces the following YAML:
```yaml
---
name: V8
cylinders: 8
...
```

Similarly, to decode the YAML produced in the previous example you only need to use ``PotentYAML/YAMLDecoder``.
```swift
import PotentYAML

let someEngine = YAML.Encoder.default.decode(yamlData)
```

> Note: All provided Encoders and Decoders from a `default` for easy access to an encoder or decoder initialized
with default options. These are used throughout the documentation.

> Tip: You may have noticed you can use either ``PotentYAML/YAML/Encoder`` or ``PotentYAML/YAMLEncoder`` to reference
the YAML encoder's type. This is true for all PotentCodables formats and allows easy disambiguation when mixing with
other codable frameworks encoders & decoders like Foundation's `JSONEncoder`/`JSONDecoder`.

### Encoding/Decoding from Strings

All PotentCodables text based data formats like <doc:PotentJSON> and <doc:PotentYAML> can encode directly to and from
Strings in addition to the standard `Data` encoding; this can save you the hassle of converting `Data` to `String` in
many cases.

The previous encoding example could be rewritten as follows:
```swift
import PotentYAML

struct Engine {
  var name: String
  var cylinders: Int
}

let v8Engine = Engine(name: "V8", cylinders: 8)

let yamlData = try YAML.Encoder.default.encodeString(v8Engine)
print(String(data: yamlData, encoding: .utf8)!)
```

All of PotentCodables text based formats provided `String` support via the following protocols. 

- ``EncodesToString``
- ``DecodesFromString``

### Encoding/Decoding from Tree values.

PotentCodables data formats are required to provide an in-memory representation known as a "tree value". Tree values
are Swift values that represent the natively encoded data. See <doc:TreeValues> to learn more about tree values.

All PotentCodables encoders and decoders have the ability to encode to or decode from tree values.

Reading our previous example `Engine` struct from a ``PotentJSON/JSON`` tree value is easy.
```swift
import PotentJSON

struct Engine {
  var name: String
  var cylinders: Int
}

let json: JSON = [
  "name": "V8",
  "cylinders": 8
]

let someEngine = JSON.Decoder.default.decodeTree(Engine.self, from: json)
```

All PotentCodables data formats provided support for tree values via the following protocols. 

- ``EncodesToTree``
- ``DecodesFromTree``
