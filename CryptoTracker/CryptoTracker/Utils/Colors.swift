// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated mark
#if os(iOS) || os(tvOS) || os(watchOS) || os(macOS)
  @available(*, deprecated, message: "Use AssetCatalogProtocols with AssetCatalogInitializer instead.")
  public typealias AssetImageTypeAlias = UIImage
  @available(*, deprecated, message: "Use AssetCatalogProtocols with AssetCatalogInitializer instead.")
  public typealias AssetColorTypeAlias = UIColor
#endif

// MARK: - Asset Catalogs

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Colors

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
@available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *)
internal enum ColorAsset {
  internal static let accentColor = SwiftGenColor(asset: "AccentColor")
}

#if os(iOS) || os(macOS) || os(tvOS)
@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension SwiftGenColor {
  @internal
  convenience init?(asset: String) {
    let bundle = Bundle.main
    #if os(iOS) || os(tvOS)
    self.init(named: asset, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset), bundle: bundle)
    #endif
  }
}
#endif
#endif

// MARK: - Images

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
@available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *)
internal enum ImageAsset {
  internal static let accentColor = SwiftGenImage(asset: "AccentColor")
}

#if os(iOS) || os(tvOS) || os(watchOS)
@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SwiftGenImage {
  @internal
  convenience init?(asset: String) {
    let bundle = Bundle.main
    self.init(named: asset, in: bundle, compatibleWith: nil)
  }
}
#elseif os(macOS)
@available(macOS 10.13, *)
extension SwiftGenImage {
  @internal
  convenience init?(asset: String) {
    let bundle = Bundle.main
    self.init(named: NSImage.Name(asset), bundle: bundle, key: nil)
  }
}
#endif
#endif

// MARK: - Implementation Details

#if os(iOS) || os(tvOS) || os(watchOS)
#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  init(_ color: ColorAsset) {
    self.init(color.swiftUIColor)
  }
}
#endif
#endif

#if os(macOS)
#if canImport(SwiftUI)
@available(macOS 10.15, *)
extension SwiftUI.Color {
  @available(macOS 10.15, *)
  init(_ color: ColorAsset) {
    self.init(color.swiftUIColor)
  }
}
#endif
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  init(_ image: ImageAsset) {
    self.init(image.swiftUIImage)
  }
}
#endif
