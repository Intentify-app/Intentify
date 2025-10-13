//
//  String+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/11/25.
//

import Foundation

public extension String {
  /// Overload of the String.Encoding version.
  init?(data: Data, encoding: CFStringEncodings) {
    self.init(data: data, encoding: String.Encoding(from: encoding))
  }

  /// Overload of the String.Encoding version.
  func data(using encoding: CFStringEncodings, allowLossyConversion: Bool = false) -> Data? {
    data(using: String.Encoding(from: encoding), allowLossyConversion: allowLossyConversion)
  }

  func lastPathComponent(deletePathExtension: Bool = false) -> Self {
    let url = URL(fileURLWithPath: self)
    return (deletePathExtension ? url.deletingPathExtension() : url).lastPathComponent
  }
}

extension String.Encoding {
  init(from: CFStringEncodings) {
    let encoding = CFStringEncoding(from.rawValue)
    self.init(rawValue: CFStringConvertEncodingToNSStringEncoding(encoding))
  }
}
