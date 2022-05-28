//
//  ViewController.swift
//  FirstMoney
//
//  Created by Андрей Русин on 18.05.2022.
//

import UIKit

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
    var stillTyping = false
    var categoryName = ""
    var displayValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if let number = sender.currentTitle {
            if stillTyping {
                if displayLabel.text!.count < 13 {
                    displayLabel.text = displayLabel.text! + number
                }else{
                    return}
            }else {
                displayLabel.text = number
                stillTyping = true
            }
        } else {
            return}
    }
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = displayLabel.text!
        displayLabel.text = "0"
        stillTyping = false
        print(categoryName)
        print(displayValue)
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    

}

