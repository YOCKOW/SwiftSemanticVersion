import XCTest
@testable import SemanticVersion

class SemanticVersionTests: XCTestCase {
  func testInitializer() {
    let string1 = "0.1.0"
    let string2 = "1.0.0-beta.2+20170904.001"
    let version1 = SemanticVersion(string1)
    let version2 = SemanticVersion(string2)
    XCTAssertNotNil(version1, "Succeeded to initialize")
    XCTAssertNotNil(version2, "Succeeded to initialize")
    
    XCTAssertEqual(version1!.description, string1, "Description Test")
    
    XCTAssertEqual(version2!.major, 1, "Major")
    XCTAssertEqual(version2!.minor, 0, "Minor")
    XCTAssertEqual(version2!.patch, 0, "Patch")
    XCTAssertEqual(version2!.prereleaseIdentifiers, "beta.2", "Pre-release")
    XCTAssertEqual(version2!.buildMetadataIdentifiers, "20170904.001", "Pre-release")
  }
  
  func testComparable() {
    let versions = [
      SemanticVersion("1.0.0-alpha")!,
      SemanticVersion("1.0.0-alpha.1")!,
      SemanticVersion("1.0.0-alpha.beta")!,
      SemanticVersion("1.0.0-beta")!,
      SemanticVersion("1.0.0-beta.2")!,
      SemanticVersion("1.0.0-beta.11")!,
      SemanticVersion("1.0.0-rc.1")!,
      SemanticVersion("1.0.0")!
    ]
    
    for ii in 0..<(versions.count - 1) {
      let ll = versions[ii]
      let rr = versions[ii + 1]
      XCTAssertLessThan(ll, rr, "\(ll.description) must be less than \(rr.description)")
    }
    
    for ii in 0..<(versions.count - 2) {
      let ll = versions[ii]
      let rr = versions[ii + 2]
      XCTAssertLessThan(ll, rr, "\(ll.description) must be less than \(rr.description)")
    }
  }
  
  static var allTests = [
    ("Test Initializer", testInitializer),
    ("Comparable", testComparable)
  ]
}
