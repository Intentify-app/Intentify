//
//  Intents.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import AppKit
import AppIntents
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

  @Parameter(title: "Input", description: "The input value for running the extension. Uses an empty string if omitted.", default: "", inputOptions: String.IntentInputOptions(capitalizationType: .none, multiline: true, autocorrect: false, smartQuotes: false, smartDashes: false))
  var input: String?

  func perform() async throws -> some ReturnsValue<[ResultEntity]> {
    let result = await Runner.shared.exec(
      entity: self.extension,
      input: input ?? ""
    )

    if let first = result.first, !first.error {
      NSPasteboard.general.string = first.title
    }

    return .result(value: result)
  }
}
