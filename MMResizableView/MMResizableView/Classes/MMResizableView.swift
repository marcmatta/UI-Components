//
//  MMResizableView.swift
//  MMResizableView
//
//  Created by Marc Matta on 4/5/18.
//  Copyright © 2018 Marc Matta. All rights reserved.
//

import UIKit
fileprivate enum DragHandleSelection {
    case upper
    case right
    case lower
    case left
}

class MMResizableView: UIView {
    public var minHeight : CGFloat = 48.0
    public var minWidth : CGFloat = 48.0
    public var showBorders : Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderInset : CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderSizableInset : CGFloat = 10
    
    public var handleSize : CGFloat = 5 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    private var lastLocation : CGPoint!
    private var dragging: Bool {
        get  {
            return handleSelection.count == 0
        }
    }
    
    private var handleSelection : [DragHandleSelection] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = self.superview, let touch = touches.first else {
            return
        }
        
        superview.bringSubview(toFront: self)
        var locationInView = touch.location(in: superview)
        let frame = self.frame
        locationInView.x = locationInView.x - frame.origin.x
        locationInView.y = locationInView.y - frame.origin.y
        
        let topLeftHandleSelected = CGRect(x: 0, y: 0, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        let topMiddleHandleSelected = CGRect(x: self.frame.size.width / 2 - borderSizableInset / 2, y: 0, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        let topRightHandleSelected = CGRect(x: self.frame.size.width - borderSizableInset , y: 0, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        
        let middleRightHandleSelected = CGRect(x: self.frame.size.width - borderSizableInset , y: self.frame.size.height / 2 - borderSizableInset / 2, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        let bottomRightHandleSelected = CGRect(x: self.frame.size.width - borderSizableInset, y: self.frame.size.height - borderSizableInset, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        
        let bottomMiddleHandleSelected = CGRect(x: self.frame.size.width / 2 - borderSizableInset / 2 , y: self.frame.size.height - borderSizableInset , width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        let bottomLeftHandleSelected = CGRect(x: 0, y: self.frame.size.height - borderSizableInset , width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        
        let middleLeftHandleSelected = CGRect(x: 0, y: self.frame.size.height / 2 - borderSizableInset / 2, width: borderSizableInset, height: borderSizableInset).contains(locationInView)
        
        handleSelection = []
        
        if topLeftHandleSelected {
            handleSelection.append(.upper)
            handleSelection.append(.left)
        }
        
        if topMiddleHandleSelected {
            handleSelection.append(.upper)
        }
        
        if topRightHandleSelected {
            handleSelection.append(.upper)
            handleSelection.append(.right)
        }
        
        if middleRightHandleSelected {
            handleSelection.append(.right)
        }
        
        if bottomRightHandleSelected {
            handleSelection.append(.lower)
            handleSelection.append(.right)
        }
        
        if bottomMiddleHandleSelected {
            handleSelection.append(.lower)
        }
        
        if bottomLeftHandleSelected {
            handleSelection.append(.lower)
            handleSelection.append(.left)
        }
        
        if middleLeftHandleSelected {
            handleSelection.append(.left)
        }
        
        lastLocation = touch.location(in: superview)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = self.superview, let touch = touches.first else {
            return
        }
        
        let locationInSuperview = touch.location(in: superview)

        if dragging {
            moveCenter(to: locationInSuperview)
        }else {
            resize(using: locationInSuperview)
        }
        
        lastLocation = locationInSuperview
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleSelection = []
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleSelection = []
    }
    
    private func moveCenter(to newLocation: CGPoint) {
        guard let superview = self.superview else{
            return
        }
        
        let translationX = newLocation.x - lastLocation.x
        let translationY = newLocation.y - lastLocation.y
        
        var newX = self.center.x + translationX
        var newY = self.center.y + translationY
        
        let didPassRightBounds = newX + self.frame.size.width / 2 > superview.bounds.maxX
        let didPassLeftBounds = newX - self.frame.size.width / 2 < superview.bounds.minX
        if didPassLeftBounds || didPassRightBounds {
            newX = self.center.x
        }
        
        let didPassLowerBounds = newY + self.frame.size.height / 2 > superview.bounds.maxY
        let didPassUpperBounds = newY - self.frame.size.height / 2 < superview.bounds.minY
        if didPassLowerBounds || didPassUpperBounds {
            newY = self.center.y
        }
        
        self.center = CGPoint(x: newX, y: newY)
        self.setNeedsDisplay()
    }
    
    private func resize(using newLocation: CGPoint) {
        guard let superview = self.superview else {
            return
        }

        var newLocation = newLocation
//        var lockX : Bool = false
//        var lockY : Bool = false
//
//        if newLocation.x - borderInset < superview.bounds.minX {
//            newLocation.x = superview.bounds.minX + borderInset
//            lockX = true
//        }
//
//        if newLocation.y - borderInset < superview.bounds.minY {
//            newLocation.y = superview.bounds.minY + borderInset
//            lockY = true
//        }
//
//        if newLocation.x + borderInset > superview.bounds.maxX  {
//            newLocation.x = superview.bounds.maxX - borderInset
//            lockX = true
//        }
//
//        if newLocation.y + borderInset > superview.bounds.maxY{
//            newLocation.y = superview.bounds.maxY - borderInset
//            lockY = true
//        }
//
        var newX : CGFloat = self.frame.origin.x
        var newY : CGFloat = self.frame.origin.y
        var newW : CGFloat = self.frame.size.width
        var newH : CGFloat = self.frame.size.height
        
        let deltaY = newLocation.y - lastLocation.y
        let deltaX = newLocation.x - lastLocation.x
        
        if handleSelection.contains(.upper) {
            if (newH - deltaY < self.minHeight) {
                newY = self.frame.maxY - self.minHeight
                newH = self.minHeight
            }else {
                newY = self.frame.origin.y + deltaY
                newH = self.frame.size.height - deltaY
            }
            
            if newY < superview.bounds.minY {
                newY = self.frame.origin.y
                newH = self.frame.size.height
            }
        }
        
        if handleSelection.contains(.left) {
            if (newW - deltaX < self.minWidth) {
                newX = self.frame.maxX - self.minWidth
                newW = self.minWidth
            }else {
                newX = self.frame.origin.x + deltaX
                newW = self.frame.size.width - deltaX
            }
            
            if newX < superview.bounds.minX {
                newX = self.frame.origin.x
                newW = self.frame.size.width
            }
            
        }
        
        if handleSelection.contains(.lower) {
            if newH + deltaY < self.minHeight {
                newH = self.minHeight
            }else {
                newH = self.frame.size.height + deltaY
            }
            
            if newY + newH > superview.bounds.maxY {
                newH = superview.bounds.maxY - newY
            }

        }
        
        if handleSelection.contains(.right) {
            if newW + deltaX < self.minWidth {
                newW = self.minWidth
            }else {
                newW = self.frame.size.width + deltaX
            }
            
            if newX + newW > superview.bounds.maxX {
                newW = superview.bounds.maxX - newX
            }

        }
        
        self.frame = CGRect(x: newX, y: newY, width: newW, height: newH)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard showBorders, let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.blue.cgColor)
        let centerSpacing = borderInset / 2
        let segments = [CGPoint(x:rect.minX + centerSpacing, y: rect.minY + centerSpacing),
                        CGPoint(x:rect.maxX - centerSpacing, y: rect.minY + centerSpacing),
                        CGPoint(x:rect.maxX - centerSpacing, y: rect.minY + centerSpacing),
                        CGPoint(x:rect.maxX - centerSpacing, y: rect.maxY - centerSpacing),
                        CGPoint(x:rect.maxX - centerSpacing, y: rect.maxY - centerSpacing),
                        CGPoint(x:rect.minX + centerSpacing, y: rect.maxY - centerSpacing),
                        CGPoint(x:rect.minX + centerSpacing, y: rect.maxY - centerSpacing),
                        CGPoint(x:rect.minX + centerSpacing, y: rect.minY + centerSpacing)
                        ]
        context.strokeLineSegments(between: segments)
        
        context.setFillColor(UIColor.blue.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: self.bounds.size.width / 2 - centerSpacing, y: 0, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: self.bounds.size.width - borderInset, y: 0, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: self.bounds.size.width - borderInset, y: self.bounds.size.height / 2 - centerSpacing, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: self.bounds.size.width - borderInset, y: self.bounds.size.height - borderInset, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x:self.bounds.size.width / 2 - centerSpacing, y: self.bounds.size.height - borderInset, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: 0, y: self.bounds.size.height - borderInset, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
        context.fillEllipse(in: CGRect(x: 0, y: self.bounds.size.height / 2 - centerSpacing, width: borderInset, height: borderInset).insetBy(dx: (borderInset - handleSize) / 2, dy: (borderInset - handleSize) / 2))
    }
}
