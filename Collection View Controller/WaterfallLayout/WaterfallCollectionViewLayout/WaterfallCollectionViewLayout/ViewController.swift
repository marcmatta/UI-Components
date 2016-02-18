//
//  ViewController.swift
//  WaterfallCollectionViewLayout
//
//  Created by marc matta on 11/19/15.
//  Copyright © 2015 marc matta. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, WaterfallCollectionViewLayoutDelegate {
    
    private var kScaleBoundLower = 0.8 as CGFloat
    private var kScaleBoundUpper = 1.5 as CGFloat
    private var _scale: CGFloat = 1
    private var scale : CGFloat {
        get {
            return _scale
        }
        
        set (newScale) {
            if (newScale < kScaleBoundLower)
            {
                _scale = kScaleBoundLower;
            }
            else if (newScale > kScaleBoundUpper)
            {
                _scale = kScaleBoundUpper;
            }
            else {
                _scale = newScale
            }
            
            (self.collectionView?.collectionViewLayout as! WaterfallCollectionViewLayout).itemSize = CGSizeMake(100*_scale,100*_scale) // Setting Default Value
            (self.collectionView?.collectionViewLayout as! WaterfallCollectionViewLayout).supplementaryViewSize = CGSizeMake(100*_scale,100*_scale) // Setting Default Value
            
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    private var scaleGesture:UIPinchGestureRecognizer?
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collectionView = self.collectionView {
            
            // Configuring WaterfallLayout
            let waterfallLayout = collectionView.collectionViewLayout as! WaterfallCollectionViewLayout
            waterfallLayout.itemSize = CGSizeMake(100,100) // Setting Default Value
            waterfallLayout.supplementaryViewSize = CGSizeMake(100, 100) // Setting Default Value
            waterfallLayout.stickyHeader = true
            waterfallLayout.verticalSpacing = 5
            waterfallLayout.horizontalSpacing = 5
            waterfallLayout.positioning = WaterfallCollectionItemPositioning.Middle
            waterfallLayout.delegate = self
            
            //Configuring Collection View
            collectionView.bounces = false
            collectionView.registerNib(UINib(nibName: "Header", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
            
            // Add the pinch to zoom gesture
            self.scaleGesture = UIPinchGestureRecognizer(target: self, action: "didReceivePinchGesture:")
            collectionView.addGestureRecognizer(self.scaleGesture!)
        }
    }
    
    // MARK:- Internal Methods
    var scaleStart : CGFloat = 0
    func didReceivePinchGesture(gesture:UIPinchGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began)
        {
            // Take an snapshot of the initial scale
            scaleStart = self.scale;
            return;
        }
        
        if (gesture.state == UIGestureRecognizerState.Changed)
        {
            // Apply the scale of the gesture to get the new scale
            self.scale = scaleStart * gesture.scale
        }
    }
    
    // MARK:- CollectionViewDataSource
    // MARK:-
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return random()%20 + 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 20
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
    }
    
    //MARK:- WaterfallDelegate
    func mm_waterfallCollectionViewLayout(layout: WaterfallCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize? {
        if indexPath.item%2==0 {
            return CGSizeMake(120*self.scale, 150*self.scale)
        }else {
            return CGSizeMake(self.scale*100,self.scale*100) // Use Default Value
        }
    }
    
    func mm_waterfallCollectionViewLayout(layout: WaterfallCollectionViewLayout, sizeForSupplementaryViewAtIndex index: Int) -> CGSize? {
        if index%2==0 {
            return CGSizeMake(150*self.scale, 150*self.scale)
        }else {
            return CGSizeMake(self.scale*100,self.scale*100) // Use Default Value
        }
    }
    
}
