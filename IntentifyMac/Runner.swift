//
//  Runner.swift
//  Intentify
//
//  Created by cyan on 10/10/25.
//

import WebKit
import IntentifyKit

final class Runner: NSObject {
  static let shared = Runner()

  private lazy var webView: WKWebView = {
    class Configuration: WKWebViewConfiguration {
      // To mimic settable isOpaque on iOS,
      // which is required for the background color and initial white flash in dark mode
      @objc func _drawsBackground() -> Bool { false }
    }

    let handler = MessageHandler()
    handler.getContext = { [weak self] in self?.webView }

    let controller = WKUserContentController()
    controller.addScriptMessageHandler(handler, contentWorld: .page, name: "bridge")

    let config = Configuration()
    config.userContentController = controller

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.uiDelegate = self
    webView.isInspectable = true
    webView.allowsMagnification = true

    if let intentifyScript = Files.intentifyScript {
      webView.evaluateJavaScript(intentifyScript)
    }

    if config.preferences.responds(to: sel_getUid("_developerExtrasEnabled")) {
      config.preferences.setValue(true, forKey: "developerExtrasEnabled")
    } else {
      Logger.assertFail("Failed to overwrite developerExtrasEnabled in WKPreferences")
    }

    // Unlock fetch to work without CORS restrictions
    if config.preferences.responds(to: sel_getUid("_webSecurityEnabled")) {
      config.preferences.setValue(false, forKey: "webSecurityEnabled")
    } else {
      Logger.assertFail("Failed to overwrite webSecurityEnabled in WKPreferences")
    }

    // Unlock more API availability without a secure origin
    if config.preferences.responds(to: sel_getUid("_secureContextChecksEnabled")) {
      config.preferences.setValue(false, forKey: "secureContextChecksEnabled")
    } else {
      Logger.assertFail("Failed to overwrite secureContextChecksEnabled in WKPreferences")
    }

    return webView
  }()

  func exec(entity: ExtensionEntity, input: String) async throws -> [ResultEntity] {
    let result = try await {
      do {
        return try await webView.callAsyncJavaScript(
          entity.executable(with: input),
          contentWorld: .page
        )
      } catch {
        if let exception = (error as NSError).userInfo["WKJavaScriptExceptionMessage"] {
          // Provide a more meaningful report than just "A JavaScript exception occurred"
          throw NSError(domain: "Intentify", code: -100, userInfo: [
            NSLocalizedDescriptionKey: "Extension “\(entity.name)” raised a JavaScript Exception: “\(exception)”."
          ])
        }

        throw error
      }
    }()

    // If the extension returns no value, the input is passed to the next action
    return ResultEntity.parse(result: result ?? input)
  }

  override private init() {}
}

// MARK: - WKUIDelegate

extension Runner: WKUIDelegate {
  func webView(
    _ webView: WKWebView,
    createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    // Open links natively instead of creating new browsers
    if let url = navigationAction.request.url {
      NSWorkspace.shared.open(url)
    }

    return nil
  }

  // Handles window.alert()
  func webView(
    _ webView: WKWebView,
    runJavaScriptAlertPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo
  ) async {
    await showAlertPanel(message: message, cancellable: false)
  }

  // Handles window.confirm()
  func webView(
    _ webView: WKWebView,
    runJavaScriptConfirmPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo
  ) async -> Bool {
    await showAlertPanel(message: message)
  }

  // Handles window.prompt()
  func webView(
    _ webView: WKWebView,
    runJavaScriptTextInputPanelWithPrompt prompt: String,
    defaultText: String?,
    initiatedByFrame frame: WKFrameInfo
  ) async -> String? {
    let inputField = NSTextField(frame: CGRect(x: 0, y: 0, width: 240, height: 24))
    inputField.stringValue = defaultText ?? ""

    let accepted = await showAlertPanel(
      message: prompt,
      accessoryView: inputField
    )

    return accepted ? inputField.stringValue : nil
  }

  @discardableResult
  private func showAlertPanel(
    message: String,
    cancellable: Bool = true,
    accessoryView: NSView? = nil
  ) async -> Bool {
    let alert = NSAlert()
    alert.messageText = message
    alert.accessoryView = accessoryView

    if cancellable {
      alert.addButton(withTitle: String(localized: "OK"))
      alert.addButton(withTitle: String(localized: "Cancel"))
    }

    let presentSheetModal = {
      guard let window = NSApp.keyWindow else {
        return alert.runModal()
      }

      return await alert.beginSheetModal(for: window)
    }

    NSApp.bringToFront()
    return await presentSheetModal() == .alertFirstButtonReturn
  }
}

// MARK: - Private

private class MessageHandler: NSObject, Sendable, WKScriptMessageHandlerWithReply {
  var getContext: (() -> WKWebView?)?

  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) async -> (Any?, String?) {
    let reportError: (String) -> (Any?, String?) = { message in
      Logger.assertFail(message)
      return (nil, message)
    }

    guard message.name == "bridge" else {
      return reportError("Invalid message name: \(message.name)")
    }

    guard let body = message.body as? [String: Any],
          let command = body["command"] as? String,
          let parameters = body["parameters"] as? [String: Any] else {
      return reportError("Invalid message body: \(message.body)")
    }

    if command == "askAI", let prompt = parameters["prompt"] as? String {
      return await Intelligence.shared.respondTo(prompt: prompt)
    }

    if command == "renderUI", let context = getContext?() {
      return await Renderer.shared.renderUI(context: context, parameters: parameters)
    }

    if command == "returnValue" {
      return await Renderer.shared.returnValue(parameters["value"], explicitly: true)
    }

    if command == "runService", let name = parameters["name"] as? String {
      return await NSPasteboard.general.runService(name, input: parameters["input"])
    }

    return reportError("Invalid message: \(body)")
  }
}

private extension ExtensionEntity {
  func executable(with input: String) -> String {
    """
    return (() => {
      \(Files.contents(of: self))
      return main(\(input.quoteEscaped));
    })();
    """
  }
}
