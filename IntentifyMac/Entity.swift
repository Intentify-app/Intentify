//
//  Entity.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppKit
import AppIntents
import SwiftUI
import IntentifyKit

struct ExtensionEntity: IndexedEntity {
  struct Metadata: Codable {
    let description: String?
    let image: String?
  }

  static let defaultQuery = ExtensionQuery()
  static var typeDisplayRepresentation: TypeDisplayRepresentation { "Extension" }

  static var allEntities: [Self] {
    Files.extensionFileNames.map { Self(id: $0) }
  }

  var id: String
  var metadata: Metadata?

  @ComputedProperty(indexingKey: \.displayName)
  var name: String { id.lastPathComponent(deletePathExtension: true) }

  @ComputedProperty(indexingKey: \.contentDescription)
  var description: String { metadata?.description ?? "Run “\(id)” in Intentify." }

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(description)",
      image: DisplayRepresentation.Image(with: metadata?.image ?? "curlybraces")
    )
  }

  init(id: String) {
    self.id = id

    if let json = try? Data(contentsOf: Files.metadataFolder.appending(path: "\(name).json")) {
      self.metadata = try? JSONDecoder().decode(Metadata.self, from: json)
    }
  }
}

struct ResultEntity: AppEntity {
  struct DummyQuery: EntityQuery {
    func entities(for identifiers: [ResultEntity.ID]) async throws -> [ResultEntity] { [] }
    func suggestedEntities() async throws -> [ResultEntity] { [] }
  }

  static let defaultQuery = DummyQuery()
  static var typeDisplayRepresentation: TypeDisplayRepresentation { "Result" }

  var id: String { title }
  var title: String
  var subtitle: String?
  var image: String?

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(title)",
      subtitle: subtitle.map { "\($0)" },
      image: DisplayRepresentation.Image(with: image)
    )
  }

  var shouldCopy: Bool {
    !title.isEmpty
  }

  static func parse(result: Any) -> [Self] {
    ((result as? [Any]) ?? [result]).map { item in
      if let json = item as? [String: String], let title = json["title"] {
        return Self(title: title, subtitle: json["subtitle"], image: json["image"])
      }

      return Self(title: "\(item)")
    }
  }
}

// MARK: - Snippet View

extension ResultEntity {
  var showsSnippet: Bool {
    title.count > 100 && subtitle == nil && image == nil
  }

  var snippetView: some View {
    Text(title)
  }
}

// MARK: - Private

private extension DisplayRepresentation.Image {
  init?(with image: String?) {
    guard let image else {
      return nil
    }

    if let data = NSImage.with(symbolName: image)?.pngData ?? NSImage.base64Data(with: image) {
      self = Self(data: data, isTemplate: false)
    } else {
      self = Self(systemName: image, isTemplate: true)
    }
  }
}
