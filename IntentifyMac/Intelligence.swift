//
//  Intelligence.swift
//  IntentifyMac
//
//  Created by cyan on 10/13/25.
//

import Foundation
import FoundationModels

final class Intelligence: NSObject {
  static let shared = Intelligence()

  func respondTo(prompt: String) async -> String {
    do {
      let response = try await session.respond(to: prompt)
      return response.content
    } catch {
      return error.localizedDescription
    }
  }

  override private init() {}

  private let session = LanguageModelSession()
}
