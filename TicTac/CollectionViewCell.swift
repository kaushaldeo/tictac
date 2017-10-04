//
//  CollectionViewCell.swift
//  TicTac
//
//  Created by Kaushal Deo on 10/3/17.
//  Copyright © 2017 Scorpion Inc. All rights reserved.
//

import UIKit

enum Player : String {
    case one = "one"
    case two = "two"
    case none = "none"
}

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView : UIImageView!
    
    var player : Player = .none {
        didSet {
            switch self.player {
            case .one:
                self.imageView.image = UIImage(named: "cross")
            case .two:
                self.imageView.image = UIImage(named: "circle")
            default:
                self.imageView.image = nil
            }
        }
    }
}


struct Move : Codable {
    let index : Int
    let name : String
    
    
    init(_ move:Int) {
        self.name = UIDevice.current.name
        self.index = move
    }
}
