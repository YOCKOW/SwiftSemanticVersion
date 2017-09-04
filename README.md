# What is SwiftSemanticVersion?
Yet another implementation of [Semantic Versioning](http://semver.org/) in Swift.

## Sample Code

```
import SemanticVersion

let version = SemanticVersion("1.0.0-beta.2+20170904.001")!
// {
//   major: 1,
//   minor: 0,
//   patch: 0,
//   prereleaseIdentifiers: "beta.2"
//   buildMetadataIdentifiers: "20170904.001"
// }
```

## Protocols
SemanticVersion conforms to `Comparable` and `CustomStringConvertible`

# How to use
Build and install:  
`./build-install.rb --install-prefix=/path/to/your/system --install`  
Then, you can use it in your project:  
`swiftc ./your/project/main.swift -I/path/to/your/system/include -L/path/to/your/system/lib -lSwiftSemanticVersion`  

