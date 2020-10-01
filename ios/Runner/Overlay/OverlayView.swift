
/// The overlay which renders a SwiftUI view, given its availability in iOS 13
/// The background is a low opacity white, so that it sets a boundary between Flutter and Swift.
class OverlayView: UIView {
  var controller: FlutterViewController
  var SUIController: UIViewController = UIViewController()
  
  init(controller: FlutterViewController) {
    self.controller = controller
    super.init(frame: .zero)

    self.addGestureRecognizer(PassiveGestureRecognizer(eventForwardingTarget: controller.view, controller: controller))
  }
  
  func layoutView(controller: FlutterViewController) {
    self.frame = controller.view.bounds
    self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    
    if #available(iOS 13.0, *) {
      SUIController = UIHostingController(rootView: OverlaySwiftUIView())
      controller.addChild(SUIController)
      SUIController.view.frame = controller.view.bounds
      controller.view.addSubview(SUIController.view)
      SUIController.didMove(toParent: controller)
      SUIController.view.backgroundColor = .clear
    }
  }
  
  required init?(coder: NSCoder) {
    controller = coder.decodeObject(forKey: "controller") as! FlutterViewController
    super.init(coder: coder)
  }
}
