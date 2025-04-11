//
//  BreedPictureCollectionViewCell.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

protocol BreedPictureCollectionViewCellDelegate: AnyObject {
    func toggleFavourite(cell: BreedPictureCollectionViewCell)
}

final class BreedPictureCollectionViewCell: UICollectionViewCell {
 
    // MARK: - Delegate
    
    weak var delegate: BreedPictureCollectionViewCellDelegate?
    
    // MARK: - UI
    
    private var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
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
        
        photoImageView.image = nil
        loader.stopAnimating()
        favouriteButton.setImage(.favouriteEmpty, for: .normal)
        imageLabel.text = nil
    }
    
    @objc private func toggleFavourite() {
        delegate?.toggleFavourite(cell: self)
    }
    
    // MARK: - Interface
    
    func set(mode: Mode) {
        self.delegate = mode.delegate
        favouriteButton.isHidden = true

        load(imageURL: mode.imageURL, mode: mode)

        imageLabel.isHidden = mode.isImageDescriptionHidden
        imageLabel.text = mode.imageURL.breed
        gradientView.isHidden = mode.isImageDescriptionHidden
        
        if !mode.isFavouriteButtonHidden {
            let isFavourite = FavouritesManager.isFavourite(imageUrl: mode.imageURL)
            favouriteButton.setImage(isFavourite ? .favouriteFull : .favouriteEmpty, for: .normal)
        }
    }

    // MARK: - Helper

    private func load(imageURL: URL, mode: Mode) {
        Task(priority: .background) {
            photoImageView.image = try? await ImageCache.shared.image(at: imageURL)
            favouriteButton.isHidden = mode.isFavouriteButtonHidden
            loader.stopAnimating()
        }
    }

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
    
    enum Mode {
        case display(imageURL: URL, delegate: BreedPictureCollectionViewCellDelegate)
        case favourite(imageURL: URL)
        
        var imageURL: URL {
            switch self {
            case .display(let imageURL, _), .favourite(let imageURL): return imageURL
            }
        }
        
        var isFavouriteButtonHidden: Bool {
            switch self {
            case .display: return false
            case .favourite: return true
            }
        }
        
        var isImageDescriptionHidden: Bool {
            return !isFavouriteButtonHidden
        }
        
        var delegate: BreedPictureCollectionViewCellDelegate? {
            switch self {
            case .display(_, let delegate): return delegate
            case .favourite(_): return nil
            }
        }
    }
    
}
