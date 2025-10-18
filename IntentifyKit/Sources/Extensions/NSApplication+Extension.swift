//
//  NSApplication+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/18/25.
//

import AppKit

public extension NSApplication {
  func bringToFront() {
    activate(ignoringOtherApps: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      guard !self.isActive else {
        return
      }

      // ignoringOtherApps is no longer reliable, use this as a fallback
      if let bundleIdentifier = Bundle.main.bundleIdentifier {
        NSWorkspace.shared.openApplication(with: bundleIdentifier)
      }
    }
  }
}

// MARK: - Private

private extension NSWorkspace {
  func openApplication(with bundleIdentifier: String) {
    guard let url = urlForApplication(withBundleIdentifier: bundleIdentifier) else {
      return
    }

    openApplication(at: url, configuration: .init())
  }
}
