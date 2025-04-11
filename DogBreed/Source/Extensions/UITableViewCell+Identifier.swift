//
//  UITableViewCell+Identifier.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

extension UITableViewCell {

    class var identifier: String { String(describing: "\(self)") }

}
