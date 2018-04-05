//
//  UIViewAttributesPreview.swift
//  MMResizableView
//
//  Created by Marc Matta on 4/5/18.
//  Copyright © 2018 Marc Matta. All rights reserved.
//

import UIKit

extension CGFloat {
    var rounded : String {
        let divisor = pow(10.0, Double(2))
        return "\((Double(self) * divisor).rounded() / divisor)"
    }
}

extension CGPoint {
    var prettyDescription: String {
        return "\(self.x.rounded), \(self.y.rounded)"
    }
}

extension CGSize {
    var prettyDescription: String {
        return "\(self.width.rounded), \(self.height.rounded)"
    }
}

extension CGRect {
    var prettyDescription : String {
        return "\(self.origin.prettyDescription), \(self.size.prettyDescription)"
    }
}

class UIViewAttributesPreview: UIView {
    @IBOutlet weak var labelBounds: UILabel!
    @IBOutlet weak var labelFrame: UILabel!
    @IBOutlet weak var labelCenter: UILabel!
    @IBOutlet weak var labelAnchor: UILabel!
    
    @IBOutlet weak var watchedView: UIView? {
        didSet {
            watchedView?.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
            watchedView?.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.new, context: nil)
            watchedView?.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.new, context: nil)
            watchedView?.addObserver(self, forKeyPath: "layer.anchorPoint", options: NSKeyValueObservingOptions.new, context: nil)
            
            self.labelBounds.text = self.watchedView!.bounds.prettyDescription
            self.labelFrame.text = self.watchedView!.frame.prettyDescription
            self.labelCenter.text = self.watchedView!.center.prettyDescription
            self.labelAnchor.text = self.watchedView!.layer.anchorPoint.prettyDescription
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        self.labelBounds.text = self.watchedView!.bounds.prettyDescription
        self.labelFrame.text = self.watchedView!.frame.prettyDescription
        self.labelCenter.text = self.watchedView!.center.prettyDescription
        self.labelAnchor.text = self.watchedView!.layer.anchorPoint.prettyDescription
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
