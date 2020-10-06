import SwiftUI


/// The initial `UIViewController` defined in `Main.storyboard` uses this class.
/// It is overlayed on top of the Flutter controls that are defined in `../lib`
/// It will relay touch events to Flutter, so that the same touch event will reproduce
/// with both Flutter and Swift.
@available(iOS 14.0, *)
class OverlayFlutterViewController: FlutterViewController, FlutterStreamHandler, ObservableObject {
  
  @Published var controlName: String = "CupertinoButton"
  
  var overlayView: OverlayView!
  
  var slidersStackView: UIStackView = UIStackView()
  
  var xSlider = UISlider()
  var ySlider = UISlider()
  var alphaSlider = UISlider()
  var xLabel: UILabel!
  var yLabel: UILabel!
  var alphaLabel: UILabel!
  
  var originalOverlayCenter: CGPoint = .zero
  
  var dropDownButton = UIButton()
  
  lazy var eventChannel: FlutterEventChannel = setEventChannel()
  var eventSink: FlutterEventSink?
  
  func setEventChannel() -> FlutterEventChannel {
    FlutterEventChannel(name: "overlay_ios.flutter.io/responder", binaryMessenger: self as! FlutterBinaryMessenger)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    overlayView = OverlayView(controller: self)
    xSlider.minimumValue = -200
    xSlider.maximumValue = 200
    xSlider.isContinuous = true
    xSlider.addTarget(self, action: #selector(xSliderChanged), for: .valueChanged)
    
    ySlider.minimumValue = -200
    ySlider.maximumValue = 200
    ySlider.isContinuous = true
    ySlider.addTarget(self, action: #selector(ySliderChanged), for: .valueChanged)
    
    alphaSlider.minimumValue = 0
    alphaSlider.maximumValue = 1
    alphaSlider.value = 1
    alphaSlider.isContinuous = true
    alphaSlider.addTarget(self, action: #selector(alphaSliderChanged), for: .valueChanged)
    
    
    slidersStackView = UIStackView(arrangedSubviews: [xSlider, ySlider, alphaSlider])
    slidersStackView.axis = .vertical
    slidersStackView.distribution = .equalSpacing
    slidersStackView.center = self.view.center
    slidersStackView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
    slidersStackView.isLayoutMarginsRelativeArrangement = true
    slidersStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
    slidersStackView.spacing = UIStackView.spacingUseSystem
    
    DispatchQueue.main.async {
      self.eventChannel.setStreamHandler(self)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
  }
  
  var controlNames = ["CupertinoButton": "Cupertino button", "CupertinoTextField": "Cupertino TextField"]
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.view.addSubview(overlayView)
    overlayView.layoutView(controller: self)
    originalOverlayCenter = overlayView.center
    
    self.view.addSubview(slidersStackView)
    let stackViewHeight: CGFloat = 150.0
    slidersStackView.frame = CGRect(x: 0, y: self.view.bounds.height - stackViewHeight - 25, width: self.view.bounds.width, height: stackViewHeight)
    
    dropDownButton = UIButton(frame: CGRect(x: 13, y: 50, width: 300, height: 40))
    dropDownButton.setTitle("Select Control", for: .normal)
    dropDownButton.setTitleColor(.systemBlue, for: .normal)
    dropDownButton.contentHorizontalAlignment = .left
    dropDownButton.showsMenuAsPrimaryAction = true
    dropDownButton.menu = UIMenu(title: "Controls", image: nil, identifier: nil, options: .displayInline, children: controlNames.map({ (arg0) -> UIAction in
      let (key, value) = arg0
      
      return UIAction(title: value, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { (action) in
        self.eventSink?(key)
        self.dropDownButton.setTitle(value, for: .normal)
        self.controlName = key
      }
    }))
    self.view.addSubview(dropDownButton)
  }
  
  @objc func xSliderChanged() {
    overlayView.center.x = originalOverlayCenter.x + CGFloat(xSlider.value)
  }
  
  @objc func ySliderChanged() {
    overlayView.center.y = originalOverlayCenter.y + CGFloat(ySlider.value)
  }
  
  @objc func alphaSliderChanged() {
    overlayView.alpha = CGFloat(alphaSlider.value)
  }
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}
