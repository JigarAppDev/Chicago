//
//  HomeViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 11/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainCatCell: UITableViewCell {
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblName: UILabel!
}

class HomeViewController: UIViewController {

    @IBOutlet var tblMainCat: UITableView!
    @IBOutlet var btnLoginNow: UIButton!
    @IBOutlet var btnAddShop: UIButton!
    var arrMainCategory = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.btnLoginNow.isHidden = false
        if let _ = Defaults.value(forKey: "userDetail") {
            //LoggedIn
            self.btnLoginNow.isHidden = true
        }
        self.getAllMainCategory()
    }
    
    //MARK: Main Category API Call
    private func getAllMainCategory() {
        
        let Url = String(format: APIConstants.GetCategory)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "parent_category=0"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let dataObj = json as! NSDictionary
                    if dataObj.value(forKey: "status_code") as! Bool == true {
                        print(dataObj)
                    }
                    let dataObj1 = JSON.init(json)
                    if dataObj1["status_code"].boolValue == true {
                        self.arrMainCategory.removeAll()
                        self.arrMainCategory = dataObj1["info"].arrayValue
                    }
                    DispatchQueue.main.async {
                        self.tblMainCat.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: ADD New shop
    @IBAction func btnAddShopClick(sender: UIButton) {
        if let _ = Defaults.value(forKey: "userDetail") {
            let addVC = self.storyboard?.instantiateViewController(identifier: "AddShopViewController") as! AddShopViewController
            self.navigationController?.pushViewController(addVC, animated: true)
        } else {
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    //MARK: TV Click
    @IBAction func btnTVClick(sender: UIButton) {
        if let webURL = URL(string: "https://www.chicagocallsheet.com/"), UIApplication.shared.canOpenURL(webURL)
        {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Get Liked Data
    @IBAction func btnLikeClick(sender: UIButton) {
        let likeVC = self.storyboard?.instantiateViewController(identifier: "LikedCategoryViewController") as! LikedCategoryViewController
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMainCategory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblMainCat.dequeueReusableCell(withIdentifier: "MainCatCell") as! MainCatCell
        let obj = self.arrMainCategory[indexPath.row]
        cell.lblName.text = obj["category_name"].stringValue
        cell.imgIcon.image = UIImage.init(named: obj["category_name"].stringValue)
        if obj["category_name"].stringValue == "Film Office/Union Halls" {
            cell.imgIcon.image = UIImage.init(named: "Film OfficeUnion Halls")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.arrMainCategory[indexPath.row]
        if obj["category_id"].intValue == 4 {
            let locationVC = self.storyboard?.instantiateViewController(identifier: "LocationListViewController") as! LocationListViewController
            locationVC.selectedObj = obj
            self.navigationController?.pushViewController(locationVC, animated: true)
        } else {
            let subCatVC = self.storyboard?.instantiateViewController(identifier: "CategoryViewController") as! CategoryViewController
            subCatVC.selectedObj = obj
            self.navigationController?.pushViewController(subCatVC, animated: true)
        }
    }
}
