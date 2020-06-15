//
//  EventsView.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 02/01/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher
import JHSpinner

class EventsView: UITableViewController, UINavigationControllerDelegate {
    
    let cache = ImageCache.default
    var category_id = Int()
    var category_name = String()
    let isInDebug = true
    var eventsJSON = JSON()
    var catJSON = JSON()
    var debugEventsJSON = JSON()
    let daysOfWeek = ["Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota" ]
    var spinner = JHSpinnerView()
    //UIColor(rgb: 0xF9AF20)
    //let defaults = NSU
    
            
    override func viewDidAppear(_ animated: Bool) {
        //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = JHSpinnerView.showOnView(self.view, spinnerColor:UIColor(rgb: 0xF9AF20), overlay:.roundedSquare, overlayColor:UIColor.black.withAlphaComponent(0.6))
        self.view.addSubview(self.spinner)
        print(category_id)
        navigationController?.delegate = self
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(rgb: 0xF9AF20)
        self.title = category_name
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.memoryStorage.config.totalCostLimit = 1
        tableView.register(UINib(nibName: "EventCell", bundle: nil) , forCellReuseIdentifier: "eventCell")
        JSONClass.getJSON(linkArray: ["/event/event/json?dateStart=\(NSDate().timeIntervalSince1970)&category_id=\(category_id)"], completion: {jsonFile,alert in
                if jsonFile != [JSON]() {
                    
                    self.eventsJSON = jsonFile[0]
                    //print("teajhbkjbjbjjgcvblj;lbhvjgh\(self.eventsJSON)")
                   // self.deleteLateEvents()
                    self.tableView.reloadData()
                    self.spinner.dismiss()
                    print("done")
                    //print(self.eventsJSON)
                }
                else {
                    self.present(alert, animated: true)
                }
            })
    }
    
    

    
    
    func deleteLateEvents() {
            for (index,subJson):(String, JSON) in eventsJSON.reversed() {
                if subJson["category_id"].intValue != category_id {
                    eventsJSON.arrayObject?.remove(at: Int(index)!)
                    if category_id == 3 {
                        print("koncert")
                    }
                
                    //print(subJson)
                }
            }
      
        print(eventsJSON)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCellClass
        let cacheURL = eventsJSON[indexPath.row]["img"].stringValue.replacingOccurrences(of: "http://", with: "https://")
        print(eventsJSON[indexPath.row]["img"].stringValue)
        cell.bkgView.image = UIImage(named: "placeholder")
        cell.eventTitleLabel.text! = eventsJSON[indexPath.row]["title"].stringValue
        
        let unixTimestamp = eventsJSON[indexPath.row]["date_start"].doubleValue
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "DST") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" //Specify your format that you want
        let calendar = Calendar.current
        cell.dateOfEventLabel.text! = "\(daysOfWeek[calendar.component(.weekday, from: date) - 1]), \(dateFormatter.string(from: date))"
//        AF.download(eventsJSON[indexPath.row]["img"].stringValue).responseData {
//          response in
//              if let data = response.value {
//                    let image = UIImage(data: data)
//                UIView.transition(with: cell.bkgView,
//                                      duration: 0.75,
//                                      options: .transitionCrossDissolve,
//                                      animations: { cell.bkgView.kf.setImage(with: self.eventsJSON[indexPath.row]["img"].url) },
//                                      completion: nil)
//                    //cell.bkgView.image = image
//               }
//        }
        
//        UIView.transition(with: cell.bkgView,
//                          duration: 0.4,
//                          options: .transitionCrossDissolve,
//                          animations: { cell.bkgView.kf.setImage(with: URL(string: cacheURL)) },
//                          completion: nil)
        
        

        //let processor = DownsamplingImageProcessor(size: cell.bkgView.frame.size)
        
//        cache.retrieveImage(forKey: cacheURL) { result in
//            switch result {
//            case .success(let value):
//                print(value.cacheType)
//
//                // If the `cacheType is `.none`, `image` will be `nil`.
//                if value.cacheType == .none {
//                    let resource = ImageResource(downloadURL: URL(string: cacheURL)!)
//                    cell.bkgView.kf.setImage(
//                    with: resource,
//                    placeholder: UIImage(named: "placeholder"),
//                    options: [
//                        .processor(processor),
//                        .scaleFactor(UIScreen.main.scale),
//                        .transition(.fade(1)),
//                    ])
//                }
//                else {
//                    cell.bkgView.image = value.image
//                }
//
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        let url = URL(string: cacheURL)
        let processor = DownsamplingImageProcessor(size: cell.bkgView.frame.size)
        cell.bkgView.kf.indicatorType = .activity
        cell.bkgView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
        //cell.eventCategoryLabel.text! = catJSON[eventsJSON[indexPath.row]["category_id"].stringValue]["name"].stringValue
        //print(eventsJSON[indexPath.row]["category_id"].stringValue)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsJSON.count
    }
    
   
}

var vSpinner : UIView?


