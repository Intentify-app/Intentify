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
    let handler = MessageHandler()
    handler.getContext = { [weak self] in self?.webView }

    let controller = WKUserContentController()
    controller.addScriptMessageHandler(handler, contentWorld: .page, name: "bridge")

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

    guard let body = message.body as? [String: Any], let parameters = body["parameters"] as? [String: Any] else {
      return reportError("Invalid message body: \(message.body)")
    }

    if body["command"] as? String == "askAI", let prompt = parameters["prompt"] as? String {
      return (await Intelligence.shared.respondTo(prompt: prompt), nil)
    }

    if body["command"] as? String == "renderUI", let context = getContext?() {
      return (await Renderer.shared.renderUI(context: context, parameters: parameters), nil)
    }

    if body["command"] as? String == "returnValue" {
      return (Renderer.shared.returnValue(parameters["value"], explicitly: true), nil)
    }

    return ("Invalid message: \(body)", nil)
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
