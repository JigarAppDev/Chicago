//
//  Date+Extensions.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//  Copyright © 2019 CarBlip. All rights reserved.
//

import Foundation

let defaultDateFormat = "0000-00-00 00:00:00"

public extension Date {
    
    // returns if a date is over 18 years ago
    func isOver18Years() -> Bool {
        var comp = (Calendar.current as NSCalendar).components(NSCalendar.Unit.month.union(.day).union(.year), from: Date())
        guard comp.year != nil && comp.day != nil else { return false }
        
        comp.year! -= 18
        comp.day! += 1
        if let date = Calendar.current.date(from: comp) {
            if self.compare(date) != ComparisonResult.orderedAscending {
                return false
            }
        }
        return true
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func localToUTC(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dt!)
    }
    
    func dateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

public func stringToDate(_ str: String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss"
    var mainString = String()
    mainString = str
    if mainString.count > 20 {
        mainString = String(mainString.prefix(19))
    }
    return formatter.date(from: mainString)!
}

public func timeAgo(for date: Date?) -> String? {
    
    let units:Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    var components: DateComponents? = nil
    if let aDate = date {
        components = Calendar.current.dateComponents(units, from: aDate, to: Date())//dateComponents(units, from: aDate, to: Date(), options: [])
    }
    if (components?.year ?? 0) > 0 {
        return date?.toString(format: "yyyy-MM-dd")
    } else if (components?.month ?? 0) > 0 {
        return date?.toString(format: "MM-dd HH:mm")
    } else if (components?.weekOfYear ?? 0) > 0 {
        return date?.toString(format: "MM-dd HH:mm")
    } else if (components?.day ?? 0) > 0 {
        return date?.toString(format: "MM-dd HH:mm")
    } else if (components?.hour ?? 0 >= 1) {
        return date?.toString(format: "HH:mm")
    } else if (components?.minute ?? 0 >= 1) {
        return "\(Int(components?.minute ?? 0)) m ago"
    } else if (components?.second ?? 0 >= 10) {
        return "\(Int(components?.second ?? 0)) s ago"
    } else {
        return "Just now"
    }
}

extension String {
    
    func age(birthday: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd" //Your date format
        dateFormatter.timeZone = TimeZone.current //Current time zone
        guard let date = dateFormatter.date(from: birthday) else {
            return "0"
        }
        
        let now = Date()
        let birthdayDate: Date = date
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: birthdayDate, to: now)
        let age = ageComponents.year
        return age?.stringValue ?? "0"
        
    }
    
}
