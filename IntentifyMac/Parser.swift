//
//  Parser.swift
//  IntentifyMac
//
//  Created by cyan on 10/16/25.
//

import Foundation
import JavaScriptCore
import IntentifyKit

struct Comment: Codable {
  struct Tag: Codable {
    let name: String?
    let value: String?
  }

  let description: String?
  let tags: [Tag]?
}

final class Parser: NSObject {
  static let shared = Parser()

  func parserComments(code: String) throws -> [Comment]? {
    guard let util = context?.objectForKeyedSubscript("window") else {
      Logger.assertFail("Failed to get the window object")
      return nil
    }

    guard let results = (util.invokeMethod("parseComments", withArguments: [code, "main"])).toArray() else {
      Logger.assertFail("Failed to invoke the parseComments method")
      return nil
    }

    let json = try JSONSerialization.data(withJSONObject: results, options: [])
    let comments = try JSONDecoder().decode([Comment].self, from: json)
    return comments
  }

  private let context: JSContext? = {
    let context = JSContext()
    Logger.assert(context != nil, "Failed to initiate JSContext")

    context?.evaluateScript("var window = {};\n" + {
      guard let parserScript = Files.parserScript else {
        Logger.assertFail("Failed to load Parser.js")
        return ""
      }

      return parserScript
    }())

    return context
  }()

  override private init() {}
}
