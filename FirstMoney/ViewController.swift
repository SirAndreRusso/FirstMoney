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
    @IBOutlet weak var allSpendings: UILabel!
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
        leftLabels()
        allSpending()
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
        leftLabels()
        allSpending()
        tableView.reloadData()
    }
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertcontroller = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in [self]
            let tfSum = alertcontroller.textFields?[0].text
            let tfDay = alertcontroller.textFields?[1].text
            guard tfDay != "" && tfSum != "" else {return}
            self.limitLabel.text = tfSum
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
            self.leftLabels()
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
    func leftLabels() {
        let limit = self.realm.objects(Limit.self)
        guard limit.isEmpty == false else {return}
        limitLabel.text = limit[0].limitSum
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any
        let filteredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        spendByPeriod.text = "\(filteredLimit)"
        guard let a = Int(limitLabel.text!),
              let b = Int(spendByPeriod.text!) else {return}
        let c = a - b
            

        availableMoney.text = "\(c)"
    }
    func allSpending() {
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpendings.text = "\(allSpend)"
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
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
        let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить") {(_,_) in
            try! self.realm.write{
                self.realm.delete(editingRow)
                self.leftLabels()
                self.allSpending()
                tableView.reloadData()
            }
        }
        return[deleteAction]
    }
    
}

