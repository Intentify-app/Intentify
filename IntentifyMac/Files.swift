//
//  Files.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import Foundation
import IntentifyKit
import os.log

enum Files {
  static let userFolder = URL.documentsDirectory.appending(path: folderName)
  static let metadataFolder = URL.documentsDirectory.appending(path: ".metadata")

  static var intentifyScript: String? {
    guard let url = Bundle.main.url(forResource: "Intentify", withExtension: "js") else {
      Logger.assertFail("Missing Intentify.js in main bundle")
      return nil
    }

    return try? Data(contentsOf: url).toString()
  }

  static var parserScript: String? {
    guard let url = Bundle.main.url(forResource: "Parser", withExtension: "js") else {
      Logger.assertFail("Missing Parser.js in main bundle")
      return nil
    }

    return try? Data(contentsOf: url).toString()
  }

  static func copyFiles(force: Bool = false) {
    guard let bundleFolder else {
      return Logger.assertFail("Missing \(folderName) bundle folder")
    }

    do {
      let fileManager = FileManager.default
      fileManager.ensureFolder(url: userFolder)

      let sourceURLs = try fileManager.contentsOfDirectory(
        at: bundleFolder,
        includingPropertiesForKeys: nil
      )

      var copiedBundleFiles = Preferences.General.copiedBundleFiles
      for sourceURL in sourceURLs {
        let filename = sourceURL.lastPathComponent
        let targetURL = userFolder.appending(path: filename)
        let targetPath = targetURL.path(percentEncoded: false)
        let shouldCopy = force || !copiedBundleFiles.contains(filename)

        if force && fileManager.fileExists(atPath: targetPath) {
          try fileManager.removeItem(at: targetURL)
        }

        if shouldCopy && !fileManager.fileExists(atPath: targetPath) {
          try fileManager.copyItem(at: sourceURL, to: targetURL)
        }

        copiedBundleFiles.insert(filename)
      }

      Preferences.General.copiedBundleFiles = copiedBundleFiles
    } catch {
      Logger.log(.error, "\(error)")
    }

    Indexer.startIndexing()
  }

  static func copyTypeDefinition() {
    guard let source = Bundle.main.url(forResource: "Intentify", withExtension: "d.ts") else {
      return Logger.assertFail("Missing Intentify.d.ts in main bundle")
    }

    let target = URL.documentsDirectory.appending(path: "Intentify.d.ts")
    try? FileManager.default.removeItem(at: target)

    do {
      try FileManager.default.copyItem(at: source, to: target)
    } catch {
      Logger.assertFail("Failed to copy type definition: \(error)")
    }
  }

  static func download(from url: URL, to folder: URL) async throws -> URL {
    let (source, response) = try await URLSession.shared.download(from: url)
    let target = folder.appending(path: response.suggestedFilename ?? url.lastPathComponent)

    if FileManager.default.fileExists(atPath: target.path(percentEncoded: false)) {
      try FileManager.default.removeItem(at: target)
    }

    try FileManager.default.moveItem(at: source, to: target)
    return target
  }

  static func generateMetadata() {
    try? FileManager.default.removeItem(at: metadataFolder)
    FileManager.default.ensureFolder(url: metadataFolder)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    for url in extensionFileURLs {
      let content = (try? Data(contentsOf: url))?.toString() ?? ""
      let comment = (try? Parser.shared.parseComments(code: content))?.first

      let metadata = ExtensionEntity.Metadata(
        description: comment?.description,
        image: (comment?.tags?.first { $0.name == "image" })?.value,
        showsDialog: (comment?.tags?.first { $0.name == "showsDialog" })?.value == "true"
      )

      let filename = url.deletingPathExtension().lastPathComponent
      let target = metadataFolder.appending(path: "\(filename).json")

      let data = try? encoder.encode(metadata)
      try? data?.write(to: target)
    }
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
