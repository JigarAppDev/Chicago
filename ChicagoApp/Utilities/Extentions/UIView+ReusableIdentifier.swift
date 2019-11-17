//
//  UIView+ReusableIdentifier.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//  Copyright © 2019 Permnt. All rights reserved.
//

import UIKit

protocol ReuseIdentifier {
  
  static var reuseIdentifier: String { get }
  
}

extension ReuseIdentifier {
  
  /// Return a suggested name that can be used as an cellIdentifier.
  static var reuseIdentifier: String {
    return String(describing: self)
  }
  
}

extension UICollectionViewCell: ReuseIdentifier {}
extension UITableViewCell: ReuseIdentifier {}
extension UITableViewHeaderFooterView: ReuseIdentifier {}
