//
//  Int+Extensions.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//

import Foundation
import UIKit

extension Int {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    } ()
    
    
    var stringValue: String {  return "\(self)" }
    
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K")]//,(100_000.0, 1_000_000.0, "M"),(100_000_000.0, 1_000_000_000.0, "B")
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = false
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 0
        
        return numFormatter.string(from: NSNumber (value:value)) ?? String (format: "%d", self)
    }
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencyCode = "USD"
        numberFormatter.currencySymbol = "$"
        let string = numberFormatter.string(from: NSNumber(value:self))!
        return string.replacingOccurrences(of: ".00", with: "").replacingOccurrences(of: " ", with: "")
    }
}
