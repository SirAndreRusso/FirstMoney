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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func numberPressed(_ sender: UIButton) {
        if let _ = sender.currentTitle {
            let number = sender.currentTitle!
            print(number)
        displayLabel.text = displayLabel.text! + number
        }else {
            return}
    }
    

}

