//
//  CategoryViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 11/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubCatCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
}

class CategoryViewController: UIViewController {

    @IBOutlet var tblSubCat: UITableView!
    @IBOutlet var lblTitle: UILabel!
    var selectedObj: JSON!
    var categoryArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTitle.text = self.selectedObj["category_name"].stringValue
        self.getAllCategory()
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Category API Call
    private func getAllCategory() {
        
        let Url = String(format: APIConstants.GetCategory)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "parent_category=\(self.selectedObj["category_id"])"
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
                        self.categoryArray.removeAll()
                        self.categoryArray = dataObj1["info"].arrayValue
                    }
                    DispatchQueue.main.async {
                        self.tblSubCat.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
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

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblSubCat.dequeueReusableCell(withIdentifier: "SubCatCell") as! SubCatCell
        let obj = self.categoryArray[indexPath.row]
        cell.lblName.text = obj["category_name"].stringValue
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationVC = self.storyboard?.instantiateViewController(identifier: "LocationListViewController") as! LocationListViewController
        locationVC.selectedObj = self.categoryArray[indexPath.row]
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
}

