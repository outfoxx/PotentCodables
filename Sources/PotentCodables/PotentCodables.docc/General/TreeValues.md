# Tree Values

What are "tree values"?

## Overview

Each decoder has an in memory representation known as the "tree" value. The great thing about tree values is that they 
hold the values in their exact serialized representation.  For example, `JSON` tree values store numbers as a
specialized ``PotentJSON/JSON/Number`` that stores the exact number value as a string along with a number of other 
properties for helping the conversion of strings to integer or floating point numbers. Accessing this
``PotentJSON/JSON/Number`` and reading the exact decimal value serialized in JSON is available from tree values. 

The decoders support accessing the tree value using specializations of the protocol
``PotentCodables/TreeValueDecodingContainer`` which extends the  `SingleValueDecodingContainer` protocol. 

Decoding ``PotentJSON/JSON`` values using the ``PotentCodables/TreeValueDecodingContainer`` as follows:
```swift
func init(from decoder: Decoder) throws {
  let treeContainer = try decoder.singleValuedContainer() as! TreeValueDecodingContainer
  self.jsonValue = try treeContainer.decodeTreeValue() as! JSON
}
```

Each tree value has the ability to "unwrap" itself (using it's `unwrapped` property) into it's the best available
standard Swift type, returned as an  `Any`. As an example, unwrappingthe the JSON value `123.456` result in a Swift
`Double`.

Tree values are returned as an `Any` to allow easy support any possible tree value. For this reason the
``PotentCodables/TreeValueDecodingContainer`` has a convenience method to access the unwrapped tree value without
excessive casting.

Decoding unwrapped ``PotentJSON/JSON`` values using the ``PotentCodables/TreeValueDecodingContainer`` as follows:
```swift
func init(from decoder: Decoder) throws {
  let treeContainer = try decoder.singleValuedContainer() as! TreeValueDecodingContainer
  self.value = try treeContainer.decodeUnwrappedValue()
}
```
