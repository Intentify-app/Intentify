//
//  Indexer.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppIntents
import CoreSpotlight

enum Indexer {
  static func startIndexing() {
    Task {
      try await CSSearchableIndex.default().deleteAllSearchableItems()
      try await CSSearchableIndex.default().indexAppEntities(ExtensionEntity.allEntities)
    }
  }
}
