//
//  VHttpRequestManager.swift
//  REN
//
//  Created by Nikul on 27/05/19.
//  Copyright © 2019 AppDook. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//Encoding Type
let URL_ENCODING = URLEncoding.default
let JSON_ENCODING = JSONEncoding.default
let appDelegate = UIApplication.shared.delegate as! AppDelegate

protocol UploadProgressDelegate
{
    func didReceivedProgress(progress:Float)
}

protocol DownloadProgressDelegate
{
    func didReceivedDownloadProgress(progress:Float,filename:String)
    func didFailedDownload(filename:String)
}

class HttpRequestManager
{
    static let shared = HttpRequestManager()
    var additionalHeader = ["User-Agent": "iOS"]//"token": UserManager.shared.accessToken ?? "gfdfdsfdf"
    var alamoFireManager = Alamofire.SessionManager.default
    var uploadDelegate : UploadProgressDelegate?
    var downloadDelegate : DownloadProgressDelegate?
    
    // METHODS
    init()
    {
        alamoFireManager.session.configuration.timeoutIntervalForRequest = 120 //seconds
        alamoFireManager.session.configuration.httpAdditionalHeaders = additionalHeader
    }
    
    //MARK:- POST Request
    func postJSONRequest(endpointurl:String, parameters:[String:Any], encodingType:ParameterEncoding = JSONEncoding.default, responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        
        additionalHeader = ["":""] //["User-Agent": "iOS", "Authorization": "Bearer \(appDelegate.userToken ?? "")" ]
        
        alamoFireManager.request(endpointurl, method: .post, parameters: parameters, encoding: encodingType, headers: nil).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)
            if let _ = response.result.error {
                responseData(nil, response.result.error as NSError?,APIErrorLogConstants.SomethingWrong)
            }else {
                switch(response.result) {
                case .success(_):
                    var message = APIErrorLogConstants.SomethingWrong
                    if let data = response.result.value {
                        if JSON(data)["msg"].stringValue.isValid() {
                            message = JSON(data)["msg"].stringValue
                        }
                        responseData(data as AnyObject, nil, message)
                    }else {
                        responseData(nil, response.result.error as NSError?, APIErrorLogConstants.NoResult)
                    }
                    break
                case .failure(_):
                    responseData(nil, response.result.error as NSError?, APIErrorLogConstants.ServerDown)
                    break
                    
                }
            }
        }
    }
    
    func postMultiPartRequest(endpointurl:String, parameters:[String:Any], responseData:@escaping (_ data: AnyObject?,_ error: NSError?, _ message: String?) -> Void)
    {
        
        ShowNetworkIndicator(xx: true)
        alamoFireManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                if let image = value as? UIImage, let imageData = image.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(imageData, withName: "profile_photo", fileName: "Profile.png", mimeType: "image/png")
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
            }
        }, to:endpointurl)
        { (result) in
            switch result {
            case .success(let request, _,_ ):
                request.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                
                request.responseJSON { response in
                    ShowNetworkIndicator(xx: false)
                    var message = APIErrorLogConstants.SomethingWrong
                    if let data = response.result.value {
                        if JSON(data)["message"].stringValue.isValid() {
                            message = JSON(data)["message"].stringValue
                        }
                        responseData(data as AnyObject, nil, message)
                    }else {
                        responseData(nil, response.result.error as NSError?, message)
                    }
                }
                break
            case .failure(let error):
                ShowNetworkIndicator(xx: false)
                responseData(nil, error as NSError?, APIErrorLogConstants.ServerDown)
                break
            }
        }
    }
    
    //MARK:- GET Request
    func getRequestWithoutParams(endpointurl:String,responseData:@escaping (_ data:AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        alamoFireManager.request(endpointurl, method: .get, headers: additionalHeader).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)
            if let _ = response.result.error {
                responseData(nil, response.result.error as NSError?,APIErrorLogConstants.SomethingWrong)
            }else{
                switch(response.result){
                case .success(_):
                    if let data = response.result.value {
                        responseData(data as AnyObject, nil, nil)
                    }else {
                        responseData(nil, response.result.error as NSError?, APIErrorLogConstants.NoResult)
                    }
                    break
                case .failure(_):
                    responseData(nil, response.result.error as NSError?, APIErrorLogConstants.ServerDown)
                    break
                }
            }
        }
    }
    
    //MARK:- GET Request With Parameter
    func getRequestWithParams(endpointurl:String, parameters:[String:Any], encodingType:ParameterEncoding = JSONEncoding.default ,responseData:@escaping (_ data:AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        alamoFireManager.request(endpointurl, method: .get, parameters: parameters, encoding: encodingType, headers: additionalHeader).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)
            if let _ = response.result.error {
                responseData(nil, response.result.error as NSError?,APIErrorLogConstants.SomethingWrong)
            }else {
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        responseData(data as AnyObject, nil, nil)
                    }else {
                        responseData(nil, response.result.error as NSError?, APIErrorLogConstants.NoResult)
                    }
                    break
                case .failure(_):
                    responseData(nil, response.result.error as NSError?, APIErrorLogConstants.ServerDown)
                    break
                    
                }
            }
        }
    }

    //MARK:- Cancel Request
    func cancelAllAlamofireRequests(responseData:@escaping ( _ status: Bool?) -> Void)
    {
       alamoFireManager.session.getTasksWithCompletionHandler
            {
                dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() } 
                downloadTasks.forEach { $0.cancel() }
                responseData(true)
        }
    }
}

public func ShowNetworkIndicator(xx :Bool)
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = xx
}

public func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
        }.resume()
}

