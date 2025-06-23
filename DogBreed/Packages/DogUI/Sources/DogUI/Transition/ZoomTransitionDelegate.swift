//
//  ZoomTransitionDelegate.swift
//  DogUIPackage
//
//  Created by Matej on 19. 6. 25.
//

import UIKit

// https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html

public final class ZoomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private let animator = Animator()
    
    public var sourceViewFrame: CGRect? {
        didSet {
            animator.originViewFrame = sourceViewFrame
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.type = .show
        return animator
    }

    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        animator.type = .hide
        return animator
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ShadowContainer(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - Animator

extension ZoomTransitionDelegate {
    
    final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

        // MARK: - Properties

        var type: `Type` = .show
        enum `Type` {
            case show
            case hide
        }
        
        fileprivate var originViewFrame: CGRect?
        
        private let transitionDuration: TimeInterval = 1

        // MARK: - UIViewControllerAnimatedTransitioning

        func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
            transitionDuration
        }
        
        func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
            switch type {
            case .show: animateShow(using: transitionContext)
            case .hide: animateHide(using: transitionContext)
            }
        }
    }
}

// MARK: - Animations

private extension ZoomTransitionDelegate.Animator {

    func animateShow(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            transitionContext.isAnimated,
            let destinationView = transitionContext.view(forKey: .to),
            let destinationSnapshotView = transitionContext.viewController(forKey: .to)?.view.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(true)
            return
        }

        // data
        let originalFrame = destinationView.frame

        // animation data - start
        destinationSnapshotView.alpha = 0
        destinationSnapshotView.frame = originViewFrame ?? .zero
        
        // view hierarchy
        transitionContext.containerView.addSubview(destinationSnapshotView)

        // animate
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut
        ) {
            // animation data - end
            destinationSnapshotView.alpha = 1
            destinationSnapshotView.frame = originalFrame
        }  completion: { isFinished in
            if isFinished {
                transitionContext.containerView.addSubview(destinationView)
                destinationSnapshotView.removeFromSuperview()

                transitionContext.completeTransition(true)
            }
        }
    }
    
    func animateHide(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            transitionContext.isAnimated,
            let originView = transitionContext.view(forKey: .from),
            let originSnapshotView = originView.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(true)
            return
        }

        transitionContext.containerView.addSubview(originSnapshotView)
        originView.removeFromSuperview()

        // animate
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            // animation data - end
            originSnapshotView.alpha = 0
            originSnapshotView.frame = self.originViewFrame ?? .zero
        }  completion: { isFinished in
            if isFinished {
                originSnapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}

// MARK: - Transition container

extension ZoomTransitionDelegate {
    
    final class ShadowContainer: UIPresentationController {
        
        private lazy var shadowView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .black
            view.alpha = 0
            return view
        }()

        override func presentationTransitionWillBegin() {
            super.presentationTransitionWillBegin()

            guard let containerView else { return }
            containerView.addSubview(shadowView)

            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: shadowView.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor)
            ])
            
            presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
                self?.shadowView.alpha = 0.5
            })
        }

        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.shadowView.alpha = 0
            }
        }
        
        override func presentationTransitionDidEnd(_ completed: Bool) {
            super.presentationTransitionDidEnd(completed)
            
            guard completed else { return }
            shadowView.removeFromSuperview()
        }
    }
}
