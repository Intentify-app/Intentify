//
//  Color+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/13/25.
//

import SwiftUI

public extension Color {
  init(hex: Int) {
    let red = Double((hex >> 16) & 0xFF) / 255
    let green = Double((hex >> 8) & 0xFF) / 255
    let blue = Double(hex & 0xFF) / 255
    self.init(red: red, green: green, blue: blue)
  }
}
