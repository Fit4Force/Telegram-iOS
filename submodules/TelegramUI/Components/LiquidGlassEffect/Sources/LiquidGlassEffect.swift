import Foundation
import UIKit
import Display
import AsyncDisplayKit
import UIKitRuntimeUtils

// MARK: - Liquid Glass Effect for iOS Contest 2025
// This implementation provides custom Liquid Glass effects for iOS 13-18
// Replicates the look and feel of iOS 19+ glass effects with:
// - Glass blur on moving elements
// - Tap highlight animations
// - Scale-up and bounce effects
// - Stretching during interaction

public final class LiquidGlassEffectView: UIView {
    
    // MARK: - Properties
    private let blurView: UIVisualEffectView
    private let tintView: UIView
    private let highlightView: UIView
    private let contentMaskView: UIView
    
    private var isHighlighted: Bool = false
    private var currentScale: CGFloat = 1.0
    
    public var glassRadius: CGFloat = 8.0 {
        didSet {
            self.updateBlurEffect()
        }
    }
    
    public var tintColor: UIColor = UIColor(white: 1.0, alpha: 0.15) {
        didSet {
            self.tintView.backgroundColor = self.tintColor
        }
    }
    
    public var highlightColor: UIColor = UIColor(white: 1.0, alpha: 0.25) {
        didSet {
            self.highlightView.backgroundColor = self.highlightColor
        }
    }
    
    public var glassCornerRadius: CGFloat = 0.0 {
        didSet {
            self.updateCornerRadius()
        }
    }
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        // Create custom blur effect
        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.tintView = UIView()
        self.highlightView = UIView()
        self.contentMaskView = UIView()
        
        super.init(frame: frame)
        
        self.setupViews()
        self.setupBlurCustomization()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        // Add blur view
        self.addSubview(self.blurView)
        
        // Add tint overlay
        self.tintView.backgroundColor = self.tintColor
        self.addSubview(self.tintView)
        
        // Add highlight view (initially hidden)
        self.highlightView.backgroundColor = self.highlightColor
        self.highlightView.alpha = 0.0
        self.addSubview(self.highlightView)
        
        // Setup initial state
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
    }
    
    private func setupBlurCustomization() {
        // Customize blur effect for glass appearance
        for subview in self.blurView.subviews {
            if subview.description.contains("VisualEffectSubview") {
                subview.isHidden = true
            }
        }
        
        // Apply custom blur filter
        if let sublayer = self.blurView.layer.sublayers?[0], let filters = sublayer.filters {
            sublayer.backgroundColor = nil
            sublayer.isOpaque = false
            
            let allowedKeys: [String] = [
                "gaussianBlur"
            ]
            
            sublayer.filters = filters.filter { filter in
                guard let filter = filter as? NSObject else {
                    return true
                }
                let filterName = String(describing: filter)
                if !allowedKeys.contains(filterName) {
                    return false
                }
                return true
            }
            
            // Set custom blur radius
            if let filter = sublayer.filters?.first as? NSObject {
                filter.setValue(self.glassRadius, forKey: "inputRadius")
            }
        }
    }
    
    private func updateBlurEffect() {
        if let sublayer = self.blurView.layer.sublayers?[0] {
            if let filter = sublayer.filters?.first as? NSObject {
                filter.setValue(self.glassRadius, forKey: "inputRadius")
            }
        }
    }
    
    private func updateCornerRadius() {
        self.layer.cornerRadius = self.glassCornerRadius
        self.blurView.layer.cornerRadius = self.glassCornerRadius
        self.tintView.layer.cornerRadius = self.glassCornerRadius
        self.highlightView.layer.cornerRadius = self.glassCornerRadius
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        self.blurView.frame = bounds
        self.tintView.frame = bounds
        self.highlightView.frame = bounds
    }
    
    // MARK: - Animations
    
    /// Highlight animation on tap
    public func animateHighlight(completion: (() -> Void)? = nil) {
        self.isHighlighted = true
        
        // Show highlight with quick fade in
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.highlightView.alpha = 1.0
        }, completion: { _ in
            // Fade out highlight
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.highlightView.alpha = 0.0
            }, completion: { _ in
                self.isHighlighted = false
                completion?()
            })
        })
    }
    
    /// Scale up and bounce animation
    public func animatePress(scale: CGFloat = 0.92, completion: (() -> Void)? = nil) {
        self.currentScale = scale
        
        // Press down animation
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            // Bounce back with spring animation
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.transform = .identity
            }, completion: { _ in
                self.currentScale = 1.0
                completion?()
            })
        })
    }
    
    /// Combined press animation with highlight
    public func animatePressWithHighlight(scale: CGFloat = 0.92, completion: (() -> Void)? = nil) {
        // Trigger both animations simultaneously
        self.animateHighlight()
        self.animatePress(scale: scale, completion: completion)
    }
    
    /// Stretch animation for elastic effect
    public func animateStretch(direction: StretchDirection, amount: CGFloat, completion: (() -> Void)? = nil) {
        let stretchTransform: CGAffineTransform
        
        switch direction {
        case .horizontal:
            stretchTransform = CGAffineTransform(scaleX: 1.0 + amount, y: 1.0 - amount * 0.5)
        case .vertical:
            stretchTransform = CGAffineTransform(scaleX: 1.0 - amount * 0.5, y: 1.0 + amount)
        }
        
        // Apply stretch
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = stretchTransform
        }, completion: { _ in
            // Spring back to normal
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.transform = .identity
            }, completion: { _ in
                completion?()
            })
        })
    }
    
    /// Continuous stretch animation during drag
    public func updateStretch(offset: CGFloat, direction: StretchDirection) {
        let normalizedOffset = min(abs(offset) / 100.0, 0.3) // Cap at 0.3
        let stretchAmount = normalizedOffset
        
        let stretchTransform: CGAffineTransform
        switch direction {
        case .horizontal:
            stretchTransform = CGAffineTransform(scaleX: 1.0 + stretchAmount, y: 1.0 - stretchAmount * 0.5)
        case .vertical:
            stretchTransform = CGAffineTransform(scaleX: 1.0 - stretchAmount * 0.5, y: 1.0 + stretchAmount)
        }
        
        self.transform = stretchTransform
    }
    
    /// Reset to normal state
    public func resetStretch(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.transform = .identity
            })
        } else {
            self.transform = .identity
        }
    }
    
    public enum StretchDirection {
        case horizontal
        case vertical
    }
}

// MARK: - Liquid Glass Node for AsyncDisplayKit
public final class LiquidGlassNode: ASDisplayNode {
    
    private var liquidGlassView: LiquidGlassEffectView {
        return self.view as! LiquidGlassEffectView
    }
    
    public var glassRadius: CGFloat {
        get { return self.liquidGlassView.glassRadius }
        set { self.liquidGlassView.glassRadius = newValue }
    }
    
    public var tintColor: UIColor {
        get { return self.liquidGlassView.tintColor }
        set { self.liquidGlassView.tintColor = newValue }
    }
    
    public var glassCornerRadius: CGFloat {
        get { return self.liquidGlassView.glassCornerRadius }
        set { self.liquidGlassView.glassCornerRadius = newValue }
    }
    
    public override init() {
        super.init()
        
        self.setViewBlock({
            return LiquidGlassEffectView()
        })
    }
    
    public func animateHighlight(completion: (() -> Void)? = nil) {
        self.liquidGlassView.animateHighlight(completion: completion)
    }
    
    public func animatePress(scale: CGFloat = 0.92, completion: (() -> Void)? = nil) {
        self.liquidGlassView.animatePress(scale: scale, completion: completion)
    }
    
    public func animatePressWithHighlight(scale: CGFloat = 0.92, completion: (() -> Void)? = nil) {
        self.liquidGlassView.animatePressWithHighlight(scale: scale, completion: completion)
    }
    
    public func animateStretch(direction: LiquidGlassEffectView.StretchDirection, amount: CGFloat, completion: (() -> Void)? = nil) {
        self.liquidGlassView.animateStretch(direction: direction, amount: amount, completion: completion)
    }
    
    public func updateStretch(offset: CGFloat, direction: LiquidGlassEffectView.StretchDirection) {
        self.liquidGlassView.updateStretch(offset: offset, direction: direction)
    }
    
    public func resetStretch(animated: Bool = true) {
        self.liquidGlassView.resetStretch(animated: animated)
    }
}
