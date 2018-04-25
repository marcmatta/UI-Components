//
//  ViewController.swift
//  SnapView
//
//  Created by marc matta on 4/24/18.
//  Copyright © 2018 marx. All rights reserved.
//

import UIKit
extension UIColor {
    static var random: UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
class TextContentView: SnappableView<TextElement>, UITextFieldDelegate {    
    lazy var textField : UITextField! = {
        let textField = UITextField(frame: self.bounds.insetBy(dx: 1, dy: 0))
        textField.isUserInteractionEnabled = false
        textField.tintColor = UIColor.green
        return textField
    }()
    
    override init(item: TextElement) {
        super.init(item: item)
        self.addSubview(textField)
        self.backgroundColor = UIColor.random
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool) {
        if self.isSelected && selected {
            textField.isUserInteractionEnabled = true
            textField.becomeFirstResponder()
        }else {
            textField.isUserInteractionEnabled = false
        }
        super.setSelected(selected: selected)
    }
}

class TextElement : SnappableItem {
    var identifier: String = UUID().uuidString
    
    var x: CGFloat = 10
    
    var y: CGFloat = 10
    
    var width: CGFloat = 100
    
    var height: CGFloat = 30
    
    var contentView: UIView {
        get {
            return TextContentView(item: self)
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var snapView: SnapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snapView.items = [TextElement(), TextElement()]
    }

    @IBAction func rotate(sender: UIButton) {
        if let rotation = self.snapView.viewRotation() {
            self.snapView.rotate(degrees: rotation == 0 ? 90:0)
        }
    }

}

