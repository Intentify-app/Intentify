//
//  Renderer.swift
//  IntentifyMac
//
//  Created by cyan on 10/16/25.
//

import AppKit
import WebKit
import IntentifyKit
import os.log

final class Renderer: NSObject {
  static let shared = Renderer()

  private let window: NSWindow = {
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .resizable, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )

    window.isReleasedWhenClosed = false
    return window
  }()

  private var resumeContinuation: ((Any?) -> Void)?

  func renderUI(context: WKWebView, parameters: [String: Any]?) async -> Any? {
    let html = parameters?["html"] as? String
    let options = parameters?["options"] as? [String: Any]

    let title = (options?["title"] as? String) ?? "Intentify"
    let width = (options?["width"] as? Double) ?? 480
    let height = (options?["height"] as? Double) ?? 270
    let size = CGSize(width: width, height: height)

    NotificationCenter.default.removeObserver(
      self,
      name: NSWindow.willCloseNotification,
      object: nil
    )

    closeWindows()
    NSApp.activate(ignoringOtherApps: true)
    NSApp.setActivationPolicy(.accessory)

    context.frame = CGRect(origin: .zero, size: size)
    window.setContentSize(size)

    window.title = title
    window.contentView = context

    window.center()
    window.makeKeyAndOrderFront(nil)

    do {
      try await context.evaluateJavaScript(
        "document.body.innerHTML = \((html ?? "").quoteEscaped);"
      )
    } catch {
      Logger.log(.error, "\(error)")
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowWillClose(_:)),
      name: NSWindow.willCloseNotification,
      object: nil
    )

    return await withCheckedContinuation { [weak self] continuation in
      self?.resumeContinuation = {
        continuation.resume(returning: $0)
      }
    }
  }

  func returnValue(_ value: Any?, shouldCloseWindow: Bool = true) -> Any? {
    resumeContinuation?(value)
    resumeContinuation = nil

    if shouldCloseWindow {
      closeWindows()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      NSApp.terminate(nil)
    }

    return value
  }

  override private init() {}
}

// MARK: - Private

private extension Renderer {
  func closeWindows() {
    NSApp.windows.forEach { $0.close() }
  }

  @objc func windowWillClose(_ notification: Notification) {
    guard (notification.object as? NSWindow) == window, window.isVisible else {
      return
    }

    _ = returnValue(nil, shouldCloseWindow: false)
  }
}
