
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

