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
    let controller = WKUserContentController()
    controller.addScriptMessageHandler(MessageHandler(), contentWorld: .page, name: "bridge")

    let config = WKWebViewConfiguration()
    config.userContentController = controller

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.uiDelegate = self
    webView.isInspectable = true

    if let intentifyScript = Files.intentifyScript {
      webView.evaluateJavaScript(intentifyScript)
    }

    // Unlock fetch to work without CORS restrictions
    if config.preferences.responds(to: sel_getUid("_webSecurityEnabled")) {
      config.preferences.setValue(false, forKey: "webSecurityEnabled")
    }

    // Unlock more API availability without a secure origin
    if config.preferences.responds(to: sel_getUid("_secureContextChecksEnabled")) {
      config.preferences.setValue(false, forKey: "secureContextChecksEnabled")
    }

    return webView
  }()

  func exec(entity: ExtensionEntity, input: String) async -> [ResultEntity] {
    do {
      let executable = entity.executable(with: input)
      if let result = try await webView.callAsyncJavaScript(executable, contentWorld: .page) {
        return ResultEntity.parse(result: result)
      }

      return [.error(with: "<null>")]
    } catch {
      // Don't use the default AppIntents error handling, which doesn't show meaningful error message
      return [.error(with: "\(error)")]
    }
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
}

// MARK: - Private

private class MessageHandler: NSObject, Sendable, WKScriptMessageHandlerWithReply {
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

    guard let body = message.body as? [String: Any], let parameters = body["parameters"] as? [String: Any] else {
      return reportError("Invalid message body: \(message.body)")
    }

    if body["command"] as? String == "askAI", let prompt = parameters["prompt"] as? String {
      return (await Intelligence.shared.respondTo(prompt: prompt), nil)
    }

    return ("Invalid message: \(body)", nil)
  }
}

private extension ExtensionEntity {
  func executable(with input: String) -> String {
    """
    return (() => {
      \(Files.contents(of: self))
      return main(\(escape(input)));
    })();
    """
  }

  func escape(_ input: String) -> String {
    guard let data = try? JSONEncoder().encode(input), let json = data.toString() else {
      return "\"\""
    }

    return json
  }
}
