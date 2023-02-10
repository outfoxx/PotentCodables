# Polymorphic Encoding & Decoding

Utilities to simplify polymorphic encoding and decoding.

## Overview

Polymorphic encoding refers to being able to encode a value with a Swift type identifier that can be used to determine
the correct type to decode.

``PotentCodables/Ref`` and ``PotentCodables/EmbeddedRef`` are provided to make encoding polymorphic values easier.
These "reference types" are designed to work with with decoding concrete types like classes and structs as well as
protocols.

### Wrapped Values

``PotentCodables/Ref`` is used to decode values that are "wrapped" with a type name. For example, given JSON similar
to the following:
```javascript
{ "@type" : "MyApp.Foo", "value" : { "name" : "A Value" } }
```

``PotentCodables/Ref`` can be used to decode a value with a little extra code. Here we decode implementations of a 
protocol `FooBar`.
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

DefaultTypeIndex.addAllowedTypes([Foo.self, Bar.self]) // Allow types for polymorphic decoding

let val = try JSONDecoder.default.decode(Ref.self).as(FooBar.self)  // Decode a `FooBar` and use `as` to cast or throw an error.
```
> Important: See <doc:PolymorphicEncodingDecoding#Type-ID-Serialization-and-Type-Resolution> to learn why
`DefaultTypeIndex.addAllowedTypes` is required and about security issues related to decoding. 

Conversley to encode a value wrapped with an object containg the Swift type name simply use `Ref.Value` during
encoding:
```swift
let data = try JSONEncoder.default.encode(Ref.Value(val))
```

> Note: ``PotentCodables/Ref`` is a type alias for the generic type ``PotentCodables/CustomRef`` that uses the
looks up type using the ``PotentCodables/DefaultTypeIndex`` and the default type and value keys. To customize keys
or use a customized type index see <doc:Custom-References>.

### Embedded Values

``PotentCodables/EmbeddedRef``, which includes `EmbeddedRef.Value`, is also
provided and is used the exact same way as ``PotentCodables/Ref``. The difference is that 
``PotentCodables/EmbeddedRef`` embeds the type name along side the encoded value's other keys.

For example, the example JSON above would resemble the following with the key embedded:
```javascript
{ "@type" : "MyApp.Foo", "name" : "A Value" }
```

> Note: ``PotentCodables/EmbeddedRef`` requires the value it encodes to use a keyed-container.  Unkeyed and
single-value containers cannot be used with it, but they can be used with ``PotentCodables/Ref``.

See the documentation for ``PotentCodables/Ref`` and ``PotentCodables/EmbeddedRef`` for a lot of details on their usage
as well as documentation of how to customize the keys used during encoding/decoding. 

### Nested Values

When a struct or class needs to reference a polymorphic type (e.g. via a protocol) you will need to implement
`Encodable.encode(to:)` and `Decodable.init(from:)`. In this scenario your can still use ``PotentCodables/Ref`` or
``PotentCodables/EmbeddedRef`` in your provided implementations.

We can store a value confornming to `FooBar` (from the previous examples) in a struct in the following way: 

```swift
struct TestValue: Codable {
  var fooBar: FooBar

  init(fooBar: FooBar) {
    self.fooBar = fooBar
  }

  enum CodingKeys: CodingKey {
    case fooBar
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.fooBar = try container.decode(Ref.self, forKey: .fooBar).as(FooBar.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(Ref.Value(fooBar), forKey: .fooBar)
  }
}
```

## Type ID Serialization and Type Resolution

By default the type serialization & resolution mechanism disallows all types to be
decoded. This is to ensure that decoding is secure and only authorized types can be decoded. Additionally, the index
mechanism, by default, uses a type id that does not include your application or module's the Swift module name so as
to ensure stable type ids across modules and frameworks.

The means that you must explicity allow classes prior to using polymorphic decoding. This is done as simply as:
```swift
DefaultTypeIndex.addAllowedTypes([Foo.self, Bar.self])
```
This generates a type id for each type (`Foo` & `Bar`) and upates the map of allowed types to include the types
provided.

### Custom Type Index

Alternatively you can implement and provide a custom type index and define your own reference type (see
<doc:Custom-References>) . If you have an alternate means of looking up types and/or generating type ids.

> Important: The default type index is designed to be safe by default. This means Swift Packages and Xcode Frameworks
**must** use a custom type index to ensure the types it expects are registered and reduce the chance of inadvertantly
creating security vulnerabilities in adopting applications.
