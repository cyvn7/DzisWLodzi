//
//  EventsCategoryView.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 06/01/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher
class EventsCategoryView: UITableViewController {
    
    var eventsJSON = JSON()
    var catJSON = JSON()
    var catDict = [Int: String]()
    var selectedID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JSONClass.getJSON(linkArray: ["/event/event/json-categories"], completion: {jsonFile,alert in
            if jsonFile != [JSON]() {
                self.catJSON = jsonFile[0]
                self.deleteIrrelevant()
                print(self.catDict)
                //print(self.catJSON)
                self.tableView.reloadData()
                print("done")
            }
            else {
                self.present(alert, animated: true)
            }
        })
    }
    
    func deleteIrrelevant() {

        //print(catJSON)
        for (index,subJson) in catJSON.reversed() {
            if subJson["parent_id"].intValue == 1 {
                catDict[subJson["id"].intValue] = subJson["name"].stringValue
                if Int(index)! > 30 {
                    break
                }
                //rint(catJSON)
            }
        }
       // print(catJSON)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //print("cell added: \(catJSON[String(indexPath.row )]["name"].stringValue), \(catJSON[String(indexPath.row)]["system_name"].stringValue) id: \(indexPath.row)")
            // create a new cell if needed or reuse an old one
        print("halo?")
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCatCell", for: indexPath)
        cell.textLabel!.text = Array(catDict)[indexPath.row].value
            cell.textLabel?.textColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.orange
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = Array(catDict)[indexPath.row].key
        performSegue(withIdentifier: "goToEvents", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catDict.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let rootFvc = segue.destination as! UINavigationController
        let fvc = rootFvc.topViewController as! EventsView
        fvc.category_id = selectedID
        fvc.category_name = catDict[selectedID]!
        print("category name: \(catDict[selectedID]!)")
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
