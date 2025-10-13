//
//  Bundle+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import Foundation

public extension Bundle {
  var shortVersionString: String {
    guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
      Logger.assertFail("Missing CFBundleShortVersionString in bundle \(self)")
      return "1.0.0"
    }

    return version
  }
}
