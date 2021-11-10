////
////  UIView+Extension.swift
////
//
//import Foundation
//import UIKit
//
//extension NSObject {
//    
//    class var nameOfClass: String {
//        return NSStringFromClass(self).components(separatedBy: ".").last! as String
//    }
//}
//
//extension UIView {
//    
////    @IBInspectable var cornerRadius: CGFloat {
////        get {
////            return layer.cornerRadius
////        }
////        set {
////            layer.cornerRadius = newValue
////            layer.masksToBounds = newValue > 0
////        }
////    }
//    
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//    
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
//    }
//    
//    class func NibObject() -> UINib {
//        let hasNib: Bool = Bundle.main.path(forResource: self.nameOfClass, ofType: "nib") != nil
//        guard hasNib else {
//            assert(!hasNib, "Invalid parameter") // assert
//            return UINib()
//        }
//        return UINib(nibName: self.nameOfClass, bundle:nil)
//    }
//    
//    
//    class func fromNib<T : UIView>(nibNameOrNil: String? = nil) -> T {
//        let v: T? = fromNib(nibNameOrNil: nibNameOrNil)
//        return v!
//    }
//    
//    class func fromNib<T : UIView>(nibNameOrNil: String? = nil) -> T? {
//        var view: T?
//        let name: String
//        if let nibName = nibNameOrNil {
//            name = nibName
//        } else {
//            // Most nibs are demangled by practice, if not, just declare string explicitly
//            name = "\(T.self)".components(separatedBy: ".").last!
//        }
//        let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
//        for v in nibViews! {
//            if let tog = v as? T {
//                view = tog
//            }
//        }
//        return view
//    }
//
//    // MARK: Frame of UIView - do not touch
//    var width: CGFloat {
//        get { return self.frame.size.width }
//        set {
//            var frame = self.frame
//            frame.size.width = newValue
//            self.frame = frame
//        }
//    }
//    
//    var height: CGFloat {
//        get { return self.frame.size.height }
//        set {
//            var frame = self.frame
//            frame.size.height = newValue
//            self.frame = frame
//        }
//    }
//    
//    var size: CGSize  {
//        get { return self.frame.size }
//        set {
//            var frame = self.frame
//            frame.size = newValue
//            self.frame = frame
//        }
//    }
//    
//    var origin: CGPoint {
//        get { return self.frame.origin }
//        set {
//            var frame = self.frame
//            frame.origin = newValue
//            self.frame = frame
//        }
//    }
//    
//    var x: CGFloat {
//        get { return self.frame.origin.x }
//        set {
//            var frame = self.frame
//            frame.origin.x = newValue
//            self.frame = frame
//        }
//    }
//    
//    var y: CGFloat {
//        get { return self.frame.origin.y }
//        set {
//            var frame = self.frame
//            frame.origin.y = newValue
//            self.frame = frame
//        }
//    }
//    
//    var centerX: CGFloat {
//        get { return self.center.x }
//        set {
//            self.center = CGPoint(x: newValue, y: self.centerY)
//        }
//    }
//    
//    var centerY: CGFloat {
//        get { return self.center.y }
//        set {
//            self.center = CGPoint(x: self.centerX, y: newValue)
//        }
//    }
//    
//    var top : CGFloat {
//        get { return self.frame.origin.y }
//        set {
//            var frame = self.frame
//            frame.origin.y = newValue
//            self.frame = frame
//        }
//    }
//    
//    var bottom : CGFloat {
//        get { return frame.origin.y + frame.size.height }
//        set {
//            var frame = self.frame
//            frame.origin.y = newValue - self.frame.size.height
//            self.frame = frame
//        }
//    }
//    
//    var right : CGFloat {
//        get { return self.frame.origin.x + self.frame.size.width }
//        set {
//            var frame = self.frame
//            frame.origin.x = newValue - self.frame.size.width
//            self.frame = frame
//        }
//    }
//    
//    var left : CGFloat {
//        get { return self.frame.origin.x }
//        set {
//            var frame = self.frame
//            frame.origin.x  = newValue
//            self.frame = frame
//        }
//    }
//    
//    var parentViewController: UIViewController? {
//               var parentResponder: UIResponder? = self
//               while parentResponder != nil {
//                   parentResponder = parentResponder!.next
//                   if let viewController = parentResponder as? UIViewController {
//                       return viewController
//                   }
//               }
//               return nil
//           }
//    
//    func origin (_ point : CGPoint) {
//        frame.origin.x = point.x
//        frame.origin.y = point.y
//    }
//    
//    func bindToKeyboard() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(UIView.keyboardWillChange(notification:)),
//            name: UIResponder.keyboardWillChangeFrameNotification,
//            object: nil
//        )
//    }
//    
//    func unbindToKeyboard() {
//        NotificationCenter.default.removeObserver(
//            self,
//            name: UIResponder.keyboardWillChangeFrameNotification,
//            object: nil
//        )
//    }
//    
//    @objc func keyboardWillChange(notification: Notification) {
//        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
//        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
//        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let deltaY = targetFrame.origin.y - curFrame.origin.y
//        
//        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
//            self.frame.origin.y += deltaY
//        })
//    }
//    
////    @IBInspectable var shadowColor: UIColor?{
////        set {
////            guard let uiColor = newValue else { return }
////            layer.shadowColor = uiColor.cgColor
////        }
////        get{
////            guard let color = layer.shadowColor else { return nil }
////            return UIColor(cgColor: color)
////        }
////    }
//    
//    @IBInspectable var shadowOpacity: Float{
//        set { layer.shadowOpacity = newValue }
//        get{ return layer.shadowOpacity }
//    }
//    
////    @IBInspectable var shadowOffset: CGSize{
////        set { layer.shadowOffset = newValue }
////        get { return layer.shadowOffset }
////    }
//    
//    @IBInspectable var shadowRadius: CGFloat{
//        set { layer.shadowRadius = newValue }
//        get{ return layer.shadowRadius }
//    }
//    
//    //set selected corner only
//    //ex : ui_viewTxt.roundCornersWithLayerMask(cornerRadius: 10, corners: [.topRight, .bottomLeft, .bottomRight])
//    func roundCornersWithLayerMask(cornerRadius: CGFloat, corners: UIRectCorner) {
//        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        layer.mask = maskLayer
//    }
//    
//    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
//        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
//            constraint.constant = gone ? 0.0 : dimension
//            self.layoutIfNeeded()
//            self.isHidden = gone
//        }
//    }
//    
//    // OUTPUT 1
//    func dropShadow(scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
//        layer.shadowOffset = CGSize(width: -1, height: 1)
//        layer.shadowRadius = 1
//        
//        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//    
//    // OUTPUT 2
//    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = color.cgColor
//        layer.shadowOpacity = opacity
//        layer.shadowOffset = offSet
//        layer.shadowRadius = radius
//        
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//    
//    // MARK: - Customized UIView Shadow
//    func dropShadow(cornerRadius: CGFloat) {
//        
//        self.layer.cornerRadius = cornerRadius
//        
//        self.layer.shadowColor = UIColor.darkGray.cgColor
//        self.layer.shadowOpacity = 1
//        
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
//        self.layer.shadowRadius = 3
//        
//        self.layer.masksToBounds = false
//        self.layer.shouldRasterize = true
//    }
//    
//    func roundShadow(cornerRadius: CGFloat) {
//        
//        self.layer.cornerRadius = cornerRadius
//        
//        self.layer.shadowColor = UIColor.darkGray.cgColor
//        
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = 3
//        self.layer.shadowOffset = .zero
//        self.layer.shouldRasterize = true
//    }
//    
//    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
//    
//    func addTapGesture(tapNumber: Int, target: Any, action: Selector) {
//        let tap = UITapGestureRecognizer(target: target, action: action)
//        tap.numberOfTapsRequired = tapNumber
//        addGestureRecognizer(tap)
//        isUserInteractionEnabled = true
//    }
//    
//    func lock() {
//        if let _ = viewWithTag(10) {
//            //View is already locked
//        }
//        else {
//            let lockView = UIView(frame: bounds)
//            lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
//            lockView.tag = 10
//            lockView.alpha = 0.0
//            let activity = UIActivityIndicatorView(style: .white)
//            activity.hidesWhenStopped = true
//            activity.center = lockView.center
//            lockView.addSubview(activity)
//            activity.startAnimating()
//            addSubview(lockView)
//            
//            UIView.animate(withDuration: 0.2, animations: {
//                lockView.alpha = 1.0
//            })
//        }
//    }
//    
//    func unlock() {
//        if let lockView = viewWithTag(10) {
//            UIView.animate(withDuration: 0.2, animations: {
//                lockView.alpha = 0.0
//            }, completion: { finished in
//                lockView.removeFromSuperview()
//            })
//        }
//    }
//    
//    func fadeOut(_ duration: TimeInterval) {
//        UIView.animate(withDuration: duration, animations: {
//            self.alpha = 0.0
//        })
//    }
//    
//    func fadeIn(_ duration: TimeInterval) {
//        UIView.animate(withDuration: duration, animations: {
//            self.alpha = 1.0
//        })
//    }
//    
//}
//
//class dropShadowView: UIView {
//    override func didMoveToWindow() {
//        
//        self.layer.cornerRadius = 8
//        
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOpacity = 1.0
//        
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
//        self.layer.shadowRadius = 3
//        
//        self.layer.masksToBounds = false
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
//
//class roundShadowView: UIView {
//    override func didMoveToWindow() {
//        self.layer.cornerRadius = self.height / 2
//        
//        self.layer.shadowColor = UIColor.darkGray.cgColor
//        
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = 3
//        self.layer.shadowOffset = .zero
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//        
//    }
//}
//
//
//class topShadowView: UIView {
//    override func didMoveToWindow() {
//        
//        self.layer.shadowColor = UIColor.gray.cgColor
//        
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = 3
//        self.layer.shadowOffset = .zero
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
//
//class roundView: UIView {
//    override func didMoveToWindow() {
//        
//        self.layer.cornerRadius = self.frame.size.height / 2
//        self.layer.masksToBounds = true
//    }
//}
//
////by me update
//// MARK: - round UIView with drop-down shadow effect
//class dropRoundShadowView: UIView {
//    override func didMoveToWindow() {
//        
//        self.layer.cornerRadius = self.height / 2
//        
//        self.layer.shadowColor = UIColor.darkGray.cgColor
//        self.layer.shadowOpacity = 1
//        
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
//        self.layer.shadowRadius = 3
//        
//        self.layer.masksToBounds = false
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
//
//class dropShadowGrayView: UIView {
//    
//    override func didMoveToWindow() {
//        
//        self.layer.cornerRadius = self.height / 2
//        
//        self.layer.shadowColor = UIColor.gray.cgColor
//        self.layer.shadowRadius = 3
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSize(width: 0, height: 5)
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
//
//extension UIView {
//
//var heightConstaint: NSLayoutConstraint? {
//    get {
//        return constraints.first(where: {
//            $0.firstAttribute == .height && $0.relation == .equal
//        })
//    }
//    set { setNeedsLayout() }
//}
//
//var widthConstaint: NSLayoutConstraint? {
//    get {
//        return constraints.first(where: {
//            $0.firstAttribute == .width && $0.relation == .equal
//        })
//    }
//    set { setNeedsLayout() }
//}
//
//}
//
//@IBDesignable
//class RoundedCornerView: UIView {
//
//    var cornerRadiusValue : CGFloat = 0
//    var corners : UIRectCorner = []
//    
//    @IBInspectable public var topLeft : Bool {
//        get {
//            return corners.contains(.topLeft)
//        }
//        set {
//            setCorner(newValue: newValue, for: .topLeft)
//        }
//    }
//    
//    @IBInspectable public var topRight : Bool {
//        get {
//            return corners.contains(.topRight)
//        }
//        set {
//            setCorner(newValue: newValue, for: .topRight)
//        }
//    }
//    
//    @IBInspectable public var bottomLeft : Bool {
//        get {
//            return corners.contains(.bottomLeft)
//        }
//        set {
//            setCorner(newValue: newValue, for: .bottomLeft)
//        }
//    }
//    
//    @IBInspectable public var bottomRight : Bool {
//        get {
//            return corners.contains(.bottomRight)
//        }
//        set {
//            setCorner(newValue: newValue, for: .bottomRight)
//        }
//    }
//    
//    func setCorner(newValue: Bool, for corner: UIRectCorner) {
//        if newValue {
//            addRectCorner(corner: corner)
//        } else {
//            removeRectCorner(corner: corner)
//        }
//    }
//    
//    func addRectCorner(corner: UIRectCorner) {
//        corners.insert(corner)
//        updateCorners()
//    }
//    
//    func removeRectCorner(corner: UIRectCorner) {
//        if corners.contains(corner) {
//            corners.remove(corner)
//            updateCorners()
//        }
//    }
//    
//    func updateCorners() {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadiusValue, height: cornerRadiusValue))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
//
//}
//
//extension UIView {
//    
//    enum Visibility {
//        case visible
//        case invisible
//        case gone
//    }
//    
//    var visibility: Visibility {
//        get {
//            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
//            if let constraint = constraint, constraint.isActive {
//                return .gone
//            } else {
//                return self.isHidden ? .invisible : .visible
//            }
//        }
//        set {
//            if self.visibility != newValue {
//                self.setVisibility(newValue)
//            }
//        }
//    }
//    
//    private func setVisibility(_ visibility: Visibility) {
//        let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
//        
//        switch visibility {
//        case .visible:
//            constraint?.isActive = false
//            self.isHidden = false
//            break
//        case .invisible:
//            constraint?.isActive = false
//            self.isHidden = true
//            break
//        case .gone:
//            if let constraint = constraint {
//                constraint.isActive = true
//            } else {
//                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
//                self.addConstraint(constraint)
//                constraint.isActive = true
//            }
//        }
//    }
//}
//
//extension UIView {
//    func dropShadowleft1(scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.white.cgColor
//        layer.shadowOpacity = 0.8
//        layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
//        layer.shadowRadius = 3.0
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//    
//    func ShadowCenter1(scale: Bool = true) {
//           layer.masksToBounds = false
//           layer.shadowColor = UIColor.white.cgColor
//           layer.shadowOpacity = 0.8
//           layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//           layer.shadowRadius = 3.0
//           layer.shouldRasterize = true
//           layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//       }
//    
//    func dropShadowbottom1(scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.white.cgColor
//        layer.shadowOpacity = 0.7
//        layer.shadowOffset = CGSize(width: 0.0, height:4.0)
//        layer.shadowRadius = 2.0
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//}
//
//extension UIView {
//    func setCornerRadius() {
//        self.layer.cornerRadius = 10;
//        self.layer.masksToBounds = true;
//    }
//    
//    func fadeTransition(_ duration:CFTimeInterval) {
//        
//        let animation = CATransition()
//        animation.timingFunction = CAMediaTimingFunction(name:
//            CAMediaTimingFunctionName.easeInEaseOut)
//        animation.type = CATransitionType.fade
//        animation.duration = duration
//        layer.add(animation, forKey: CATransitionType.fade.rawValue)
//    }
//    
//    func setRound() {
//        self.layer.cornerRadius = self.frame.size.width/2;
//        self.layer.masksToBounds = true;
//    }
//    
//    func setBottomShadow(){
//        self.layer.masksToBounds = false
//        self.layer.shadowColor =  UIColor.lightGray.cgColor//UIColor(white: 0x000000, alpha: 1.0).cgColor
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 0
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
//    }
//    
//    func setbtnShadowLogin(){
//        self.layer.masksToBounds = false
//        self.layer.shadowOffset = CGSize(width: 0, height: 1)
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 3.0
//        self.layer.shadowColor = self.backgroundColor?.cgColor
//    }
//    
//    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
//            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            self.layer.mask = mask
//        })
//        
//    }
//}
//
//public extension UIView {
//
//    //@discardableResult
//    /*func addBlur(style: UIBlurEffect.Style = .light) -> UIVisualEffectView {
//        let blurEffect = UIBlurEffect(style: style)
//        let blurBackground = UIVisualEffectView(effect: blurEffect)
//        addSubview(blurBackground)
//        blurBackground.alpha = 0.8
//        blurBackground.translatesAutoresizingMaskIntoConstraints = false
//        blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        blurBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        return blurBackground
//    }*/
//    func addBlurToView()  {
//        var blurEffect: UIBlurEffect
//        if #available(iOS 10.0,*){
//            blurEffect = UIBlurEffect(style: .dark)
//        }else{
//            blurEffect = UIBlurEffect(style: .light)
//        }
//        let bluredEffectView = UIVisualEffectView(effect: blurEffect)
//        bluredEffectView.frame = self.bounds
//        bluredEffectView.alpha = 0.8
//        bluredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    }
//    
//    func removeBlurFromView()  {
//        for subview in self.subviews{
//            if subview is UIVisualEffectView{
//                subview.removeFromSuperview()
//            }
//        }
//    }
//}
//
//extension UIView {
//    @discardableResult
//    func constrain(constraints: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
//        let constraints = constraints(self)
//        self.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate(constraints)
//        return constraints
//    }
//    
//    @discardableResult
//    func constrainToEdges(_ inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
//        return constrain {[
//            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
//            $0.leadingAnchor.constraint(equalTo: $0.superview!.leadingAnchor, constant: inset.left),
//            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: inset.bottom),
//            $0.trailingAnchor.constraint(equalTo: $0.superview!.trailingAnchor, constant: inset.right)
//        ]}
//    }
//}
//
//
//extension UIView {
//
//    var safeAreaBottom: CGFloat {
//         if #available(iOS 11, *) {
//            if let window = UIApplication.shared.keyWindowInConnectedScenes {
//                return window.safeAreaInsets.bottom
//            }
//         }
//         return 0
//    }
//
//    var safeAreaTop: CGFloat {
//         if #available(iOS 11, *) {
//            if let window = UIApplication.shared.keyWindowInConnectedScenes {
//                return window.safeAreaInsets.top
//            }
//         }
//         return 0
//    }
//}
//
//extension UIApplication {
//    var keyWindowInConnectedScenes: UIWindow? {
//        return windows.first(where: { $0.isKeyWindow })
//    }
//}
//
//extension UIView {
//
//    func addDashedBorder() {
//        //Create a CAShapeLayer
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor.init(named: "color_plus_title")!.cgColor
//        shapeLayer.lineWidth = 4
//        // passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment
//        shapeLayer.lineDashPattern = [4,4]
//
//        let path = CGMutablePath()
//        path.addLines(between: [CGPoint(x: 0, y: 0),
//                                CGPoint(x: self.frame.width, y: 0)])
//        shapeLayer.path = path
//        layer.addSublayer(shapeLayer)
//    }
//}
//
//extension UIView {
//    private static let lineDashPattern: [NSNumber] = [2, 2]
//    private static let lineDashWidth: CGFloat = 1.0
//
//    func makeDashedBorderLine() {
//        let path = CGMutablePath()
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.lineWidth = UIView.lineDashWidth
//        shapeLayer.strokeColor = UIColor.lightGray.cgColor
//        shapeLayer.lineDashPattern = UIView.lineDashPattern
//        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
//                                CGPoint(x: bounds.maxX, y: bounds.height/2)])
//        shapeLayer.path = path
//        layer.addSublayer(shapeLayer)
//    }
//}
//
//class RectangularDashedView: UIView {
//    override var cornerRadius: CGFloat{
//        didSet {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = cornerRadius > 0
//        }
//    }
//    var dashWidth: CGFloat = 0
//    var dashColor: UIColor = .clear
//    var dashLength: CGFloat = 0
//    var betweenDashesSpace: CGFloat = 0
//    var dashBorder: CAShapeLayer?
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        dashBorder?.removeFromSuperlayer()
//        let dashBorder = CAShapeLayer()
//        dashBorder.lineWidth = dashWidth
//        dashBorder.strokeColor = dashColor.cgColor
//        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
//        dashBorder.frame = bounds
//        dashBorder.fillColor = nil
//        if cornerRadius > 0 {
//            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//        } else {
//            dashBorder.path = UIBezierPath(rect: bounds).cgPath
//        }
//        layer.addSublayer(dashBorder)
//        self.dashBorder = dashBorder
//    }
//}
//
//
