# What is SwiftSemanticVersion?

Yet another implementation of [Semantic Versioning](http://semver.org/) in Swift.


## Sample Code

```Swift
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


# License

MIT License.  
See "LICENSE.txt" for more information.
