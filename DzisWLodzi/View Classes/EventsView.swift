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
    
    var localtitleStr = String()
    var localDescStr = String()
    var localImages = [Int : UIImage]()
    var localImage = UIImage()
    var localWebsite = String()
    var localDate = String()
    //UIColor(rgb: 0xF9AF20)
    //let defaults = NSU
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
            
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
        //popraw dateStart=\(NSDate().timeIntervalSince1970)&
        JSONClass.getJSON(linkArray: ["/event/event/json?category_id=\(category_id)"], completion: {jsonFile,alert in
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
        //cell.bkgView.image = UIImage(named: "placeholder")
        cell.eventTitleLabel.text! = eventsJSON[indexPath.row]["title"].stringValue
        
        let unixTimestamp = eventsJSON[indexPath.row]["date_start"].doubleValue
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "DST") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" //Specify your format that you want
        let calendar = Calendar.current
        cell.dateOfEventLabel.text! = "\(daysOfWeek[calendar.component(.weekday, from: date) - 1]), \(dateFormatter.string(from: date))"
        
        
        let url = URL(string: cacheURL)
        let processor = DownsamplingImageProcessor(size: cell.bkgView.frame.size)
        cell.bkgView.kf.indicatorType = .activity
        cell.bkgView.kf.setImage(
            with: url,
            placeholder: UIImage(color: UIColor(rgb: 0xF9AF20)),
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
                self.localImages[indexPath.row] = value.image
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
                
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
        //cell.eventCategoryLabel.text! = catJSON[eventsJSON[indexPath.row]["category_id"].stringValue]["name"].stringValue
        //print(eventsJSON[indexPath.row]["category_id"].stringValue)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let unixTimestamp = eventsJSON[indexPath.row]["date_start"].doubleValue
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "DST") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" //Specify your format that you want
        let calendar = Calendar.current
        localtitleStr = eventsJSON[indexPath.row]["title"].stringValue
        localDescStr = eventsJSON[indexPath.row]["description"].stringValue
        print(indexPath.row)
        localImage = localImages[indexPath.row]!
        localWebsite = eventsJSON[indexPath.row]["url_buy"].stringValue
        localDate = "\(daysOfWeek[calendar.component(.weekday, from: date) - 1]), \(dateFormatter.string(from: date))"

        performSegue(withIdentifier: "goToDesc", sender: self)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsJSON.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fvc = segue.destination as! EventDesc
        fvc.titleStr = localtitleStr
        fvc.descStr = localDescStr
        fvc.image = localImage
        fvc.website = localWebsite
        fvc.date = localDate
    }
    
   
}

var vSpinner : UIView?


public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
