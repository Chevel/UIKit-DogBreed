//
//  BreedPicturesViewController.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogUI
import UIKit
import Combine
import DogCore
import DogData
import DogBreedContainer

final class BreedPicturesViewController: UIViewController, BreedPictureCellDisplayable {

    // MARK: - Properties

    private let viewModel: BreedPicturesViewModel
    private var subscriberTokens = Set<AnyCancellable>()
    private enum Section: Int {
        case breeds

        var columns: Int { 2 }
        @MainActor var heightDimension: NSCollectionLayoutDimension { NSCollectionLayoutDimension.fractionalWidth(1) }
        @MainActor var widthDimension: NSCollectionLayoutDimension { NSCollectionLayoutDimension.fractionalWidth(1) }
        var insets: NSDirectionalEdgeInsets { .zero }
    }
    
    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DogUI.BreedPicture.CollectionViewCell.self, forCellWithReuseIdentifier: DogUI.BreedPicture.CollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        return collectionView
    }()
    
    private var layout: UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {( sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: section.widthDimension, heightDimension: section.heightDimension)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: section.columns)
            
            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.contentInsets = section.insets
            return layoutSection
        }
    }
    
    private let detailsTransitionDelegate = ZoomTransitionDelegate()

    // MARK: - Init

    init(breedName: String, dependencies: Dependencies) {
        viewModel = BreedPicturesViewModel(breed: Breed(name: breedName), dogService: dependencies.networkService)
        super.init(nibName: nil, bundle: nil)
        title = breedName
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoder")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }
        
    // MARK: - Helper
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$imagesUrls
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink() { _ in
                self.collectionView.reloadData()
            }.store(in: &subscriberTokens)
    }
}

// MARK: - UICollectionViewDataSource

extension BreedPicturesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imagesUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let breedName = viewModel.breedName(for: indexPath),
            let imageUrl = viewModel.imagesUrls[safe: indexPath.row]
        else { return UICollectionViewCell() }

        let cell = dequeueBreedPictureCell(for: collectionView, at: indexPath)
    
        cell.set(
            mode: .display(delegate: self),
            data: .init(name: breedName, url: imageUrl),
            delegate: self
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            guard
                let imageUrl = viewModel.imagesUrls[safe: indexPath.row],
                let image = await ImageCache.shared.image(at: imageUrl)
            else { return }

            await MainActor.run {
                let vc = DogUI.BreedPicture.DetailViewController(image: image)
                
                if #available(iOS 18.0, *) {
                    vc.preferredTransition = .zoom(sourceViewProvider: { _ in
                        collectionView.cellForItem(at: indexPath)
                    })
                    show(vc, sender: self)
                } else {
                    let cell = collectionView.cellForItem(at: indexPath)!
                    let cellFrameInGlobalCoordinateSpace = cell.convert(cell.frame, to: view)
                    detailsTransitionDelegate.sourceViewFrame = cellFrameInGlobalCoordinateSpace
                    
                    vc.modalPresentationStyle = .custom
                    vc.transitioningDelegate = detailsTransitionDelegate
                    present(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension BreedPicturesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            cell.alpha = 1
        }
        
        animator.startAnimation(afterDelay: 0.005 * Double(indexPath.row))
    }
}

// MARK: - BreedPictureCollectionViewCellDelegate

extension BreedPicturesViewController: DogUI.BreedPicture.CollectionViewCell.Delegate {
    
    func toggleFavourite(cell: DogUI.BreedPicture.CollectionViewCell) {
        guard
            let path = collectionView.indexPath(for: cell),
            let imageUrl = viewModel.imagesUrls[safe: path.row]
        else {
            return
        }

        viewModel.markAsFavourite(imageURL: imageUrl)
        collectionView.reloadItems(at: [path])
    }
}
