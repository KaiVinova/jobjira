//
//  Extensions.swift
//  GameMaster
//
//  Created by Akshay Rai on 04/02/16.
//  Copyright © 2016 AppInfy. All rights reserved.
//
//
import Foundation


import Foundation

//MARK: Stiring Extension
extension String{
    
    var length: Int{
        return self.characters.count
    }
    var localizedString: String{
        return NSLocalizedString(self, comment: "")
    }
    
    func stringByRemovingLeadingTrailingWhitespaces() -> String {
        let spaceSet = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: spaceSet)
    }
    
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: NSCharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    //Validate Email
    var isEmail: Bool {
        do {
//            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", options: .caseInsensitive)            
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let charcter  = NSCharacterSet(charactersIn: "+0123456789").inverted
        var filtered:String!
        let inputString:[String] = self.components(separatedBy: charcter)
        filtered = inputString.joined(separator: "") as String!
        return  self == filtered
        
    }
    
    var utf8Data: NSData? {
        return data(using: String.Encoding.utf8) as NSData?
    }
    
    
}

//MARK: UserDefault Extension
extension UserDefaults {
    
    class func save(value:AnyObject,forKey key:String)
    {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func getStringDataFromUserDefault(key:String) -> String?
    {
        if let value = UserDefaults.standard.object(forKey: key) as? String {
            return value
        }
        return nil
    }
    class func getAnyDataFromUserDefault(key:String) -> AnyObject?
    {
        if let value: AnyObject = UserDefaults.standard.object(forKey: key) as AnyObject? {
            
            return value
        }
        return nil
    }
    class func removeFromUserDefaultForKey(key:String)
    {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func clean()
    {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
}



extension UIAlertController{
    class func showMessage(parent: UIViewController, messageText: String, messageTitle: String, buttonText: String) {
        let alert = UIAlertController(title: messageTitle, message: messageText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
        parent.present(alert, animated: true, completion: nil)
    }
}

extension NSError{
    
    class func networkConnectionError(urlString: String) -> NSError{
        let errorUserInfo =
        [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
            NSURLErrorFailingURLErrorKey : "\(urlString)"
        ]
        return NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
    }
    
    class func jsonParsingError(urlString: String) -> NSError{
        let errorUserInfo =
        [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
            NSURLErrorFailingURLErrorKey : "\(urlString)"
        ]
        return NSError(domain: NSCocoaErrorDomain, code: PARSING_ERROR_CODE, userInfo:errorUserInfo)
    }
    
    class func notFoundError(urlString: String) -> NSError{
        let errorUserInfo =
            [   NSLocalizedDescriptionKey : "URL not found",
                NSURLErrorFailingURLErrorKey : "\(urlString)"
        ]
        return NSError(domain: NSCocoaErrorDomain, code: NOT_FOUND_ERROR_CODE, userInfo:errorUserInfo)
    }
}

class CircularImageV: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

extension UIButton{
    
    func makeBlurImage(targetButton:UIButton?)
    {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.light))
        blur.frame = targetButton!.bounds
        blur.isUserInteractionEnabled = false //This allows touches to forward to the 
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetButton!.insertSubview(blur, at: 0)
    }
    
    func roundButtonCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addDashedBorder(color:CGColor) {
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [10,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
    
    func makeBlurView(targetView:UIView?)
    {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.light))
        blur.frame = targetView!.bounds
        blur.isUserInteractionEnabled = false //This allows touches to forward to the
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetView!.insertSubview(blur, at: 0)
    }
    
    func addBlurArea(area: CGRect, targetView:UIView?) {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = CGRect(x: 0, y: 0, width: area.width, height: area.height)
        blurView.isUserInteractionEnabled = false //This allows touches to forward to the
        let container = UIView(frame: area)
        container.alpha = 0.7
        container.addSubview(blurView)
        
        targetView!.insertSubview(container, at: 0)
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}

extension NSData {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self as Data, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
extension Array where Element: Hashable {
    var setValue: Set<Element> {
        return Set<Element>(self)
    }
}

extension Array {
    func contain<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension String{
    func breakStringIntoArray() -> [String] {
        return self.components(separatedBy: "/")
    }
    
    func timeStampToDateString(_ timeStamp:Int, format:String) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date as Date)
    }
    
    
}

extension UIImageView{
    func setImageWithString(_ string: String?) {
        
        if let string = string, let url = NSURL(string: string) {
            
            let activityIndicatorView = UIActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            activityIndicatorView.isHidden = false
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.color = UIColor.white
            activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
            addSubview(activityIndicatorView)
            bringSubview(toFront: activityIndicatorView)
            
            activityIndicatorView.startAnimating()
            
            setImageWith(NSURLRequest(url: url as URL) as URLRequest, placeholderImage: nil, success: { request, response, image in
                
                self.image = image
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
            }, failure: { request, response, error in
                
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
            })
        }
    }
}

class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
