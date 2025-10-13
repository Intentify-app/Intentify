//
//  NSPasteboard+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import AppKit

public extension NSPasteboard {
  var string: String? {
    get {
      string(forType: .string)
    }
    set {
      guard let newValue else {
        return
      }

      declareTypes([.string], owner: nil)
      setString(newValue, forType: .string)
    }
  }
}
