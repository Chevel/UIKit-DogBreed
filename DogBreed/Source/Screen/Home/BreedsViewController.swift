//
//  BreedsViewController.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit
import Combine

final class BreedsViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = 50
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.register(BreedTableViewCell.self, forCellReuseIdentifier: BreedTableViewCell.identifier)
        return view
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .black
        loader.hidesWhenStopped = true
        return loader
    }()

    // MARK: - Data

    private var subscriberTokens = Set<AnyCancellable>()
    private var viewModel = BreedsViewModel()
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Breed> = {
        return UITableViewDiffableDataSource<Section, Breed>(tableView: tableView) { [weak self]
            (tableView: UITableView, indexPath: IndexPath, item: Breed) -> UITableViewCell? in
            
            guard let name = self?.viewModel.breeds?[safe: indexPath.row]?.name else {
                return UITableViewCell()
            }
            let breedCell = Self.dequeueBreedCell(for: tableView, at: indexPath)
            breedCell.set(text: name)
            return breedCell
        }
    }()
    private enum Section {
        case breeds
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupBindings()
    }
    
    // MARK: - Helper
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(loader)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        loader.startAnimating()
    }
    
    private func setupFavouritesButtonIfNeeded() {
        guard navigationItem.rightBarButtonItem == nil else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "home_favourites_button_title".translated(),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(favoritesPressed))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
    }
    
    private func setupBindings() {
        viewModel.$breeds
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink() {
                self.loader.stopAnimating()
                self.setupFavouritesButtonIfNeeded()
                
                guard let newData = $0 else { return }
                var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Breed>()
                initialSnapshot.appendSections([.breeds])
                initialSnapshot.appendItems(newData)
                self.dataSource.apply(initialSnapshot, animatingDifferences: false)
            }.store(in: &subscriberTokens)
    }
    
    // MARK: - Action

    @objc private func favoritesPressed() {
        present(UINavigationController(rootViewController: FavouritePicturesViewController()), animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension BreedsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let breed = viewModel.breeds?[safe: indexPath.row] else {
            return
        }
        navigationController?.pushViewController(BreedPicturesViewController(breedName: breed.name), animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            cell.transform = .identity
        }
        
        animator.startAnimation(afterDelay: 0.005 * Double(indexPath.row))
    }

}

// MARK: - Cell

private extension BreedsViewController {
    
    static func dequeueBreedCell(for tableView: UITableView, at indexPath: IndexPath) -> BreedTableViewCell {
        guard let breedCell = tableView.dequeueReusableCell(withIdentifier: BreedTableViewCell.identifier) as? BreedTableViewCell
        else {
            fatalError("⛔️ Error in \(#file) at \(#line) - \(BreedTableViewCell.self) is not registered on \(self).")
        }
        return breedCell
    }
    
}


