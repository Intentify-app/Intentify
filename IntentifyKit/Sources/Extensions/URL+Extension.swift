//
//  URL+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import Foundation

public extension URL {
  var lowercasedPathExtension: String {
    pathExtension.lowercased()
  }
}
