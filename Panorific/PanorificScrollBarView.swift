//
//  PanorificScrollBarView.swift
//  Panorific
//
//  Created by Naji Dmeiri on 9/16/14.
//  Copyright (c) 2014 Naji Dmeiri. All rights reserved.
//

import UIKit

class PanorificScrollBarView: UIView {
    
    let scrollBarLayer = CAShapeLayer()
    
    init(frame: CGRect, edgeInsets: UIEdgeInsets) {
        super.init(frame: frame)
        
        let scrollBarPath = UIBezierPath()
        scrollBarPath.moveToPoint(CGPointMake(edgeInsets.left, CGRectGetHeight(self.bounds) - edgeInsets.bottom))
        scrollBarPath.addLineToPoint(CGPointMake(CGRectGetWidth(self.bounds) - edgeInsets.right, CGRectGetHeight(self.bounds) - edgeInsets.bottom))
        
        let scrollBarBackgroundLayer = CAShapeLayer()
        scrollBarBackgroundLayer.path = scrollBarPath.CGPath
        scrollBarBackgroundLayer.lineWidth = 1.0
        scrollBarBackgroundLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.1).CGColor
        scrollBarBackgroundLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(scrollBarBackgroundLayer)
        
        self.scrollBarLayer.path = scrollBarPath.CGPath
        self.scrollBarLayer.lineWidth = 1.0
        self.scrollBarLayer.strokeColor = UIColor.whiteColor().CGColor
        self.scrollBarLayer.fillColor = UIColor.clearColor().CGColor
        self.scrollBarLayer.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
        self.layer.addSublayer(self.scrollBarLayer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateWithScrollAmount(scrollAmount: CGFloat, forScrollableWidth scrollableWidth: CGFloat, inScrollableArea scrollableArea: CGFloat) {
        self.scrollBarLayer.strokeStart = scrollAmount * scrollableArea
        self.scrollBarLayer.strokeEnd = scrollAmount * scrollableArea + scrollableWidth
    }
}
