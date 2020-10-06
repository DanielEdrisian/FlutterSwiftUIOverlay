import SwiftUI

/// The SwiftUI view that appears as an overlay to our Flutter view.
/// Given iOS 13 availability.
@available(iOS 14.0, *)
struct OverlaySwiftUIView: View {
  
  @ObservedObject var controller: OverlayFlutterViewController
  
  @State var text: String = ""
  
  var body: some View {
    switch controller.controlName {
      case "CupertinoButton":
        AnyView(Button("Button", action: { }))
      case "CupertinoTextField":
        AnyView(TextField("Placeholder", text: $text)
                  .textFieldStyle(RoundedBorderTextFieldStyle()))
      default:
        AnyView(Text("Incorrect Key"))
    }
  }
}
