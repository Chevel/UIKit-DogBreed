//
//  BreedPictureCollectionViewCell.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit
import DogUIComponents

final class BreedPictureCollectionViewCell: UICollectionViewCell {

    @MainActor protocol Delegate: AnyObject {
        func toggleFavourite(cell: BreedPictureCollectionViewCell)
    }
 
    // MARK: - Delegate
    
    weak var delegate: Delegate?
    
    // MARK: - UI
    
    private var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = .black
        return view
    }()

    private var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        imageView.image = .placeholder
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var favouriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        return button
    }()

    private var imageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageTask: Task<(), Never>?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = .placeholder
        photoImageView.contentMode = .scaleAspectFill

        loader.startAnimating()
        favouriteButton.setImage(.favouriteEmpty, for: .normal)
        imageLabel.text = nil

        imageTask?.cancel()
        imageTask = nil
    }
    
    @objc private func toggleFavourite() {
        delegate?.toggleFavourite(cell: self)
    }
    
    // MARK: - Interface
    
    func set(mode: Mode, data: ImageData, delegate: Delegate?) {
        self.delegate = delegate

        imageTask = Task {
            let image = await ImageCache.shared.image(at: data.url)

            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                if let image {
                    self?.photoImageView.image = image
                } else {
                    self?.photoImageView.image = .warning
                    self?.photoImageView.contentMode = .scaleAspectFit
                }
                self?.loader.stopAnimating()
            }
        }

        favouriteButton.isHidden = mode.isFavouriteButtonHidden
        imageLabel.isHidden = mode.isImageDescriptionHidden
        gradientView.isHidden = mode.isImageDescriptionHidden
        
        imageLabel.text = data.name

        if !mode.isFavouriteButtonHidden {
            let isFavourite = FavouritesManager.isFavourite(imageUrl: data.url)
            favouriteButton.setImage(isFavourite ? .favouriteFull : .favouriteEmpty, for: .normal)
        }
    }

    // MARK: - Helper

    private func setup() {
        guard photoImageView.superview == nil else { return }

        contentView.addSubview(photoImageView)
        contentView.addSubview(loader)
        contentView.addSubview(favouriteButton)
        contentView.addSubview(gradientView)
        contentView.addSubview(imageLabel)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: contentView.frame.height/2),
            
            imageLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            imageLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            imageLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor),
            imageLabel.heightAnchor.constraint(equalToConstant: 50),

            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            favouriteButton.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: 4),
            favouriteButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -4),
            favouriteButton.widthAnchor.constraint(equalToConstant: 40),
            favouriteButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        favouriteButton.addTarget(self, action: #selector(toggleFavourite), for: .touchUpInside)
        loader.startAnimating()
    }
}

// MARK: - Mode

extension BreedPictureCollectionViewCell {
    
    struct ImageData {
        let name: String
        let url: URL
    }

    enum Mode {
        case display(delegate: Delegate)
        case favourite
        
        var isFavouriteButtonHidden: Bool {
            switch self {
            case .display: return false
            case .favourite: return true
            }
        }
        
        var isImageDescriptionHidden: Bool {
            return !isFavouriteButtonHidden
        }
    }
}
