//
//  Array+Extensions.swift
//  Permnt
//
//  Created by Harry on 31/08/19.
//  Copyright © 2019 Permnt. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
