//
//  SpendingModel.swift
//  FirstMoney
//
//  Created by Андрей Русин on 29.05.2022.
//

import Foundation
import RealmSwift
class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
    
}
