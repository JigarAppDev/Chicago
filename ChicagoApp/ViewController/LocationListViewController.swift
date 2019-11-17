//
//  LocationListViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 11/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON

class LocationCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
}

class LocationListViewController: UIViewController {

    @IBOutlet var tblLocation: UITableView!
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
        
        let Url = String(format: APIConstants.GetCategoryDetails)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "category_id=\(self.selectedObj["category_id"])"
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
                        self.tblLocation.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblLocation.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        let obj = self.categoryArray[indexPath.row]
        cell.lblName.text = obj["Company_name"].stringValue
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = self.storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let obj = self.categoryArray[indexPath.row]
        detailsVC.selectedObj = obj
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}

