//
//  NSImage+Extension.swift
//  IntentifyKit
//
//  Created by cyan on 10/12/25.
//

import AppKit

public extension NSImage {
  var pngData: Data? {
    guard let tiffData = tiffRepresentation else {
      return nil
    }

    guard let bitmapRep = NSBitmapImageRep(data: tiffData) else {
      return nil
    }

    return bitmapRep.representation(using: .png, properties: [:])
  }

  static func with(
    symbolName: String,
    color: NSColor = .controlAccentColor,
    size: Double = 64,
    padding: Double = 6,
    cornerRadius: Double? = 10
  ) -> NSImage? {
    let baseSymbol = NSImage(
      systemSymbolName: symbolName,
      accessibilityDescription: nil
    )

    let configuration = NSImage.SymbolConfiguration()
      .applying(.init(paletteColors: [color]))
      .applying(.init(pointSize: size, weight: .regular))

    guard let adjustedSymbol = baseSymbol?.withSymbolConfiguration(configuration) else {
      return baseSymbol
    }

    let totalSize = CGSize(
      width: size + padding * 2,
      height: size + padding * 2
    )

    guard let bitmapRep = NSBitmapImageRep(size: totalSize) else {
      return baseSymbol
    }

    let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let backgroundColor = color.withAlphaComponent(0.1)
    let backgroundPath = NSBezierPath(
      roundedRect: CGRect(origin: .zero, size: totalSize),
      xRadius: cornerRadius ?? 0,
      yRadius: cornerRadius ?? 0
    )

    backgroundColor.setFill()
    backgroundPath.fill()

    let symbolScale = min(size / adjustedSymbol.size.width, size / adjustedSymbol.size.height)
    let scaledWidth = adjustedSymbol.size.width * symbolScale
    let scaledHeight = adjustedSymbol.size.height * symbolScale

    let symbolRect = CGRect(
      x: (totalSize.width - scaledWidth) * 0.5,
      y: (totalSize.height - scaledHeight) * 0.5,
      width: scaledWidth,
      height: scaledHeight
    )

    adjustedSymbol.draw(
      in: symbolRect,
      from: .zero,
      operation: .sourceOver,
      fraction: 1
    )

    let image = NSImage(size: totalSize)
    image.addRepresentation(bitmapRep)

    NSGraphicsContext.restoreGraphicsState()
    return image
  }

  static func base64Data(with encoded: String) -> Data? {
    guard Self(systemSymbolName: encoded, accessibilityDescription: nil) == nil else {
      return nil
    }

    return Data(base64Encoded: encoded, options: .ignoreUnknownCharacters)
  }
}

// MARK: - Private

private extension NSBitmapImageRep {
  convenience init?(size: CGSize, scale: Double = NSScreen.preferredScale) {
    self.init(
      bitmapDataPlanes: nil,
      pixelsWide: Int(size.width * scale),
      pixelsHigh: Int(size.height * scale),
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: .deviceRGB,
      bytesPerRow: 0,
      bitsPerPixel: 0
    )

    self.size = size
  }
}

private extension NSScreen {
  /// Preferred rendering scale based on all screens.
  static var preferredScale: Double {
    max(2.0, screens.map(\.backingScaleFactor).max() ?? 2.0)
  }
}
