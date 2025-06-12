//
//  BreedTableViewCell.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

public extension DogUI.Breeds {
    
    final class TableViewCell: UITableViewCell {
        
        // MARK: - Properties
        
        private var displayLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .black
            return label
        }()
        
        // MARK: - Init
        
        public override func awakeFromNib() {
            assertionFailure("Storyboards are not supported")
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        // MARK: - Lifecycle
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            
            displayLabel.text = nil
        }
        
        // MARK: - Helper

        private func setup() {
            guard displayLabel.superview == nil else { return }
            
            contentView.addSubview(displayLabel)
            
            NSLayoutConstraint.activate([
                displayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                displayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                displayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                displayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            selectionStyle = .none
        }
        
        // MARK: - Interface
        
        public func set(text: String) {
            displayLabel.text = text
        }
    }
}
