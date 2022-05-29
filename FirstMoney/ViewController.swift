//
//  ViewController.swift
//  FirstMoney
//
//  Created by Андрей Русин on 18.05.2022.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var numberFromKeyboard: [UIButton]!{
        didSet{
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var stillTyping = false
    var categoryName = ""
    var displayValue: Int = 1
    var spendingArray: Results<Spending>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self)
    }
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if let number = sender.currentTitle {
            if number == "0" && displayLabel.text == "0" {
                stillTyping = false
            }else {
                if stillTyping {
                    if displayLabel.text!.count < 13  {
                        displayLabel.text = displayLabel.text! + number
                    }else{
                        return}
                }else {
                    
                    displayLabel.text = number
                    stillTyping = true
                }
            }
        }
    }
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write{
            realm.add(value)
        }
        tableView.reloadData()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        var spending = spendingArray[indexPath.row]
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        return cell
    }
    private func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction] {
        let editingRow = spendingArray[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить") {(_,_) in
            try! self.realm.write{
                self.realm.delete(editingRow)
                tableView.reloadData()
            }
        }
        return[deleteAction]
    }
    
}

