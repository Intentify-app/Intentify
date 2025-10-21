//
//  Intents.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppKit
import AppIntents
import SwiftUI
import IntentifyKit

struct IntentProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    return [
      AppShortcut(
        intent: IntentifyIntent(),
        phrases: [
          "Run \(\.$extension) in \(.applicationName)",
        ],
        shortTitle: "\(IntentifyIntent.title)",
        systemImageName: "curlybraces.square"
      ),
    ]
  }
}

struct IntentifyIntent: AppIntent {
  static let title: LocalizedStringResource = "Run Extension"
  static let description = IntentDescription("Run an Intentify extension with input and get the result.")
  static var parameterSummary: some ParameterSummary {
    Summary("Run \(\.$extension) with \(\.$input)")
  }

  @Parameter(title: "Extension", description: "The extension file to run.")
  var `extension`: ExtensionEntity

  @Parameter(title: "Input", description: "The input value for running the extension. Uses an empty string if omitted.", default: "", inputOptions: String.IntentInputOptions(capitalizationType: .none, multiline: true, autocorrect: false, smartQuotes: false, smartDashes: false), inputConnectionBehavior: .connectToPreviousIntentResult)
  var input: String?

  func perform() async throws -> some ReturnsValue<[ResultEntity]> & ShowsSnippetView {
    let result = try await Runner.shared.exec(
      entity: self.extension,
      input: input ?? ""
    )

    if let entity = result.first {
      if entity.shouldCopy {
        NSPasteboard.general.string = entity.title
      }

      if result.count == 1 && self.extension.metadata?.showsDialog == true {
        return .result(value: result, view: entity.snippetView)
      }
    }

    // EmptyView() renders nothing but quits Spotlight for window.open()
    return .result(value: result, view: EmptyView())
  }
}

// Honestly, I'm not sure how it works and can hardly find any useful information online...
//
// Apple, please provide better documentation and sample code!
extension IntentifyIntent: PredictableIntent {
  static var predictionConfiguration: some IntentPredictionConfiguration {
    IntentPrediction(parameters: \.$extension) { parameter in
      DisplayRepresentation(
        title: "Run \(parameter.name) in Intentify",
        image: parameter.displayRepresentation.image
      )
    }
  }
}
