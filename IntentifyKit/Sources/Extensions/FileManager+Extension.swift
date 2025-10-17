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

  func copyFiles(from sourceFolder: URL, to targetFolder: URL, force: Bool = false) {
    ensureFolder(url: targetFolder)

    do {
      let sourceURLs = try contentsOfDirectory(
        at: sourceFolder,
        includingPropertiesForKeys: nil
      )

      for sourceURL in sourceURLs {
        let targetURL = targetFolder.appending(path: sourceURL.lastPathComponent)
        let targetPath = targetURL.path(percentEncoded: false)

        if force && fileExists(atPath: targetPath) {
          try removeItem(at: targetURL)
        }

        if !fileExists(atPath: targetPath) {
          try copyItem(at: sourceURL, to: targetURL)
        }
      }
    } catch {
      Logger.log(.error, "\(error)")
    }
  }

  func fileURLs(in folder: URL) -> [URL] {
    (try? contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
  }
}
