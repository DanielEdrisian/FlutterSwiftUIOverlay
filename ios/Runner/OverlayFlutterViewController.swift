import SwiftUI


/// The SwiftUI view that appears as an overlay to our Flutter view.
/// Given iOS 13 availability.
struct OverlaySwiftUIView: View {
  @available(iOS 13.0.0, *)
  var body: some View {
    Text("Hello World")
  }
}


/// The initial `UIViewController` defined in `Main.storyboard` uses this class.
/// It is overlayed on top of the Flutter controls that are defined in `../lib`
/// It will relay touch events to Flutter, so that the same touch event will reproduce
/// with both Flutter and Swift.
class OverlayFlutterViewController: FlutterViewController {
  
  var overlayView: OverlayView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    overlayView = OverlayView(controller: self)
    self.view.addSubview(overlayView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    overlayView.layoutView(controller: self)
  }
}

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

/// Gesture recognizer that does two things:
/// 1. Route touch events to the `OverlayFlutterViewController`
/// 2. Route touch events to a `FlutterEventChannel` that is being listened to in `overlay_ios.flutter.io/responder`

class PassiveGestureRecognizer: UIGestureRecognizer, FlutterStreamHandler, UIGestureRecognizerDelegate {
  var eventForwardingTarget: UIResponder
  var controller: FlutterViewController
  var eventChannel: FlutterEventChannel
  var eventSink: FlutterEventSink?

  init(eventForwardingTarget: UIResponder, controller: FlutterViewController) {
    self.eventForwardingTarget = eventForwardingTarget
    self.controller = controller
    self.eventChannel = FlutterEventChannel(name: "overlay_ios.flutter.io/responder", binaryMessenger: self.controller as! FlutterBinaryMessenger)
    super.init(target: nil, action: nil)
    
    self.delegate = self
    
    DispatchQueue.main.async {
      self.eventChannel.setStreamHandler(self)
    }
  }
  
  func sinkTouchLocations(touches: Set<UITouch>) {
    for t in touches {
      eventSink?(t.location(in: controller.view))
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    eventForwardingTarget.touchesBegan(touches, with: event)
    sinkTouchLocations(touches: touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    eventForwardingTarget.touchesMoved(touches, with: event)
    sinkTouchLocations(touches: touches)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    eventForwardingTarget.touchesEnded(touches, with: event)
    sinkTouchLocations(touches: touches)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    eventForwardingTarget.touchesCancelled(touches, with: event)
    sinkTouchLocations(touches: touches)
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    true
  }
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}

