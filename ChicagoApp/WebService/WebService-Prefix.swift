//
//  WebService-Prefix.swift
//  REN
//
//  Created by Nikul on 27/05/19.
//  Copyright © 2019 AppDook. All rights reserved.
//

import Foundation

struct APIErrorLogConstants {
    static let NoInternet = "ParentNetwork requires a network connection to work properly.  Please check your WiFi or internet connection."
    static let SomethingWrong = "Something went wrong. Please try after some time."
    static let NoResult = "No results found!"
    static let ServerDown = "ParentNetwork server is not responding.Please try after some time"
}

struct APISuccessLogConstant {
    static let ProfileUpdate = "Profile update Suceessfully."
    static let DeleteActivity = "Activity deleted Suceessfully."
    static let UnjoinActivity = "Activity Unjoin Suceessfully."
}

struct APIServerConstants {
    static let BaseURL = "http://178.128.236.91/chicago_api/"
}

struct APIConstants {
    static let LOGIN = "\(APIServerConstants.BaseURL)login"
    static let SIGNUP = "\(APIServerConstants.BaseURL)signup"
    static let FORGOTPWD = "\(APIServerConstants.BaseURL)forgot_password"
    static let RESETPWD = "\(APIServerConstants.BaseURL)reset_password"
    static let GetCategory = "\(APIServerConstants.BaseURL)get_category"
    static let GetCategoryDetails = "\(APIServerConstants.BaseURL)get_profile"
    static let LoginByThirdParty = "\(APIServerConstants.BaseURL)login_by_thirdparty"
    static let ADDSHOP = "\(APIServerConstants.BaseURL)add_shop_detail"
}


