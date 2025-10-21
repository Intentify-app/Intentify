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

  func runService(_ name: String, input: Any?) async -> (Bool, String?) {
    let content = input as? String
    string = content ?? ""

    // The pasteboard item is used as input, but it's not done synchronously
    let succeeded = NSPerformService(name, self)
    try? await Task.sleep(for: .seconds(0.5))

    return (succeeded, succeeded ? nil : "Failed to perform the service")
  }
}
