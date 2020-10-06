import SwiftUI

/// The overlay which renders a SwiftUI view, given its availability in iOS 13
/// The background is a low opacity white, so that it sets a boundary between Flutter and Swift.
@available(iOS 14.0, *)
class OverlayView: UIView {
  var controller: OverlayFlutterViewController
  var SUIController: UIViewController = UIViewController()
  
  init(controller: OverlayFlutterViewController) {
    self.controller = controller
    super.init(frame: .zero)
    
    //    self.addGestureRecognizer(PassiveGestureRecognizer(eventForwardingTarget: controller.view, controller: controller))
  }
  
  func layoutView(controller: OverlayFlutterViewController) {
    self.frame = controller.view.bounds
//    self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    
    SUIController = UIHostingController(rootView: OverlaySwiftUIView(controller: controller))
    controller.addChild(SUIController)
    SUIController.view.frame = controller.view.bounds
    SUIController.didMove(toParent: controller)
    self.addSubview(SUIController.view)
    SUIController.removeFromParent()
    controller.view.addSubview(SUIController.view)
    SUIController.view.backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    controller = coder.decodeObject(forKey: "controller") as! OverlayFlutterViewController
    super.init(coder: coder)
  }
  
  override var center: CGPoint {
    didSet {
      SUIController.view.center = self.center
    }
  }
  
  override var alpha: CGFloat {
    didSet {
      SUIController.view.alpha = self.alpha
    }
  }
}
