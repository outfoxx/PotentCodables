# 🧪 PotentCodables
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

The library name is `PotentCodables` when adding dependencies to your target(s).


## Usage

### Using Encoders/Decoders

If your only goal is to use one of the provided implementations of a serialization format, not much information is needed beyond the
name of the encoder/decoder pair that you are seeking to use.  All of the implementations provided by the package are 100% compatible with
Swift's `Codable` system and they all intentionally mimic the interface of Swift's native encoders & Decoder
(e.g. `Foundation.JSONEncoder` and `Foundation.JSONDecoder`).

For example encoding to CBOR is essentially the same as encoding with Swift's standard JSONEncoder
```swift
let data = try CBOREncoder.default.encode(myValue)
```
#### Provided Formats

- JSON - `JSONEncoder`/`JSONDecoder` or `JSON.Encoder`/`JSON.Decoder`
  A conformant [JSON](https://tools.ietf.org/html/rfc8259) implementation that is a drop-in replacement for Swift's JSON encoder and
  decoder provided by Foundation. These implementations offer enhancements to what items can be encoded to (e.g. to/from Strings
  and to/from native value trees) and offer performance enhancements when using `AnyValue`.  
- CBOR - `CBOREncoder`/`CBORDecoder` or `CBOR.Encoder`/`CBOR.Decoder`
  A conformant implementation of the [CBOR](cbor.io) serialization format written in pure Swift.
- AnyValue - `AnyValueEncoder`/`AnyValueDecoder` or `AnyValue.Encoder`/`AnyValue.Decoder`
  An in-memory transcoding implementation for working with unstructured values using `AnyValue`.

#### Extended Interfaces

All provided encoders and decoders come with an extended set of methods that allow different targets and sources when encoding and
decoding.

Encoders provide these methods
```swift
// Encoding to value tree - Supported by all encoders
func encodeTree<T: Encodable>(_ value: T) throws -> Value

// Encoding to data - supported by text & binary format encoders
func encode<T: Encodable>(_ value: T) throws -> Data

// Encoding to string - supported by text format encoders
func encode<T: Encodable>(_ value: T) throws -> String  
```

Decoders provide these methods
```swift
// Decoding from a value tree - supported by all decoders
func decodeTree<T: Decodable>(_ type: T.Type, from value: Value) throws -> T
func decodeTreeIfPresent<T: Decodable>(_ type: T.Type, from value: Value) throws -> T?

// Decoding from data - supported by text & binary format decoders
func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: Data) throws -> T?

// Decoding from string - supported by text format encoders
func decode<T: Decodable>(_ type: T.Type, from data: String) throws -> T  
func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: String) throws -> T?
```

### Polymorphic Encoding/Decoding

`Codable` encoders and decoders are a great tool and very convenient. Unfortunately using them with polymorphic types is cumbersome,
to say the least, and near impossible in a lot of other cases.

PotentCodables provides `Ref` and `EmbeddedRef` to make encoding/decoding polymorphic types very easy. The reference wrappers are
designed to work with concrete type and protcols alike.

`Ref` is used to decode values that are "wrapped" with a type name. For example, given JSON similar to the following:
```javascript
{ "@type" : "MyApp.Foo", "value" : { "name" : "A Value" } }
```

`Ref` can be used to decode a value with little extra code
```swift
protocol FooBar {
  var name: String { get }
}

struct Foo: FooBar, Codable {
  let name: String
}

struct Bar: FooBar, Codable {
  let count: Int
}

let val = try JSONDecoder.default.decode(Ref.self).as(FooBar.self)  // Decode ref and use the `as` utility to cast it or throw
```

To encode a value with the required structure and inserting the Swift type name simply use `Ref.Value` during encoding:
```swift
let data = try JSONEncoder.default.encode(Ref.Value(val))
```

`EmbeddedRef`, which includes `EmbeddedRef.Value`, is also provided and is used the exact same way as `Ref`. The difference is that
`EmbeddedRef` embeds the type name along side the encoded values other keys. For example, the example JSON above would resemble the
following with the key embedded:
```javascript
{ "@type" : "MyApp.Foo", "name" : "A Value" }
```

 `EmbeddedRef` requires the value it encodes to use a keyed-container.  Unkeyed and single-value containers cannot be used with
it, but they can be used with `Ref`.


The documentation for `Ref` and `EmbeddedRef` provide a lot of details on their usage as well as documentation of how to customize the
keys used during encoding/decoding.

##### ⚠️ Top-Level Classes Only ⚠️
Currently due to limitations with Swift's dynamic type lookup `Ref` and `EmbeddedRef` currently only support top-level reference types
(aka `class`).  When Swift's runtime support dynamic lookup of value & generic types, those will be supported as well.


### `AnyValue` - Unstructured Values

Sometimes it is necessary to decode values of any type or that can take on any structure; unfortunately Swift's `Codable` is not well suited
for this purpose. PotentCodables provides `AnyValue` to fill the gap.

Using `AnyValue` is simple, just use it wherever you would normally use an `Any`. Since `AnyValue` supports `Codable` everything else
works as normal including Swift's automatic codable generation.
```swift
struct Account : Codable {
  let name: String
  let data: AnyValue                  // `data` can store and scalar or complex value
  let dataDict: [String: AnyValue]    // `dataDict` is required to be a dictionary of name to any values
  let dataArray: [AnyValue]           // `dataArray` is required to be an array of any values
}
```

The example `Account` struct above has a `data` property that can take on any value supported by the codable system. For example
when decoding from JSON, any value or tree of values (including _null_, _bool_, _string_, _number_, _arrray_ or _object_) could be saved in
the `data` property. Encoding the same `Account` value back to JSON will produce equivalent serialized JSON regardless of the contents
of the `data` field.

`AnyValue` has lots of features to make building and using them natural in Swift, like "dynamic member lookup" to access fields of a
`AnyValue.dictionary`. See the documentation for complete details.

**Performance**
Although `AnyValue` is compatible with any conformant `Codable` encoder or decoder, PotentCodables decoders specifically have shortcuts
to decode the proper values in a more performant fashion and should be used when possible.


## More

* [Encoder/Decoder Protocols](Docs/Protocols.md)
* [Implementing New Formats](Docs/Implementing.md)

