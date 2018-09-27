//
//  SnapView.swift
//  SnapView
//
//  Created by marc matta on 4/24/18.
//  Copyright © 2018 marx. All rights reserved.
//

import UIKit

extension FloatingPoint {
    var toRadians: Self { return self * .pi / 180 }
    var toDegrees: Self { return self * 180 / .pi }
}

protocol Snappable: NSObjectProtocol {
    var isSelected : Bool {get set}
    func setSelected(selected: Bool)
}

class SnappableView<T: SnappableItem> : UIView, Snappable {
    var item: T
    var isSelected: Bool = false
    
    init(item: T) {
        self.item = item
        super.init(frame: CGRect(x: item.x, y: item.y, width: item.width, height: item.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(selected: Bool) {
        self.isSelected = selected
        
        if !selected {
            self.resignAllResponders()
        }
        
        self.layer.borderColor = selected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = selected ? 2 : 0
    }
}

extension UIView {
    func resignAllResponders() {
        self.subviews.forEach {
            $0.resignFirstResponder()
            $0.resignAllResponders()
        }
    }
    
    func contains(subview: UIView) -> Bool{
        for view in self.subviews {
            if view == subview || view.contains(subview: subview){
                return true
            }
        }
        
        return false
    }
}

protocol SnappableItem {
    var x: CGFloat {get set}
    var y: CGFloat {get set}
    var width: CGFloat {get set}
    var height: CGFloat {get set}
    
    var contentView: UIView {get}
}

class SnapView: UIView {
    /// gesture used to pan views
    private var panGesture: UIPanGestureRecognizer!
    
    /// gesture used to select view before panning
    private var tapGesture: UITapGestureRecognizer!
    
    /// translation offset from point of touch to center of selected view
    private var offset = CGPoint.zero
    
    /// should not drag if not selected
    private var shouldPan = false
    
    /// vertical snapping guides
    private var guidesX : [CGFloat] = []
    
    /// horizontal snapping guides
    private var guidesY : [CGFloat] = []
    
    /// items to draw
    public var items : [SnappableItem] = [] {
        didSet {
            self.subviews.forEach{$0.removeFromSuperview()}
            
            items.forEach { (item) in
                let content = item.contentView
                content.frame = boundedFrame(forView: content)
                self.addSubview(content)
            }
        }
    }
    
    /// the guy we're dragging
    public var selectedView: UIView! {
        didSet {
            if let oldView = oldValue as? Snappable, oldValue != selectedView {
                oldView.setSelected(selected: false)
            }
            
            if let view = selectedView as? Snappable{
                view.setSelected(selected: true)
                
                self.panGesture.isEnabled = true
            }else {
                self.panGesture.isEnabled = false
                resignAllResponders()
            }
        }
    }
    
    /// minimum width
    public var minimumWidth : CGFloat?
    
    /// minimum height
    public var minimumHeight : CGFloat?
    
    /// how near should the selected view move to start showing guides
    public var threshold:CGFloat = 10.0
    
    /// minimum spacing distance to start snapping horizontally
    public var snapX : CGFloat = 5.0
    
    /// minimum spacing distance to start snapping vertically
    public var snapY : CGFloat = 5.0
    
    override var frame: CGRect {
        didSet {
            
        }
    }
    
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

    @objc private func tap(rec:UITapGestureRecognizer) {
        switch rec.state {
        case .ended:
            let p: CGPoint = rec.location(in: self)
            let view = self.hitTest(p, with: nil)
            if view != nil && view != self {
                self.selectedView = view
                DispatchQueue.main.async {
                    self.bringSubview(toFront: view!)
                    self.subviews.forEach({ (v) in
                        if v != view {
                            v.layer.zPosition = 0
                        }else {
                            v.layer.zPosition = 1
                        }
                    })
                }
            }else if view == self{
                self.selectedView = nil
            }
        default:
            break
        }
    }
    
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        var location = pan.location(in: self)
        
        switch pan.state {
        case .began:
            shouldPan = true
            
            let p = pan.location(in: self)
            if let touchedView = self.hitTest(p, with: nil), touchedView != self.selectedView && !self.selectedView.contains(subview: touchedView) {
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
                let itemBounds = self.selectedView.frame
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
                
                guidesX.append(contentsOf: [5, self.bounds.width / 2, self.bounds.width - 5])
                guidesY.append(contentsOf: [5, self.bounds.height / 2, self.bounds.height - 5])
                
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
    override internal func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            
            let view = super.hitTest(point, with: event)
            if view == nil || view!.isUserInteractionEnabled || subviews.contains(view!) {
                return view
            }
            
            guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
                return nil
            }
            
            for subview in subviews.reversed() {
                if subview.frame.contains(point) {
                    return subview
                }
            }
            return self
        }
        
        return nil
    }
    
    override internal func draw(_ rect: CGRect) {
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
    
    private func boundedFrame(usingRect rect: CGRect) -> CGRect {
        // Get reference bounds.
        let referenceBounds = self.bounds
        let referenceWidth = referenceBounds.width
        let referenceHeight = referenceBounds.height
        
        // Get item bounds.
        var itemBounds = rect
        var width = minimumWidth != nil ? max(itemBounds.width, minimumWidth!) : itemBounds.width
        var height = minimumHeight != nil ? max(itemBounds.height, minimumHeight!) : itemBounds.height
        
        if itemBounds.width > referenceBounds.width {
            width = referenceBounds.width
        }
        
        if itemBounds.height > referenceBounds.height {
            height = referenceBounds.height
        }
        
        itemBounds = CGRect(origin: itemBounds.origin, size: CGSize(width: width, height: height))
        
        let itemHalfWidth = itemBounds.width / 2.0
        let itemHalfHeight = itemBounds.height / 2.0
        
        // bound the view inside the reference
        var location = itemBounds.offsetBy(dx: itemHalfWidth, dy: itemHalfHeight).origin
        location.x = max(itemHalfWidth, location.x)
        location.x = min(referenceWidth - itemHalfWidth, location.x)
        location.y = max(itemHalfHeight, location.y)
        location.y = min(referenceHeight - itemHalfHeight, location.y)
        
        return CGRect(origin: CGPoint(x: location.x - itemHalfWidth, y: location.y - itemHalfHeight), size: itemBounds.size)
    }
    
    private func boundedFrame(forView view: UIView) -> CGRect {
        return boundedFrame(usingRect: view.frame)
    }
    
    // MARK: - Public
    public func rotate(degrees: CGFloat) {
        if let view = self.selectedView {
            view.transform = CGAffineTransform.identity.rotated(by: degrees.toRadians)
            view.frame = boundedFrame(forView: view)
        }
    }
    
    public func viewRotation() -> CGFloat? {
        if let view = selectedView {
            return rotation(forView: view)
        }
        
        return nil
    }
    
    public func rotation(forView view: UIView) -> CGFloat {
        return CGFloat(atan2f(Float(view.transform.b), Float(view.transform.a)).toDegrees)
    }
    
    public func changeFrame(forView view: UIView, usingRect rect: CGRect) {
        let transformedRect = rect.applying(CGAffineTransform.identity.rotated(by: rotation(forView: view).toRadians))
        view.frame = boundedFrame(usingRect: CGRect(origin: rect.origin, size: transformedRect.size))
    }
}
