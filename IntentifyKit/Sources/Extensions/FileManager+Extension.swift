//
//  FileManager+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import Foundation

public extension FileManager {
  func ensureFolder(url: URL) {
    guard !fileExists(atPath: url.path(percentEncoded: false)) else {
      return
    }

    do {
      try createDirectory(at: url, withIntermediateDirectories: true)
    } catch {
      Logger.log(.error, "\(error)")
    }
  }

  func fileURLs(in folder: URL) -> [URL] {
    (try? contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
  }
}
