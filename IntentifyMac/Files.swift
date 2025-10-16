//
//  Files.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import Foundation
import IntentifyKit

enum Files {
  static let userFolder = URL.documentsDirectory.appending(path: folderName)

  static var intentifyScript: String? {
    guard let url = Bundle.main.url(forResource: "Intentify", withExtension: "js") else {
      Logger.assertFail("Missing Intentify.js in main bundle")
      return nil
    }

    return try? Data(contentsOf: url).toString()
  }

  static func copyFiles(force: Bool = false) {
    guard let bundleFolder else {
      return Logger.assertFail("Missing \(folderName) bundle folder")
    }

    FileManager.default.copyFiles(
      from: bundleFolder,
      to: userFolder,
      force: force
    )

    Indexer.startIndexing()
  }

  static var extensionFileURLs: [URL] {
    FileManager.default.fileURLs(in: userFolder)
      .filter { $0.lowercasedPathExtension == "js" }
  }

  static var extensionFileNames: [String] {
    extensionFileURLs.map { $0.lastPathComponent }
  }

  static func contents(of entity: ExtensionEntity) -> String {
    guard let data = try? Data(contentsOf: userFolder.appending(path: entity.id)) else {
      Logger.assertFail("Missing file of: \(entity)")
      return ""
    }

    return data.toString() ?? ""
  }
}

// MARK: - Private

private extension Files {
  private static let folderName = "Extensions"
  private static let bundleFolder = Bundle.main.url(forResource: folderName, withExtension: nil)
}
