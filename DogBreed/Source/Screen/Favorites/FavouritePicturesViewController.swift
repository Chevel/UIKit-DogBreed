//
//  FavouritePicturesViewController.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit
import Combine

final class FavouritePicturesViewController: UIViewController, BreedPictureCellDisplayable {

    // MARK: - Data

    private let viewModel = FavouritePicturesViewModel()
    private var subscriberTokens = Set<AnyCancellable>()

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.register(BreedPictureCollectionViewCell.self, forCellWithReuseIdentifier: BreedPictureCollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        return collectionView
    }()
    
    private var layout: UICollectionViewFlowLayout {
        let padding: CGFloat = 8
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        layout.itemSize = CGSize(width: (view.frame.width/2) - padding/2, height: (view.frame.height/3) - padding/2)
        return layout
    }

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
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
        setupFilterMenu()
    }
    
    // MARK: - Helper

    private func setupUI() {
        title = "favourites_screen_title".translated()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupFilterMenu() {
        var children = viewModel.breeds.map { breed in
            UIAction(title: breed, handler: { [weak self] action in
                switch action.state {
                case .on: self?.viewModel.activeFilter = .none
                case .mixed, .off: self?.viewModel.activeFilter = .breed(value: breed)
                @unknown default: self?.viewModel.activeFilter = .breed(value: breed)
                }
            })
        }.sorted { $0.title < $1.title }
        children.append(UIAction(title: "favourites_filter_menu_option_close".translated()) { _ in })
        
        let button = UIButton()
        button.setImage(viewModel.activeFilter.isActive ? UIImage.filterActiveIcon : UIImage.filterInactiveIcon, for: .normal)
        button.menu = UIMenu(title: "favourites_filter_menu_title".translated(), options: .displayInline, children: children)
        button.showsMenuAsPrimaryAction = true
        button.addAction(UIAction(title: "") { [weak self] _ in
            button.menu?.children.forEach({ action in
                if let action = action as? UIAction {
                    action.state = action.title == self?.viewModel.activeFilter.filterBreed ? .on : .off
                }
            })
        }, for: .menuActionTriggered)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupBindings() {
        viewModel.$displayedData
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink() { _ in
                self.collectionView.reloadData()
            }.store(in: &subscriberTokens)
    }

}

// MARK: - UICollectionViewDataSource

extension FavouritePicturesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayedData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let imageUrl = viewModel.displayedData[safe: indexPath.row]
        else { return UICollectionViewCell() }

        let cell = dequeueBreedPictureCell(for: collectionView, at: indexPath)
        cell.set(mode: .favourite, data: .init(name: imageUrl.breed, url: imageUrl), delegate: nil)
        return cell
    }

}
