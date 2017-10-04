//
//  CollectionViewLayout.swift
//  ScanRecipe
//
//  Created by Kaushal Deo on 10/3/17.
//  Copyright © 2017 Scorpion Inc. All rights reserved.
//

import UIKit

@objc protocol CollectionViewLayoutDelegate {
    /**
     Size for section header. Optional.
     
     @param collectionView - collectionView
     @param section - section for section header view
     
     Returns size for section header view.
     */
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionHeaderViewForSection section: Int) -> CGSize
    /**
     Size for section footer. Optional.
     
     @param collectionView - collectionView
     @param section - section for section footer view
     
     Returns size for section footer view.
     */
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionFooterViewForSection section: Int) -> CGSize
    /**
     Height for cell in column.
     
     @param collectionView - collectionView
     @param indexPath - index path for cell
     
     Returns height of image view.
     */
    @objc optional func collectionView(collectionView: UICollectionView,
                                       heightForCellAtIndexPath indexPath: IndexPath,
                                       withWidth: CGFloat) -> CGFloat
    
}

@IBDesignable class CollectionViewLayout: UICollectionViewLayout {
    
    @IBOutlet weak var delegate : CollectionViewLayoutDelegate?
    /**
     Number of columns.
     */
    @IBInspectable var numberOfColumns: Int = 2
    
    /**
     Cell padding.
     */
    @IBInspectable var cellPadding: CGFloat = 1
    
    
    private var cache = [CollectionLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        get {
            let bounds = collectionView.bounds
            let insets = collectionView.contentInset
            return bounds.width - insets.left - insets.right
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(
                width: contentWidth,
                height: contentHeight
            )
        }
    }
    
    override class var layoutAttributesClass: AnyClass {
        return CollectionLayoutAttributes.self
    }
    
    override var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    private var numberOfSections: Int {
        return collectionView.numberOfSections
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    /**
     Invalidates layout.
     */
    override func invalidateLayout() {
        cache.removeAll()
        contentHeight = 0
        
        super.invalidateLayout()
    }
    
    override func prepare() {
        if cache.isEmpty {
            let collumnWidth = contentWidth / CGFloat(numberOfColumns)
            let cellWidth = collumnWidth - (cellPadding * 2)
            
            var xOffsets = [CGFloat]()
            
            for collumn in 0..<numberOfColumns {
                xOffsets.append(CGFloat(collumn) * collumnWidth)
            }
            
            for section in 0..<numberOfSections {
                let numberOfItems = self.numberOfItems(inSection: section)
                
                if let headerSize = self.delegate?.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionHeaderViewForSection: section
                    ) {
                    let headerX = (contentWidth - headerSize.width) / 2
                    let headerFrame = CGRect(
                        origin: CGPoint(
                            x: headerX,
                            y: contentHeight
                        ),
                        size: headerSize
                    )
                    let headerAttributes = CollectionLayoutAttributes(
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                        with: IndexPath(item: 0, section: section)
                    )
                    headerAttributes.frame = headerFrame
                    cache.append(headerAttributes)
                    
                    contentHeight = headerFrame.maxY
                }
                
                var yOffsets = [CGFloat](
                    repeating: contentHeight,
                    count: numberOfColumns
                )
                
                for item in 0..<numberOfItems {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    let column = yOffsets.index(of: yOffsets.min() ?? 0) ?? 0
                    
                    let imageHeight : CGFloat = self.delegate?.collectionView?(collectionView: collectionView, heightForCellAtIndexPath: indexPath, withWidth: cellWidth) ?? cellWidth
                    let cellHeight = cellPadding + imageHeight + cellPadding
                    
                    let frame = CGRect(
                        x: xOffsets[column],
                        y: yOffsets[column],
                        width: collumnWidth,
                        height: cellHeight
                    )
                    
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    let attributes = CollectionLayoutAttributes(
                        forCellWith: indexPath
                    )
                    attributes.frame = insetFrame
                    attributes.imageHeight = imageHeight
                    cache.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffsets[column] = yOffsets[column] + cellHeight
                }
                
                if let footerSize = self.delegate?.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionFooterViewForSection: section
                    ) {
                    let footerX = (contentWidth - footerSize.width) / 2
                    let footerFrame = CGRect(
                        origin: CGPoint(
                            x: footerX,
                            y: contentHeight
                        ),
                        size: footerSize
                    )
                    let footerAttributes = CollectionLayoutAttributes(
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                        with: IndexPath(item: 0, section: section)
                    )
                    footerAttributes.frame = footerFrame
                    cache.append(footerAttributes)
                    
                    contentHeight = footerFrame.maxY
                }
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        if let context = super.invalidationContext(forBoundsChange: newBounds) as? UICollectionViewFlowLayoutInvalidationContext {
        context.invalidateFlowLayoutDelegateMetrics = newBounds.width != self.collectionView.bounds.width || newBounds.height != self.collectionView.bounds.height
        return context
        }
        return super.invalidationContext(forBoundsChange: newBounds)
    }

}

/**
 CollectionViewLayoutAttributes.
 */
class CollectionLayoutAttributes: UICollectionViewLayoutAttributes {
    /**
     Image height to be set to contstraint in collection view cell.
     */
    var imageHeight: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CollectionLayoutAttributes
        copy.imageHeight = imageHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? CollectionLayoutAttributes {
            if attributes.imageHeight == imageHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}
