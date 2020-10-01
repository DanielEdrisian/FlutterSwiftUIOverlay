import SwiftUI

/// The SwiftUI view that appears as an overlay to our Flutter view.
/// Given iOS 13 availability.
struct OverlaySwiftUIView: View {
  @available(iOS 13.0.0, *)
  var body: some View {
    Text("Hello World")
  }
}
