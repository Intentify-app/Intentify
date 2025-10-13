//
//  StableInset.swift
//  IntentifyKit
//
//  Created by cyan on 10/13/25.
//

import SwiftUI

public struct StableInset: View {
  private let length: Double

  public init(length: Double = 10) {
    self.length = length
  }

  public var body: some View {
    VStack {}.frame(width: length, height: length)
  }
}
