//
//  UserDefaults+Extensions.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//  Copyright © 2019 Permnt. All rights reserved.
//

import UIKit
import Foundation

extension UserDefaults {
    
    func setCustomObjToUserDefaults(CustomeObj: AnyObject, forKey:String) {
        
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: CustomeObj)
        defaults.set(encodedData, forKey: forKey)
        defaults.synchronize()
    }
    
    func getCustomObjFromUserDefaults(forKey:String) -> AnyObject? {
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: forKey) != nil {
            if let decoded  = defaults.object(forKey: forKey) as? Data {
                let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with:decoded) as AnyObject
                return decodedTeams
            }
        }
        return nil
    }
    
    func setJsonObject<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func getJsonObject<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
    
    func setStructArray<T: Codable>(_ value: [T], forKey defaultName: String){
        let data = value.map { try? JSONEncoder().encode($0) }
        
        set(data, forKey: defaultName)
    }
    
    func getstructArray<T>(_ type: T.Type, forKey defaultName: String) -> [T] where T : Decodable {
        guard let encodedData = array(forKey: defaultName) as? [Data] else {
            return []
        }
        
        return encodedData.map { try! JSONDecoder().decode(type, from: $0) }
    }
    
    func removeCustomObject(forKey:String)
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: forKey)
        defaults.synchronize()
    }
    
    //MARK: Save Header Token
    func setHeaderToken(value: String){
        set(value, forKey: ETOKEN)
        //synchronize()
    }
    
    //MARK: Retrieve Header Data
    func getHeaderToken() -> String?{
        return string(forKey: ETOKEN)
    }
    
    //MARK: Save Header Token
    func removeHeaderToken() {
        removeObject(forKey: ETOKEN)
        //synchronize()
    }

}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    
    func jsonToData(json: [String: AnyObject]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json as? Dictionary ?? Dictionary(), options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch _ {
            return nil
        }
    }

}
