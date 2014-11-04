//
//  PanorificViewController.swift
//  Panorific
//
//  Created by Naji Dmeiri on 9/16/14.
//  Copyright (c) 2014 Naji Dmeiri. All rights reserved.
//

import UIKit
import CoreMotion

class PanorificViewController: UIViewController, UIScrollViewDelegate {
    
    // The image that will be diplayed in the receiver.
    var image: UIImage?
    
    // Subviews
    private var panningScrollView: UIScrollView!
    private var panningImageView: UIImageView!
    private var scrollBarView: PanorificScrollBarView!
    
    // Managing Motion Sensing
    private var motionManager: CMMotionManager = CMMotionManager()
    private var motionBasedPanEnabled: Bool = true
    
    // Managing Animation
    private var displayLink: CADisplayLink!
    
    // Contstants
    private let MovementSmoothing: CGFloat = 0.3
    private let AnimationDuration: CGFloat = 0.3
    private let RotationMultiplier: CGFloat = 5.0
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.panningScrollView = UIScrollView(frame: self.view.bounds)
        self.panningScrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.panningScrollView.backgroundColor = UIColor.blackColor()
        self.panningScrollView.delegate = self
        self.panningScrollView.scrollEnabled = false
        self.panningScrollView.alwaysBounceVertical = false
        self.panningScrollView.maximumZoomScale = 2.0
        self.panningScrollView.pinchGestureRecognizer.addTarget(self, action: "pinchGestureRecognized:")
        self.view.addSubview(self.panningScrollView)
        
        self.panningImageView = UIImageView(frame: self.view.bounds)
        self.panningImageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.panningImageView.backgroundColor = UIColor.blackColor()
        self.panningImageView.contentMode = .ScaleAspectFit
        self.panningScrollView.addSubview(self.panningImageView)
        
        self.scrollBarView = PanorificScrollBarView(frame: self.view.bounds, edgeInsets: UIEdgeInsetsMake(0.0, 10.0, 50.0, 10.0))
        self.scrollBarView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.scrollBarView.userInteractionEnabled = false
        self.view.addSubview(self.scrollBarView)
        
        self.displayLink = CADisplayLink(target: self, selector: "displayLinkUpdate:")
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleMotionBasedPan:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.configureWithImage(self.image!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.panningScrollView.contentOffset = CGPointMake((self.panningScrollView.contentSize.width / 2.0) - (CGRectGetWidth(self.panningScrollView.bounds)) / 2.0,
            (self.panningScrollView.contentSize.height / 2.0) - (CGRectGetHeight(self.panningScrollView.bounds)) / 2.0)
        
        self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(),
            withHandler: { (motion: CMDeviceMotion!, error: NSError!) -> Void in
                self.calculateRotationBasedOnDeviceMotionRotationRate(motion)
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.image = nil
        
        super.viewDidDisappear(animated)
    }
    
    deinit {
        self.displayLink.invalidate()
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Instance methods
    
    func configureWithImage(image: UIImage) {
        self.panningImageView.image = image
        self.updateScrollViewZoomToMaximumForImage(image)
    }
    
    func calculateRotationBasedOnDeviceMotionRotationRate(motion: CMDeviceMotion) {
        if self.motionBasedPanEnabled {
            let xRotationRate = CGFloat(motion.rotationRate.x)
            let yRotationRate = CGFloat(motion.rotationRate.y)
            let zRotationRate = CGFloat(motion.rotationRate.z)
            
            if abs(yRotationRate) > (abs(xRotationRate) + abs(zRotationRate)) {
                let invertedYRotationRate = yRotationRate * -1.0
                
                let zoomScale = self.maximumZoomScaleForImage(self.panningImageView.image!)
                let interpretedXOffset = self.panningScrollView.contentOffset.x + invertedYRotationRate * zoomScale * RotationMultiplier
                
                let contentOffset = self.clampedContentOffsetForHorizontalOffset(interpretedXOffset)
                
                UIView.animateWithDuration(NSTimeInterval(MovementSmoothing), delay: 0.0,
                    options: .BeginFromCurrentState | .AllowUserInteraction | .CurveEaseOut,
                    animations: { () -> Void in
                        self.panningScrollView.setContentOffset(contentOffset, animated: false)
                    },
                    completion: nil)
            }
        }
    }
    
    func displayLinkUpdate(displayLink: CADisplayLink) {
        let panningImageViewPresentationLayer: AnyObject! = self.panningImageView.layer.presentationLayer()
        let panningScrollViewPresentationLayer: AnyObject! = self.panningScrollView.layer.presentationLayer()
        
        let horizontalContentOffset = CGRectGetMinX(panningScrollViewPresentationLayer.bounds)
        
        let contentWidth = CGRectGetWidth(panningImageViewPresentationLayer.frame)
        let visibleWidth = CGRectGetWidth(self.panningScrollView.bounds)
        
        let clampedXOffsetAsPercentage = max(0.0, min(1.0, horizontalContentOffset / (contentWidth - visibleWidth)))
        
        let scrollBarWidthPercentage = visibleWidth / contentWidth
        let scrollableAreaPercentage = 1.0 - scrollBarWidthPercentage
        
        self.scrollBarView.updateWithScrollAmount(clampedXOffsetAsPercentage,
            forScrollableWidth: scrollBarWidthPercentage,
            inScrollableArea: scrollableAreaPercentage)
    }
    
    func toggleMotionBasedPan(sender: AnyObject) {
        let motionBasedPanWasEnabled = self.motionBasedPanEnabled
        
        if motionBasedPanWasEnabled {
            self.motionBasedPanEnabled = false
        }
        
        UIView.animateWithDuration(NSTimeInterval(AnimationDuration), animations: {
            self.updateViewsForMotionBasedPanEnabled(!motionBasedPanWasEnabled)
            }, completion: { (_) in
                if !motionBasedPanWasEnabled {
                    self.motionBasedPanEnabled = true
                }
        })
    }
    
    func updateViewsForMotionBasedPanEnabled(motionBasedPanEnabled: Bool) {
        if motionBasedPanEnabled {
            self.updateScrollViewZoomToMaximumForImage(self.panningImageView.image!)
            self.panningScrollView.scrollEnabled = false
        } else {
            self.panningScrollView.zoomScale = 1.0
            self.panningScrollView.scrollEnabled = true
        }
    }
    
    func maximumZoomScaleForImage(image: UIImage) -> CGFloat {
        return (CGRectGetHeight(self.panningScrollView.bounds) / CGRectGetWidth(self.panningScrollView.bounds)) * (image.size.width / image.size.height)
    }
    
    func updateScrollViewZoomToMaximumForImage(image: UIImage) {
        let zoomScale = self.maximumZoomScaleForImage(image)
        
        self.panningScrollView.maximumZoomScale = zoomScale
        self.panningScrollView.zoomScale = zoomScale
    }
    
    func clampedContentOffsetForHorizontalOffset(horizontalOffset: CGFloat) -> CGPoint {
        let maximumXOffset = self.panningScrollView.contentSize.width - CGRectGetWidth(self.panningScrollView.bounds)
        let minimumXOffset: CGFloat = 0.0
        
        let clampedXOffset = max(minimumXOffset, min(horizontalOffset, maximumXOffset))
        let centeredY = (self.panningScrollView.contentSize.height / 2.0) - (CGRectGetHeight(self.panningScrollView.bounds)) / 2.0
        
        return CGPointMake(clampedXOffset, centeredY)
    }
    
    func pinchGestureRecognized(sender: AnyObject) {
        self.motionBasedPanEnabled = false
        self.panningScrollView.scrollEnabled = true
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.panningImageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        scrollView.setContentOffset(self.clampedContentOffsetForHorizontalOffset(scrollView.contentOffset.x), animated: true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            scrollView.setContentOffset(self.clampedContentOffsetForHorizontalOffset(scrollView.contentOffset.x), animated:true)
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollView.setContentOffset(self.clampedContentOffsetForHorizontalOffset(scrollView.contentOffset.x), animated: true)
    }
}
