//
//  DogUI.BreedPicture.Details.swift
//  DogUIPackage
//
//  Created by Matej on 19. 6. 25.
//

import UIKit

public extension DogUI.BreedPicture {

    final class DetailViewController: UIViewController {
        
        // MARK: - Properties
        
        private lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        private lazy var closeButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.tintColor = .white
            button.addTarget(self, action: #selector(close), for: .touchUpInside)
            return button
        }()
        
        // MARK: - Init
        
        public init(image: UIImage) {
            super.init(nibName: nil, bundle: nil)
            self.imageView.image = image
            setupSubviews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewIsAppearing(_ animated: Bool) {
            super.viewIsAppearing(animated)
            setup()
        }
    }
}

private extension DogUI.BreedPicture.DetailViewController {
    
    func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black
    }

    func setupSubviews() {
        view.addSubview(imageView)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            view.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            view.heightAnchor.constraint(equalTo: imageView.heightAnchor),
            
            view.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: closeButton.topAnchor, constant: -8),
            
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

private extension DogUI.BreedPicture.DetailViewController {
    
    @objc
    func close() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
