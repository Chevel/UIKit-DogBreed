//
//  GradientView.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

final public class GradientView: UIView {
    
    // MARK: - UI
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return gradientLayer
    }()
    
    // MARK: - Init

    public init() {
        super.init(frame: .zero)
        
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.removeFromSuperlayer()
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
