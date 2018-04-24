//
//  SnapView.swift
//  SnapView
//
//  Created by marc matta on 4/24/18.
//  Copyright © 2018 marx. All rights reserved.
//

import UIKit

protocol SnappableView: NSObjectProtocol {
    func setSelected(selected: Bool)
}

extension UIView : SnappableView {
    func setSelected(selected: Bool) {
        if !selected {
            self.resignFirstResponder()
        }
        
        self.layer.borderColor = selected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = selected ? 2 : 0
    }
}

class SnapView: UIView {
    /// gesture used to pan views
    var panGesture: UIPanGestureRecognizer!
    
    /// gesture used to select view before panning
    var tapGesture: UITapGestureRecognizer!
    
    /// translation offset from point of touch to center of selected view
    var offset = CGPoint.zero
    
    /// the guy we're dragging
    var selectedView: UIView! {
        didSet {
            if let oldView = oldValue {
                oldView.setSelected(selected: false)
            }
            
            if let view = selectedView {
                view.setSelected(selected: true)
                
                self.panGesture.isEnabled = true
            }else {
                self.panGesture.isEnabled = false
            }
        }
    }
    
    /// how near should the selected view move to start showing guides
    var threshold:CGFloat = 10.0
    
    /// should not drag if not selected
    var shouldPan = false
    
    /// minimum spacing distance to start snapping horizontally
    var snapX : CGFloat = 5.0
    
    /// minimum spacing distance to start snapping vertically
    var snapY : CGFloat = 5.0
    
    /// vertical snapping guides
    var guidesX : [CGFloat] = [20]
    
    /// horizontal snapping guides
    var guidesY : [CGFloat] = [20]
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    // MARK - Private
    private func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.cancelsTouchesInView = true
        self.addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(rec:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delaysTouchesEnded = true
        tapGesture.cancelsTouchesInView = true
        
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Gesture Callbacks

    @objc func tap(rec:UITapGestureRecognizer) {
        switch rec.state {
        case .ended:
            let p: CGPoint = rec.location(in: self)
            if let view = self.hitTest(p, with: nil), view != self {
                self.selectedView = view
                DispatchQueue.main.async {
                    self.bringSubview(toFront: view)
                    self.subviews.forEach({ (v) in
                        if v != view {
                            v.layer.zPosition = 0
                        }else {
                            v.layer.zPosition = 1
                        }
                    })
                }
            }else {
                self.selectedView = nil
            }
        default:
            break
        }
    }
    
    @objc func pan(_ pan: UIPanGestureRecognizer) {
        var location = pan.location(in: self)
        
        switch pan.state {
        case .began:
            shouldPan = true
            
            let p = pan.location(in: self)
            if self.hitTest(p, with: nil) != self.selectedView {
                shouldPan = false
            }
            
            if self.selectedView != nil && shouldPan {
                // Capture the initial touch offset from the itemView's center.
                let center = self.selectedView.center
                offset.x = location.x - center.x
                offset.y = location.y - center.y
            }
            
        case .changed:
            if shouldPan {
                // Get reference bounds.
                let referenceBounds = self.bounds
                let referenceWidth = referenceBounds.width
                let referenceHeight = referenceBounds.height
                
                // Get item bounds.
                let itemBounds = self.selectedView.bounds
                let itemHalfWidth = itemBounds.width / 2.0
                let itemHalfHeight = itemBounds.height / 2.0
                
                // Apply the initial offset.
                location.x -= offset.x
                location.y -= offset.y
                
                // Bound the item position inside the reference view.
                location.x = max(itemHalfWidth, location.x)
                location.x = min(referenceWidth - itemHalfWidth, location.x)
                location.y = max(itemHalfHeight, location.y)
                location.y = min(referenceHeight - itemHalfHeight, location.y)
                
                // Snap to closest sibling
                guidesX.removeAll()
                guidesY.removeAll()
                
                self.subviews.filter{$0 != self.selectedView}.forEach { (view) in
                    if (view.frame.minX - self.selectedView.frame.minX < threshold) ||
                        (view.frame.minX - self.selectedView.frame.maxX < threshold){
                        guidesX.append(view.frame.minX)
                    }
                    
                    if (view.frame.maxX - self.selectedView.frame.minX < threshold) ||
                        (view.frame.maxX - self.selectedView.frame.maxX < threshold) {
                        guidesX.append(view.frame.maxX)
                    }
                    
                    if (view.frame.minY - self.selectedView.frame.minY < threshold) ||
                        (view.frame.minY - self.selectedView.frame.maxY < threshold){
                        guidesY.append(view.frame.minY)
                    }
                    
                    if (view.frame.maxY - self.selectedView.frame.minY < threshold) ||
                        (view.frame.maxY - self.selectedView.frame.maxY < threshold) {
                        guidesY.append(view.frame.maxY)
                    }
                }
                
                let closestXs = guidesX.map({ guide -> CGFloat in
                    let distance1 = guide - (location.x + itemHalfWidth)
                    let distance2 = guide - (location.x - itemHalfWidth)
                    
                    if abs(distance1) < snapX || abs(distance2) < snapX {
                        return abs(distance1) < abs(distance2) ? distance1 : distance2
                    }
                    
                    return CGFloat.greatestFiniteMagnitude
                }).sorted { (value1, value2) -> Bool in
                    return value1 < value2
                }
                
                if let closestX = closestXs.first, abs(closestX) < snapX {
                    location.x += closestX
                }
                
                let closestYs = guidesY.map({ guide -> CGFloat in
                    let distance1 = guide - (location.y + itemHalfHeight)
                    let distance2 = guide - (location.y - itemHalfHeight)
                    
                    if abs(distance1) < snapY || abs(distance2) < snapY {
                        return abs(distance1) < abs(distance2) ? distance1 : distance2
                    }
                    
                    return CGFloat.greatestFiniteMagnitude
                }).sorted { (value1, value2) -> Bool in
                    return value1 < value2
                }
                
                if let closestY = closestYs.first, closestY < snapY{
                    location.y += closestY
                }
                
                // Apply the resulting item center.
                self.selectedView.center = location
                
                // draw guides
                self.setNeedsDisplay()
            }
        case .cancelled, .ended:
            // Get the current velocity of the item from the pan gesture recognizer.
            shouldPan = false
            offset = CGPoint.zero
            
            // remove guides
            self.setNeedsDisplay()
        default: ()
        }
    }
    
    // MARK: Override points
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return super.hitTest(point, with: event)
        }
        
        guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
            return nil
        }
        
        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard shouldPan, let view = selectedView, let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setStrokeColor(UIColor.blue.cgColor)
        
        let minimumX = view.frame.minX
        let maximumX = view.frame.maxX
        
        for guide in self.guidesX {
            if abs(minimumX - guide) < threshold || abs(maximumX - guide) < threshold {
                context.beginPath()
                context.setLineDash(phase: 0, lengths: [4,4])
                context.move(to: CGPoint(x: guide, y: rect.minY))
                context.addLine(to: CGPoint(x: guide, y: rect.maxY))
                context.drawPath(using: CGPathDrawingMode.stroke)
                context.closePath()
            }
        }
        
        let minimumY = view.frame.minY
        let maximumY = view.frame.maxY
        
        for guide in self.guidesY {
            if abs(minimumY - guide) < threshold || abs(maximumY - guide) < threshold {
                context.beginPath()
                context.setLineDash(phase: 0, lengths: [4,4])
                context.move(to: CGPoint(x: rect.minX, y: guide))
                context.addLine(to: CGPoint(x: rect.maxX, y: guide))
                context.strokePath()
                context.closePath()
            }
        }
    }
}
