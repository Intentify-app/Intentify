//
//  View+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/12/25.
//

import SwiftUI

public extension View {
  func borderedRect(cornerRadius: Double) -> some View {
    modifier(BorderedRectModifier(cornerRadius: cornerRadius))
  }

  func codeStyle() -> some View {
    modifier(CodeStyleModifier())
  }

  func tintedLabel() -> some View {
    modifier(TintedLabelModifier())
  }
}

// MARK: - Private

private struct BorderedRectModifier: ViewModifier {
  let cornerRadius: Double

  func body(content: Content) -> some View {
    let roundedRect = RoundedRectangle(
      cornerRadius: cornerRadius,
      style: .continuous
    )

    content
      .background(Color.gray.opacity(0.06))
      .background(
        roundedRect.stroke(Color.gray.opacity(0.5), lineWidth: 2)
      )
      .clipShape(roundedRect)
  }
}

private struct CodeStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .monospaced()
      .padding(.horizontal, 5)
      .padding(.vertical, 1.5)
      .borderedRect(cornerRadius: 4)
  }
}

private struct TintedLabelModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 5)
      .padding(.vertical, 2)
      .foregroundStyle(Color.accentColor)
      .background(Color.accentColor.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
}
