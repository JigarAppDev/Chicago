//
//  UITableView+Extensions.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//

import Foundation
import UIKit

extension UITableView {
    
}

extension UITableViewCell {
    var tableView: UITableView? {
        var view = self.superview
        while (view != nil && view!.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as? UITableView
    }
}
