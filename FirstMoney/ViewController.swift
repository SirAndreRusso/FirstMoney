//
//  ViewController.swift
//  FirstMoney
//
//  Created by Андрей Русин on 18.05.2022.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var availableMoney: UILabel!
    @IBOutlet weak var spendByPeriod: UILabel!
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
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertcontroller = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in [self]
            let tfSum = alertcontroller.textFields?[0].text
            self.limitLabel.text = tfSum
            let tfDay = alertcontroller.textFields?[1].text
            guard tfDay != "" else {return}
            if let day = tfDay {
                let currentDate = Date()
                let lastDay = currentDate.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, currentDate, lastDay])
                    try! self.realm.write{
                        self.realm.add(value)
                    }
                    
                }else {
                    try! self.realm.write {
                        limit[0].limitSum = self.self.limitLabel.text!
                        limit[0].limitDate = currentDate as NSDate
                        limit[0].limitLastDay = lastDay as NSDate
                    }
                }
                
            }
        }
        alertcontroller.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .numberPad
        }
        alertcontroller.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .numberPad
        }
        let alertCancel = UIAlertAction(title: "Отмена", style: .cancel) { _ in }
        alertcontroller.addAction(alertInstall)
        alertcontroller.addAction(alertCancel)
        present(alertcontroller, animated: true)
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let spending = spendingArray[indexPath.row]
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        switch spending.category {
        case "🍔": cell.recordCategory.text! += "  Еда"
        case "👗": cell.recordCategory.text! += "  Одежда"
        case "📞": cell.recordCategory.text! += "  Связь"
        case "🎣": cell.recordCategory.text! += "  Досуг"
        case "💅🏻": cell.recordCategory.text! += "  Красота"
        case "🚙": cell.recordCategory.text! += "  Авто"
        default:   cell.recordCategory.text! += ""
        }
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

