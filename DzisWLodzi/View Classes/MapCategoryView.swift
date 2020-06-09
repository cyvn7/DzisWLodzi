//
//  CategoryView.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 28/12/2019.
//  Copyright © 2019 Maciej Przybylski. All rights reserved.
//

import UIKit
import CoreData

class MapCategoryView: UITableViewController {
    
    var categoryMonuments = [String : Int]()
    var categoryAttractions = [String : Int]()
    var currentDict = [String : Int]()
    var selectedCategories = [Int]()
    var keysArray = Array<Any>()
    
    
    @IBOutlet weak var doneBtnOut: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            currentDict = categoryMonuments
            keysArray = Array(currentDict.keys)
        case 1:
            currentDict = categoryAttractions
            keysArray = Array(currentDict.keys)
        default:
            break
        }
        tableView.reloadData()
    }
    
    
    @IBAction func refresh(_ sender: Any) {
        selectedCategories = [Int]()
        defaults.set(selectedCategories, forKey: "selectedCategories")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        tableView.reloadData()
    }

    
    @IBAction func doneBtnPressed(_ sender: Any) {

        self.dismiss(animated: true, completion: nil) 
    }
    
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCategories = (defaults.array(forKey: "selectedCategories") ?? [Int]()) as! [Int]
        doneBtnOut.isEnabled = false
        currentDict = categoryMonuments
        keysArray = Array(currentDict.keys)
        let fontFirst = UIFont(name: "Lato-Semibold", size: 18.0)!
    segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : fontFirst, NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xF9AF20)], for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentDict.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = keysArray[indexPath.row] as? String
        cell.textLabel?.font = UIFont(name:"Raleway-SemiBold", size:20)
        cell.tintColor = UIColor(rgb: 0xF9AF20)
        
        if selectedCategories.contains(currentDict[cell.textLabel!.text!]!) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
//        if let category = categories?[indexPath.row] {
//
//            cell.textLabel?.text = category.name
//
//            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
//
//            cell.backgroundColor = categoryColour
//            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
//
//        }



       return cell

    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            let cur_id = currentDict[cell.textLabel!.text!]!
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                selectedCategories.append(cur_id)
                doneBtnOut.isEnabled = true
                //newUser.setValue(cur_id, forKey: "cat_id")
                
            } else if cell.accessoryType == .checkmark {
                
                cell.accessoryType = .none
                selectedCategories = selectedCategories.filter { $0 != cur_id }
                if selectedCategories == [Int]() {
                    doneBtnOut.isEnabled = false
                }
                //context.delete(object)
            }
            
            defaults.set(selectedCategories, forKey: "selectedCategories")
        }
         
        
    }
}

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var cellText: UILabel!
    
    
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}


