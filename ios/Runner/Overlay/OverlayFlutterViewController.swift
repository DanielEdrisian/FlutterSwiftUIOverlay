
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
