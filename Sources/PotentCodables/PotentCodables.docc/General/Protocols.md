# Encoder/Decoder Protocols

Details of all the protocols PotentCodables `Encoder`s and `Decoder`s implement.

## Native Value Trees

All PotentCodable encoders and decoders use a two stage serialization system. For example, when encoding an `Encodable` value it is first
transformed into a native "value tree" that is defined by the serialization format. Secondarily, a serialization utility is used to transform
the value tree into the final serialized data.

For example, when encoding to CBOR the `Encodable` value is first transformed into `CBOR` values that closely match the CBOR
specification and then the `CBOR` value tree is serialized into `Data`.  The same process is done for decoding but in reverse, `Data` is turned
into a value tree and then the value tree is decoded into a `Decodable` value as requested.

This two stage system is important to ensure that we can implement new serialization formats with a reduced amount of code. All of the 
machinery to encode `Encodable`s and  decode `Decodable`s are isolated in a common set of classes that need to be implemented only
once.


The protocol representing a native value tree is `Value` and its quite small:
```swift
  protocol Value {
    var isNull: Bool { get }
    var unwrapped: Any? { get }
  }
```

It provides only the ability to test if it represents something equivalent to Swift's  `nil` and the ability to "unwrap" itself into native Swift
values.

You can see examples of `Value` implementations in the `JSON` and `CBOR` enumerations. These types closely track the values representable
by thier format and can be easily manipulated.

Aside from providing code structure that allows us to employ code re-use this requirement ensures that we can always encode/decode
to an in-memory value tree. A very useful side-effect of this is that it allows us to easily examine or manipulate everything that is encoded
and decoded.

**Note:** Inevitably somebody will want to point out the inefficiency of using a two stage system of serialization. It is our belief that the added
features and reduced implementation cost far outweigh any slight performance/memory improvement that might be gained from serializing
directly to the target format.  _Also_, Swift's native JSON implementations already use this same two stage method. In the native
implementation, encodables are turned into Objective-C values and then Objective-C's JSONSerialiazation class is used to create serialized
JSON data.

## Value Tree Encoding/Decoding

Due to the requirement that all of our encoders and decoders support a native value tree representation, it provides the capability to encode
or decode to native value trees using the following methods:

#### Protocols

Each encoder implements `EncodesToTree` and provides the following method with `Value` being the `Encoder`'s native value tree type;
allowing us to transform an `Encodable` instance into a native value tree.
```swift
protocol EncodesToTree {
  func encodeTree<T : Encodable, V : Value>(_ value: T) throws -> V
}
```

Each decoder implements `DecodesFromTree` and provides the following methods with `Value` being the `Decoder`'s native value tree
type; allowing us to transform a native value tree into an instance of a `Decodable` type.
```swift
protocol DecodesFromTree {
  func decodeTree<T : Decodable, V : Value>(_ type: T.Type, from: V) throws -> T
  func decodeTreeIfPresent<T : Decodable, V : Value>(_ type: T.Type, from: V) throws -> T?
}
```

## Data Encoding/Decoding

Binary formats, like `CBOR`, are encoded to their final form as a `Data` value. This is the interface most widely recognized from Swift's native
implementations for JSON and Property List.

#### Protocols

Each encoder implements `EncodesToData` and provides the following method to transform `Encodable` instances into `Data` values.
```swift
protocol EncodesToData {
  func encode<T: Encodable>(_ value: T) throws -> Data
}
```

Each decoder implements `DecodesFromData` and provides the following methods to transform `Data` into an instance of a `Decodable`
type.
```swift
protocol DecodesFromData {
  func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
  func decodeIfPresent<T: Decodable>(_ type: T.Type, from: Data) throws -> T?
}
```

## String Encoding/Decoding

Any PotentCodable encoder or decoder that is implementing a text based serialization format (e.g. JSON, YAML, etc.) provides the extra 
capability to encode to and decode from `String` values. These formats also support the methods for Data encoding/decoding using a
string encoding required by their speification or that will be automatically detected during decoding.

#### Protocols

Each encoder implements `EncodesToString` and provides the following method to transform `Encodable` instances into `String` values.
```swift
protocol EncodesToString {
  func encodeString<T: Encodable>(_ value: T) throws -> String
}
```

Each decoder implements `DecodesFromString` and provides the following methods to transform `String` into an instance of a
`Decodable` type.
```swift
protocol DecodesFromString {
  func decode<T: Decodable>(_ type: T.Type, from: String) throws -> T
  func decodeIfPresent<T: Decodable>(_ type: T.Type, from: String) throws -> T
}
```

## Using Protocols

Unlike Swift's native encoders/decoders, all the encoders and decoders provided by PotentCodables implement the above interfaces
based on the type of format (e.g. binary or text).  This allow users to interchangably use any encoder or decoder at runtime without munually
adding protocol conformance.

One encoder/decoder pair, `AnyValueEncoder`/`AnyValueDecoder`, only supports targeting native value trees. This is because it has no
serialized format and only exists to transcode between in-memory representations.
