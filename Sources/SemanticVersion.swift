/***************************************************************************************************
 SemanticVersion.swift
  © 2017 YOCKOW.
    Licensed under MIT License.
    See "LICENSE.txt" for more information.
 **************************************************************************************************/

import Foundation

/// Represents for [semantic versioning](http://semver.org/)
///
/// ```
/// let version = SemanticVersion("1.0.0-beta.2+20170904.001")!
/// // {
/// //   major: 1,
/// //   minor: 0,
/// //   patch: 0,
/// //   prereleaseIdentifiers: "beta.2"
/// //   buildMetadataIdentifiers: "20170904.001"
/// // }
/// ```
public struct SemanticVersion {
  fileprivate enum Component: CustomStringConvertible, Comparable {
    case integer(UInt)
    case string(String)
    fileprivate var description: String {
      switch self {
      case .integer(let integer): return String(integer)
      case .string(let string): return string
      }
    }
    fileprivate static func ==(lhs:Component, rhs:Component) -> Bool {
      switch (lhs, rhs) {
      case (.integer(let lint), .integer(let rint)) where lint == rint: return true
      case (.string(let lstr), .string(let rstr)) where lstr == rstr: return true
      default: return false
      }
    }
    /// Identifiers consisting of only digits are compared numerically.
    /// Identifiers with letters or hyphens are compared lexically in ASCII sort order.
    /// Numeric identifiers always have lower precedence than non-numeric identifiers.
    fileprivate static func <(lhs:Component, rhs:Component) -> Bool {
      switch (lhs, rhs) {
      case (.integer, .string): return true
      case (.string, .integer): return false
      case (.integer(let lint), .integer(let rint)): return lint < rint
      case (.string(let lstr), .string(let rstr)): return lstr < rstr
      }
    }
  }
  private var _major: Component
  private var _minor: Component
  private var _patch: Component
  fileprivate var _prereleaseIdentifiers: [Component] = []
  private var _buildMetadataIdentifiers: [Component] = []
  
  public var major: UInt {
    get {
      guard case .integer(let integer) = self._major else { fatalError("Never Reached...") }
      return integer
    }
    set {
      self._major = .integer(newValue)
    }
  }
  
  public var minor: UInt {
    get {
      guard case .integer(let integer) = self._minor else { fatalError("Never Reached...") }
      return integer
    }
    set {
      self._minor = .integer(newValue)
    }
  }
  
  public var patch: UInt {
    get {
      guard case .integer(let integer) = self._patch else { fatalError("Never Reached...") }
      return integer
    }
    set {
      self._patch = .integer(newValue)
    }
  }
  
  public var prereleaseIdentifiers: String? {
    get {
      guard self._prereleaseIdentifiers.count > 0 else { return nil }
      return self._prereleaseIdentifiers.map{ $0.description }.joined(separator:".")
    }
    set {
      guard let identifiers = newValue,
        let components = Array<Component>(string:identifiers, allowingLeadingZeros:false) else {
          self._prereleaseIdentifiers = []
          return
      }
      self._prereleaseIdentifiers = components
    }
  }
  
  public var buildMetadataIdentifiers: String? {
    get {
      guard self._buildMetadataIdentifiers.count > 0 else { return nil }
      return self._buildMetadataIdentifiers.map{ $0.description }.joined(separator:".")
    }
    set {
      guard let identifiers = newValue,
        let components = Array<Component>(string:identifiers, allowingLeadingZeros:true) else {
          self._buildMetadataIdentifiers = []
          return
      }
      self._buildMetadataIdentifiers = components
    }
  }
  
  public init(_ major:UInt,
              _ minor:UInt,
              _ patch:UInt,
              _ prerelease:String? = nil,
              _ buildMetadata:String? = nil) {
    self._major = .integer(major)
    self._minor = .integer(minor)
    self._patch = .integer(patch)
    self.prereleaseIdentifiers = prerelease
    self.buildMetadataIdentifiers = buildMetadata
  }
  
  public init?(_ string:String) {
    let split: (String, Character) -> (String, String?) = {
      if let index = $0.index(of:$1) {
        #if swift(>=4.0)
        return (String($0[$0.startIndex..<index]), String($0[$0.index(after:index)..<$0.endIndex]))
        #else
        return ($0[$0.startIndex..<index], $0[$0.index(after:index)..<$0.endIndex])
        #endif
      } else {
        return ($0, nil)
      }
    }
    
    let (majorMinorPatchPrerelease, buildMetadata): (String, String?) = split(string, "+")
    let (majorMinorPatch, prerelease): (String, String?) = split(majorMinorPatchPrerelease, "-")
    
    let components:[UInt?] = majorMinorPatch.components(separatedBy:".").map{UInt(strictString:$0)}
    guard components.count == 3 else { return nil }
    
    guard let major = components[0] else { return nil }
    guard let minor = components[1] else { return nil }
    guard let patch = components[2] else { return nil }
    
    self.init(major, minor, patch, prerelease, buildMetadata)
  }
}

extension SemanticVersion: CustomStringConvertible {
  public var description: String {
    var desc = "\(self.major).\(self.minor).\(self.patch)"
    if let prerelease = self.prereleaseIdentifiers { desc += "-\(prerelease)" }
    if let buildMetadata = self.buildMetadataIdentifiers { desc += "+\(buildMetadata)" }
    return desc
  }
}

extension SemanticVersion: Comparable {
  public static func ==(lhs:SemanticVersion, rhs:SemanticVersion) -> Bool {
    if lhs.major != rhs.major { return false }
    if lhs.minor != rhs.minor { return false }
    if lhs.patch != rhs.patch { return false }
    if lhs.prereleaseIdentifiers != rhs.prereleaseIdentifiers { return false }
    return true
  }
  
  /// reference: http://semver.org/#spec-item-11
  /// Build metadata does not figure into precedence
  public static func <(lhs:SemanticVersion, rhs:SemanticVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    } else if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    } else if lhs.patch != rhs.patch {
      return lhs.patch < rhs.patch
    } else {
      // When major, minor, and patch are equal,
      // a pre-release version has lower precedence than a normal version
      // Example: 1.0.0-alpha < 1.0.0
      switch (lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers) {
      case (.none, .none): return false
      case (.some, .none): return true
      case (.none, .some): return false
      case (.some, .some):
        // A larger set of pre-release fields has a higher precedence than a smaller set,
        // if all of the preceding identifiers are equal.
        // Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2
        //          < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
        let lComponents = lhs._prereleaseIdentifiers
        let rComponents = rhs._prereleaseIdentifiers
        let nn = min(lComponents.count, rComponents.count)
        for ii in 0..<nn {
          let lComponent = lComponents[ii]
          let rComponent = rComponents[ii]
          if lComponent != rComponent { return lComponent < rComponent }
        }
        return lComponents.count < rComponents.count
      }
      
    }
  }
}


extension Array where Element == SemanticVersion.Component {
  fileprivate init?(string:String, allowingLeadingZeros:Bool) {
    self.init()
    
    let numerics = CharacterSet(charactersIn:"0123456789")
    let alphanumerics = CharacterSet(charactersIn:"-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    
    let identifiers = string.components(separatedBy:".")
    for identifier in identifiers {
      guard !identifier.isEmpty else { return nil }
      
      if identifier.consists(of:numerics) {
        if identifier[identifier.startIndex] != "0" || identifier == "0" {
          self.append(.integer(UInt(identifier)!))
          continue
        } else if !allowingLeadingZeros {
          return nil
        }
      }
      
      guard identifier.consists(of:alphanumerics) else { return nil }
      self.append(.string(identifier))
    }
  }
}

extension String {
  /**
   
   Returns true if all of characters(unicode code points) are contained in `characters`
   
   */
  fileprivate func consists(of characters:CharacterSet) -> Bool {
    let scalars = self.unicodeScalars
    var ii = scalars.startIndex
    while true {
      if ii == scalars.endIndex { break }
      defer { ii = scalars.index(after:ii) }
      guard characters.contains(scalars[ii]) else { return false }
    }
    return true
  }
  
  #if swift(>=4.0)
  #else
  fileprivate func index(of element:Character) -> String.Index? {
    return self.range(of:String(element))?.lowerBound
  }
  #endif
}

extension UInt {
  /**
   
   Returns nil if `string` contains leading zeroes
   
   */
  fileprivate init?(strictString string:String) {
    if string != "0" && string[string.startIndex] == "0" { return nil }
    self.init(string)
  }
}
