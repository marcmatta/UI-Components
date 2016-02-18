//
//  MMWaterfallCollectionViewLayout.swift
//  WaterfallCollectionViewLayout
//
//  Created by marc matta on 11/19/15.
//  Copyright © 2015 marc matta. All rights reserved.
//

import UIKit

extension CGRect {
    static func mm_unionOfRects(rects: [CGRect]) -> CGRect {
        return rects.reduce(CGRect.zero) {CGRectUnion($0, $1)}
    }
}

protocol WaterfallCollectionViewLayoutDelegate : class{
    func mm_waterfallCollectionViewLayout(layout:WaterfallCollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize?
    func mm_waterfallCollectionViewLayout(layout:WaterfallCollectionViewLayout, sizeForSupplementaryViewAtIndex index:Int) -> CGSize?
}

enum WaterfallCollectionItemPositioning {
    case Left, Middle, Right
}

class WaterfallCollectionViewLayout: UICollectionViewLayout {
    
    // MARK:- Variables
    // MARK:-
    
    // MARK: Public
    var stickyColumnCount = 0
    var stickyHeader = false
    
    var positioning = WaterfallCollectionItemPositioning.Left {
        willSet (newPosition) {
            if (newPosition == positioning) {
                return
            }
        }
        didSet {
            self.invalidateLayout()
        }
    }
    
    var itemSize : CGSize = CGSizeZero {
        willSet (newSize) {
            if (CGSizeEqualToSize(newSize, itemSize)){
                return
            }
        }
        
        didSet {
            self.invalidateLayout()
        }
    }
    
    var supplementaryViewSize : CGSize = CGSize.zero {
        willSet (newSize) {
            if (CGSizeEqualToSize(newSize, supplementaryViewSize)){
                return
            }
        }
        
        didSet {
            self.invalidateLayout()
        }
    }
    
    var verticalSpacing:CGFloat = 0 {
        willSet (newSpacing) {
            if newSpacing == verticalSpacing {
                return
            }
        }
        
        didSet {
            self.invalidateLayout()
        }
    }
    
    var horizontalSpacing:CGFloat = 0 {
        willSet (newSpacing) {
            if newSpacing == horizontalSpacing {
                return
            }
        }
        
        didSet {
            self.invalidateLayout()
        }
    }
    
    weak var delegate : WaterfallCollectionViewLayoutDelegate?
    
    // MARK:-
    // MARK: Private
    var contentSize : CGSize = CGSizeZero
    private var attributes = [String:UICollectionViewLayoutAttributes]()
    
    
    // MARK:- Methods
    // MARK:- Overrides
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributes[self.keyForItemAtIndexPath(indexPath)]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = self.attributes.filter { (key, attribute) -> Bool in
            return CGRectIntersectsRect(attribute.frame, rect)
        }
        
        let supplementaryViewsAttributes = layoutAttributes.filter({ (key, value) -> Bool in
            return value.representedElementCategory != UICollectionElementCategory.Cell
        })
        
        adjustSupplementaryViewAttributes(supplementaryViewsAttributes.map {$0.1})
        
        return layoutAttributes.map {$0.1}
    }
    
    /*
    // Decoration Views supported : Highlight column background, Highlight Cell Background
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    return nil
    }
    */
    
    // column headers
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes =  self.attributes[self.keyForSupplementaryViewAtIndexPath(indexPath, elementKind: elementKind)] {
            self.adjustSupplementaryViewAttributes([attributes])
            return attributes
        }
        
        return nil
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        if self.collectionView?.numberOfSections() == 0 {
            return
        }
        
        self.attributes.removeAll()
        self.contentSize = CGSize.zero
        
        generateAttributes()
        calculateContentSize()
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    //MARK:- Private Methods
    private func adjustSupplementaryViewAttributes(attributes: [UICollectionViewLayoutAttributes]) {
        if stickyHeader {
            for attribute in attributes {
                if (attribute.representedElementCategory != UICollectionElementCategory.Cell) {
                    attribute.zIndex = 1024
                    attribute.frame.origin.y = (self.collectionView?.contentOffset.y)!
//                    let section = attribute.indexPath.section;
//                    let numberOfItemsInSection = self.collectionView?.numberOfItemsInSection(section)
//                    
//                    let firstCellIndexPath = NSIndexPath(forItem:0, inSection:section)
//                    let lastCellIndexPath = NSIndexPath(forItem:max(0, (numberOfItemsInSection! - 1)), inSection:section)
//                    
//                    let firstCellAttrs = self.layoutAttributesForItemAtIndexPath(firstCellIndexPath)
//                    let lastCellAttrs = self.layoutAttributesForItemAtIndexPath(lastCellIndexPath)
//                    
//                    let headerHeight = CGRectGetHeight(attribute.frame)
//                    
//                    attribute.frame.origin.y = min(
//                        max(
//                            self.collectionView!.contentOffset.y,
//                            (CGRectGetMinY(firstCellAttrs!.frame) - headerHeight)
//                        ),
//                        (CGRectGetMaxY(lastCellAttrs!.frame) - headerHeight)
//                    ) - verticalSpacing
                }
            }
        }
    }
    
    private func keyForItemAtIndexPath(indexPath: NSIndexPath) -> String {
        return "Item \(indexPath.section),\(indexPath.item)"
    }
    
    private func keyForSupplementaryViewAtIndexPath(indexPath: NSIndexPath, elementKind: String) -> String {
        return "\(elementKind) \(indexPath.section),\(indexPath.item)"
    }
    
    private func generateAttributes() {
        if let collectionView = self.collectionView {
            var xOffset : CGFloat = 0
            for var section = 0; section < collectionView.numberOfSections(); ++section {
                // Number of items in section
                let numberOfItemsInSection = collectionView.numberOfItemsInSection(section)
                
                // Cache supplementary view size and items size. Elements at index 0 being the supplementary view size
                var itemSizes = Array<CGSize>()
                
                if let delegate = self.delegate {
                    // Delegate is set
                    if let delegateSize = delegate.mm_waterfallCollectionViewLayout(self, sizeForSupplementaryViewAtIndex: section) {
                        itemSizes.append(delegateSize)
                    }else{
                        // delegateSize returned from delegate equal to nil. Use defaultValue
                        itemSizes.append(self.supplementaryViewSize)
                    }
                    
                    // Add Cell Sizes
                    for var item=0; item<numberOfItemsInSection; ++item{
                        let itemIndexPath = NSIndexPath(forItem: item, inSection: section)
                        if let delegateSize = delegate.mm_waterfallCollectionViewLayout(self, sizeForItemAtIndexPath: itemIndexPath) {
                            itemSizes.append(delegateSize)
                        }else {
                            itemSizes.append(self.itemSize)
                        }
                    }
                }else {
                    // Delegate no set. Use default values for all elements
                    itemSizes.append(self.supplementaryViewSize)
                    
                    for var item=0; item<numberOfItemsInSection; ++item{
                        itemSizes.append(self.itemSize)
                    }
                }
                
                // Header Attributes
                let maxSectionWidth = itemSizes.map{$0.width}.reduce(0){max($0,$1)}
                
                let supplementaryIndexPath = NSIndexPath(forItem: 0, inSection: section)
                let supplementaryHeaderKey = self.keyForSupplementaryViewAtIndexPath(supplementaryIndexPath, elementKind: UICollectionElementKindSectionHeader)
                let supplementaryAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: supplementaryIndexPath)
                
                var xOffsetSupplementaryView : CGFloat = 0
                
                switch positioning {
                case WaterfallCollectionItemPositioning.Left:
                    xOffsetSupplementaryView = xOffset
                case WaterfallCollectionItemPositioning.Middle:
                    xOffsetSupplementaryView = xOffset + (maxSectionWidth - itemSizes[0].width)/2
                case WaterfallCollectionItemPositioning.Right:
                    xOffsetSupplementaryView = xOffset + maxSectionWidth - itemSizes[0].width
                }
                
                supplementaryAttributes.frame = CGRectIntegral(CGRectMake(xOffsetSupplementaryView, 0, itemSizes[0].width, itemSizes[0].height))
                
                self.attributes[supplementaryHeaderKey] = supplementaryAttributes
                
                // Cell Attributes
                var cellYOffset : CGFloat = CGRectGetMaxY(supplementaryAttributes.frame) + verticalSpacing
                
                for var item=0; item<numberOfItemsInSection; ++item{
                    let cellIndexPath = NSIndexPath(forItem: item, inSection: section)
                    let cellKey = self.keyForItemAtIndexPath(cellIndexPath)
                    let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                    
                    var xOffsetCell = 0 as CGFloat
                    switch positioning {
                    case WaterfallCollectionItemPositioning.Left:
                        xOffsetCell = xOffset
                    case WaterfallCollectionItemPositioning.Middle:
                        xOffsetCell = xOffset + (maxSectionWidth - itemSizes[item+1].width)/2
                    case WaterfallCollectionItemPositioning.Right:
                        xOffsetCell = xOffset + maxSectionWidth - itemSizes[item+1].width
                    }
                    
                    cellAttributes.frame = CGRectIntegral(CGRectMake(xOffsetCell, cellYOffset, itemSizes[item+1].width, itemSizes[item+1].height))
                    
                    cellYOffset = CGRectGetMaxY(cellAttributes.frame) + verticalSpacing
                    
                    self.attributes[cellKey] = cellAttributes
                }
                
                xOffset += maxSectionWidth + (maxSectionWidth > horizontalSpacing ? horizontalSpacing: horizontalSpacing - maxSectionWidth)
            }
        }
    }
    
    private func calculateContentSize() {
        let attributes = Array(self.attributes.values)
        self.contentSize = CGRect.mm_unionOfRects(attributes.map {CGRectIntegral($0.frame)}).size
    }
}
