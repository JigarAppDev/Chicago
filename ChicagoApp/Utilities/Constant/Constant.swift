//
//  Constant.swift
//  Eshtreli
//
//  Created by Nikul on 26/09/19.
//  Copyright © 2019 MyMac. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Size {
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
}

let APPName = "Chicago"
let EUSER = "UserInfo"
let ETOKEN = "UserToken"

let Loadersize = CGSize(width: 40, height: 40)
var ToastDuration:TimeInterval = 2.0
let Defaults = UserDefaults.standard
var userData : JSON = []

struct ValidationMessage {
    static let Username = "Please enter username"
    static let Email = "Please enter email"
    static let ValidEmail = "Please enter valid email"
    static let Password = "Please enter password"
    static let NotMatchPassword = "Password not match"
    static let Phone = "Please enter phone number"
    static let City = "Please enter city"
    static let Address = "Please enter address"
}

func getUserDetail() -> JSON {
    guard let userDetail = UserDefaults.standard.value(forKey: "userDetail") as? Data else { return JSON.init() }
    let data = JSON(userDetail)
    userData = data
    print(data)
    return data
}
