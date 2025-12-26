import Foundation
import UIKit
import Display
import ComponentFlow
import LiquidGlassEffect

// MARK: - Liquid Glass Button Wrapper for iOS Contest 2025
// Wraps standard buttons with liquid glass effect for attach menu, voice/video recording

public final class LiquidGlassButtonView: UIView {
    
    private let liquidGlassView: LiquidGlassEffectView
    private let contentContainerView: UIView
    
    public var glassRadius: CGFloat {
        get { return self.liquidGlassView.glassRadius }
        set { self.liquidGlassView.glassRadius = newValue }
    }
    
    public var glassCornerRadius: CGFloat {
        get { return self.liquidGlassView.glassCornerRadius }
        set { self.liquidGlassView.glassCornerRadius = newValue }
    }
    
    public var tintColor: UIColor {
        get { return self.liquidGlassView.tintColor }
        set { self.liquidGlassView.tintColor = newValue }
    }
    
    public override init(frame: CGRect) {
        self.liquidGlassView = LiquidGlassEffectView()
        self.contentContainerView = UIView()
        
        super.init(frame: frame)
        
        self.addSubview(self.liquidGlassView)
        self.addSubview(self.contentContainerView)
        
        self.contentContainerView.isUserInteractionEnabled = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.liquidGlassView.frame = self.bounds
        self.contentContainerView.frame = self.bounds
    }
    
    // Add a view as content (icon, text, etc.)
    public func addContent(_ view: UIView) {
        self.contentContainerView.addSubview(view)
    }
    
    // MARK: - Animation Methods
    
    public func animateTap(completion: (() -> Void)? = nil) {
        self.liquidGlassView.animatePressWithHighlight(scale: 0.90, completion: completion)
    }
    
    public func animatePress(isPressed: Bool) {
        if isPressed {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.liquidGlassView.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.liquidGlassView.transform = .identity
            })
        }
    }
    
    public func startRecordingAnimation() {
        // Pulse effect during recording
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.08
        pulseAnimation.duration = 0.8
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.liquidGlassView.layer.add(pulseAnimation, forKey: "recordingPulse")
    }
    
    public func stopRecordingAnimation() {
        self.liquidGlassView.layer.removeAnimation(forKey: "recordingPulse")
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.liquidGlassView.transform = .identity
        })
    }
}

// MARK: - Component Wrapper for ComponentFlow integration

public final class LiquidGlassButtonComponent: Component {
    public let size: CGSize
    public let cornerRadius: CGFloat
    public let tintColor: UIColor
    public let content: AnyComponent<Empty>?
    public let action: () -> Void
    
    public init(
        size: CGSize,
        cornerRadius: CGFloat,
        tintColor: UIColor = UIColor(white: 1.0, alpha: 0.15),
        content: AnyComponent<Empty>? = nil,
        action: @escaping () -> Void
    ) {
        self.size = size
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content
        self.action = action
    }
    
    public static func ==(lhs: LiquidGlassButtonComponent, rhs: LiquidGlassButtonComponent) -> Bool {
        if lhs.size != rhs.size {
            return false
        }
        if lhs.cornerRadius != rhs.cornerRadius {
            return false
        }
        if lhs.tintColor != rhs.tintColor {
            return false
        }
        return true
    }
    
    public final class View: UIView {
        private let buttonView: LiquidGlassButtonView
        private var contentView: ComponentView<Empty>?
        private var component: LiquidGlassButtonComponent?
        
        override public init(frame: CGRect) {
            self.buttonView = LiquidGlassButtonView()
            
            super.init(frame: frame)
            
            self.addSubview(self.buttonView)
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            self.addGestureRecognizer(tapRecognizer)
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func handleTap() {
            self.buttonView.animateTap { [weak self] in
                self?.component?.action()
            }
        }
        
        func update(component: LiquidGlassButtonComponent, availableSize: CGSize, transition: ComponentTransition) -> CGSize {
            self.component = component
            
            self.buttonView.glassCornerRadius = component.cornerRadius
            self.buttonView.tintColor = component.tintColor
            
            transition.setFrame(view: self.buttonView, frame: CGRect(origin: .zero, size: component.size))
            
            if let content = component.content {
                let contentView: ComponentView<Empty>
                if let current = self.contentView {
                    contentView = current
                } else {
                    contentView = ComponentView<Empty>()
                    self.contentView = contentView
                }
                
                let contentSize = contentView.update(
                    transition: transition,
                    component: content,
                    environment: {},
                    containerSize: component.size
                )
                
                if let view = contentView.view {
                    if view.superview == nil {
                        self.buttonView.addContent(view)
                    }
                    transition.setFrame(view: view, frame: CGRect(
                        origin: CGPoint(
                            x: (component.size.width - contentSize.width) / 2.0,
                            y: (component.size.height - contentSize.height) / 2.0
                        ),
                        size: contentSize
                    ))
                }
            }
            
            return component.size
        }
    }
    
    public func makeView() -> View {
        return View()
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, transition: transition)
    }
}
