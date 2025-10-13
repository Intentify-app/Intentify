//
//  Data+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import Foundation

public extension Data {
  /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/introStrings.html
  func toString(encoding: String.Encoding = .utf8) -> String? {
    // Perfect, successfully decoded it with the preferred encoding
    if let decoded = String(data: self, encoding: encoding) {
      return decoded
    }

    // Oh no, guess the encoding since we failed to decode it directly
    var converted: NSString?
    NSString.stringEncoding(
      for: self,
      encodingOptions: [
        // Just a blind guess, it's not possible to know without extra information
        .suggestedEncodingsKey: [
          String.Encoding(from: .GB_18030_2000).rawValue,
          String.Encoding(from: .big5).rawValue,
          String.Encoding.japaneseEUC.rawValue,
          String.Encoding.shiftJIS.rawValue,
          String.Encoding(from: .EUC_KR).rawValue,
          encoding.rawValue,
        ],
      ],
      convertedString: &converted,
      usedLossyConversion: nil
    )

    // It can still be nil
    return converted as? String
  }
}
