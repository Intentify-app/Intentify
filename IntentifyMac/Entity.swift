//
//  Entity.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppKit
import AppIntents
import IntentifyKit

struct ExtensionEntity: IndexedEntity {
  static let defaultQuery = ExtensionQuery()
  static var typeDisplayRepresentation: TypeDisplayRepresentation { "Extension" }

  static var allEntities: [Self] {
    Files.extensionFiles.map { Self(id: $0) }
  }

  var id: String

  @ComputedProperty(indexingKey: \.displayName)
  var name: String { id.lastPathComponent(deletePathExtension: true) }

  @ComputedProperty(indexingKey: \.contentDescription)
  var description: String { "Run “\(id)” in Intentify" }

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      image: DisplayRepresentation.Image(with: "curlybraces")
    )
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
  var error: Bool = false

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(title)",
      subtitle: subtitle.map { "\($0)" },
      image: DisplayRepresentation.Image(with: image)
    )
  }

  static func parse(result: Any) -> [Self] {
    ((result as? [Any]) ?? [result]).map { item in
      if let json = item as? [String: String], let title = json["title"] {
        return Self(title: title, subtitle: json["subtitle"], image: json["image"])
      }

      return Self(title: "\(item)")
    }
  }

  static func error(with message: String) -> Self {
    Self(title: message, image: "exclamationmark.circle", error: true)
  }
}

// MARK: - Private

private extension DisplayRepresentation.Image {
  init?(with image: String?) {
    guard let image else {
      return nil
    }

    if let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters) {
      self = DisplayRepresentation.Image(data: data)
    } else if let pngData = NSImage.with(symbolName: image)?.pngData {
      self = DisplayRepresentation.Image(data: pngData)
    } else {
      self = DisplayRepresentation.Image(systemName: image)
    }
  }
}
