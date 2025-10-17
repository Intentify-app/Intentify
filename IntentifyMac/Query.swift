//
//  Query.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppIntents

struct ExtensionQuery: EnumerableEntityQuery, EntityStringQuery {
  func suggestedEntities() async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities
  }

  func allEntities() async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities
  }

  func entities(for identifiers: [ExtensionEntity.ID]) async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities.filter {
      identifiers.contains($0.id)
    }
  }

  func entities(matching pattern: String) async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities.filter { entity in
      [entity.name, entity.description].contains {
        $0.localizedCaseInsensitiveContains(pattern)
      }
    }
  }
}
