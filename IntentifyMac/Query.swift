//
//  Query.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppIntents

struct ExtensionQuery: EnumerableEntityQuery, EntityStringQuery {
  func allEntities() async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities
  }

  func entities(for identifiers: [ExtensionEntity.ID]) async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities.filter {
      identifiers.contains($0.id)
    }
  }

  func entities(matching name: String) async throws -> [ExtensionEntity] {
    ExtensionEntity.allEntities.filter {
      $0.name.range(of: name, options: .caseInsensitive) != nil
    }
  }
}
