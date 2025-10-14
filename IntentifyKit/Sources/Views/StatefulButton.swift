//
//  StatefulButton.swift
//  IntentifyKit
//
//  Created by cyan on 10/13/25.
//

import SwiftUI

public struct StatefulButton: View {
  enum Indicator {
    case loading
    case checkmark
  }

  @State private var indicator: Indicator?
  private let title: LocalizedStringKey
  private let delay: TimeInterval
  private let action: () -> Void

  public init(
    _ title: LocalizedStringKey,
    delay: TimeInterval = 1.0,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.action = action
    self.delay = delay
  }

  public var body: some View {
    Button {
      guard indicator != .loading else {
        return
      }

      withAnimation(.bouncy) {
        indicator = .loading
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation {
          indicator = .checkmark
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          withAnimation(.bouncy) {
            indicator = .none
          }
        }
      }

      action()
    } label: {
      HStack(spacing: 5) {
        Text(title)

        if indicator == .loading {
          ProgressView().controlSize(.small)
        }

        if indicator == .checkmark {
          Image(systemName: "checkmark")
            .bold()
            .foregroundStyle(.green)
            .transition(.scale.combined(with: .opacity))
        }
      }
    }
    .buttonStyle(.glass)
  }
}
