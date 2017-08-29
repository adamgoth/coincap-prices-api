//
//  ViewController.swift
//  coincapAPI
//
//  Created by Adam Goth on 8/27/17.
//  Copyright © 2017 Adam Goth. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var coins = [[String: String]]()
    var initialLoad = true
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let tableRefreshControl = UIRefreshControl()
    
    //UI colors
    let colorOlive = UIColor(red: 119/255, green: 171/255, blue: 65/255, alpha: 0.1)
    let colorLightGreen = UIColor(red: 160/255, green: 204/255, blue: 99/255, alpha: 0.1)
    let colorSlateGray = UIColor(red: 50/255, green: 100/255, blue: 117/255, alpha: 0.1)
    let colorDefault = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 0.3)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoinCap.io Prices"

        //create activity indicator for initial load
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.darkGray
        view.addSubview(activityIndicator)
        
        //create refresh control for swipe down
        tableView.refreshControl = tableRefreshControl
        tableRefreshControl.addTarget(self, action: #selector(backgroundFetchJSON), for: .valueChanged)
        let fetchingStringAttributes : [String : Any] = [NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 12.0)!]
        tableRefreshControl.attributedTitle = NSAttributedString(string: "Fetching Price Data...", attributes: fetchingStringAttributes)
        
        //customize navbar
        //navigationController?.navigationBar.barTintColor = colorLightGreen
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        imageView.contentMode = .scaleAspectFit
        let logo = UIImage(named: "coincaplogo.png")
        imageView.image = logo
        self.navigationItem.titleView = imageView
        
        tableView.separatorStyle = .none
        
        //fetch prices in the background
        backgroundFetchJSON()
    }
    
    func fetchJSON() {
        let urlString = "http://www.coincap.io/front"
        
        if initialLoad {
            activityIndicator.performSelector(onMainThread: #selector(UIActivityIndicatorView.startAnimating), with: nil, waitUntilDone: false)
        }
        
        if let url = URL(string: urlString) {
            if let data =  try? Data(contentsOf: url) {
                if let json = try? JSON(data: data) {
                    self.parse(json: json)
                }
            }
        }
    }
    
    func parse(json: JSON) {
        coins = []
        for result in json.arrayValue {
            let coin = result["long"].stringValue
            let price = result["price"].stringValue
            let obj = ["coin": coin, "price": price]
            coins.append(obj)
        }
        
        if initialLoad {
            activityIndicator.performSelector(onMainThread: #selector(UIActivityIndicatorView.stopAnimating), with: nil, waitUntilDone: false)
            initialLoad = false
        }
        
        tableRefreshControl.performSelector(onMainThread: #selector(UIRefreshControl.endRefreshing), with: nil, waitUntilDone: false)
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    func backgroundFetchJSON() {
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    
    func convertToCurrencyString(_ price: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        let double = NSString(string: price).floatValue
        let number = double as NSNumber
        if let converted = formatter.string(from: number) {
            return converted
        } else {
            return "Error"
        }
    }
    
    func refreshTable() {
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }

    //table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let coin = coins[indexPath.row]
        cell.textLabel?.text = coin["coin"]
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name:"Roboto", size:18)
        cell.detailTextLabel?.font = UIFont(name:"Roboto", size:18)

        switch indexPath.row % 4 {
        case 0:
            cell.backgroundColor = colorOlive
        case 1:
            cell.backgroundColor = colorDefault
        case 2:
            cell.backgroundColor = colorSlateGray
        case 3:
            cell.backgroundColor = colorDefault
        default:
            cell.backgroundColor = colorSlateGray
        }
        
        if let price = coin["price"] {
            cell.detailTextLabel?.text = convertToCurrencyString(price)
        } else {
            cell.detailTextLabel?.text = "Error"
        }
        
        
        return cell
    }
    
}

