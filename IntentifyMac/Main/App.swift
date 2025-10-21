//
//  App.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import SwiftUI
import IntentifyKit

@main
struct IntentifyApp: App {
  init () {
    Files.copyFiles()
    Files.copyTypeDefinition()

    let checkUpdates: @Sendable () -> Void = {
      Task {
        await Updater.checkForUpdates()
      }
    }

    // Check for updates on launch with a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: checkUpdates)

    // Check for updates on a weekly basis, for users who never quit apps
    Timer.scheduledTimer(withTimeInterval: 7 * 24 * 60 * 60, repeats: true) { _ in
      checkUpdates()
    }
  }

  var body: some Scene {
    WindowGroup(id: windowId) {
      IntentifyView()
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(.contentSize)
    .commands {
      CommandGroup(replacing: .help) {}
    }
  }
}

// MARK: - Private

private let windowId = "IntentifyWindow"

private struct IntentifyView: View {
  @Environment(\.openWindow)
  private var openWindow

  @Environment(\.dismissWindow)
  private var dismissWindow

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .bottom, spacing: 0) {
        if let appIcon = NSImage(named: "AppIcon") {
          Image(nsImage: appIcon)
            .resizable()
            .frame(width: 28, height: 28)

          StableInset(length: 4)
        }

        Text("[Intentify](https://github.com/Intentify-app/Intentify)")
          .font(Font.largeTitle)
          .fontWeight(.heavy)
          .padding(.bottom, -2)
          .tint(.blue)

        Text(" extends **[Spotlight](https://support.apple.com/guide/mac-help/mchlp1008/mac)** **\(Image(systemName: "magnifyingglass"))** by running **[JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)**, with ")

        Text("Apple Intelligence")
          .bold()
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(stops: [
                .init(color: Color(hex: 0x0894FF), location: 0.0),
                .init(color: Color(hex: 0x6C7BFF), location: 0.12),
                .init(color: Color(hex: 0xC959DD), location: 0.25),
                .init(color: Color(hex: 0xFF2E54), location: 0.55),
                .init(color: Color(hex: 0xFF9004), location: 0.95),
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .onTapGesture {
            if let url = URL(string: "https://www.apple.com/apple-intelligence/") {
              NSWorkspace.shared.open(url)
            }
          }

        Text(" support.")
      }
      .tint(.accentColor)

      StableInset()

      HStack(spacing: 0) {
        Text("Run ")
        Text("Extension").tintedLabel()
        Text(" with ")
        Text("Input").tintedLabel()
      }
      .padding(10)
      .font(.system(size: 18))
      .borderedRect(cornerRadius: 14)

      StableInset()

      Text("To get started, create _extension.js_ files like this:")

      VStack(alignment: .trailing) {
        VStack(alignment: .leading) {
          HStack(spacing: 0) {
            Text("async function").foregroundStyle(Color.syntaxRed)
            Text(" main").foregroundStyle(Color.syntaxPurple)
            Text("(").foregroundStyle(Color.syntaxDarkBlue)
            Text("input").foregroundStyle(Color.syntaxOrange)
            Text(") {").foregroundStyle(Color.syntaxDarkBlue)
          }
          HStack(spacing: 0) {
            Text("  return ").foregroundStyle(Color.syntaxRed)
            Text("'Intentified!'").foregroundStyle(Color.syntaxBlue)
            Text(";").foregroundStyle(Color.syntaxGray)
          }
          Text("}").foregroundStyle(Color.syntaxDarkBlue)
        }
        .monospaced()

        Button("Copy") {
          NSPasteboard.general.string = "async function main(input) {\n  return 'Intentified!';\n}"
        }
        .foregroundStyle(.white)
        .controlSize(.small)
        .buttonStyle(.bordered)
        .keyboardShortcut(KeyEquivalent("c"), modifiers: .command)
      }
      .padding(8)
      .background(Color.snippetBlack)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

      StableInset()

      HStack(spacing: 0) {
        Text("Place them in the ")

        Button("**Extensions** (⌘-E)") {
          NSWorkspace.shared.open(Files.userFolder)
        }
        .buttonStyle(.glass)
        .keyboardShortcut(KeyEquivalent("e"), modifiers: .command)
        .contextMenu {
          ForEach(NSWorkspace.shared.urlsForApplications(toOpen: Files.userFolder), id: \.self) { app in
            Button {
              NSWorkspace.shared.open(
                [Files.userFolder],
                withApplicationAt: app,
                configuration: .init()
              )
            } label: {
              Label {
                Text("Open with \(app.lastPathComponent)")
              } icon: {
                Image(nsImage: NSWorkspace.shared.icon(forFile: app.path(percentEncoded: false)))
              }
            }
          }
        }

        Text(" folder and ")

        Button("**relaunch** (⌘-R)") {
          Indexer.startIndexing()
          dismissWindow(id: windowId)

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            openWindow(id: windowId)
          }
        }
        .buttonStyle(.glass)
        .keyboardShortcut(KeyEquivalent("r"), modifiers: .command)

        Text(" the app to apply.")
      }

      HStack(spacing: 0) {
        Text("Invoke Spotlight with ")
        Text("⌘-space").codeStyle()
        Text(" and type ")
        Text("run extension").codeStyle()
        Text(" to use them.")
      }

      StableInset()

      HStack(spacing: 0) {
        Text("Intentify includes **[built-in examples](https://github.com/Intentify-app/Intentify/tree/main/IntentifyMac/Resources/Extensions)** that you can ")
          .tint(.accentColor)

        StatefulButton("**restore**") {
          Files.copyFiles(force: true)
        }

        Text(" if modified or deleted.")
      }

      StableInset()

      Divider()

      HStack(spacing: 0) {
        Image(systemName: "heart.fill")
          .foregroundColor(.red)

        Text(" Learn more in the **[wiki](https://github.com/Intentify-app/Intentify/wiki)** and **[source code](https://github.com/Intentify-app/Intentify)**.")

        Spacer()

        Text("_[Version \(Bundle.main.shortVersionString)](https://github.com/Intentify-app/Intentify/releases)_")
          .tint(.gray)
      }
      .padding(.bottom, 8)
      .padding(.vertical, 6)
      .tint(.accentColor)
    }
    .font(.system(size: 15))
    .padding([.top, .horizontal], 20)
    .fixedSize()
  }
}

#Preview {
  IntentifyView()
}
