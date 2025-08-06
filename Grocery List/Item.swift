
import Foundation
import SwiftData

@Model
class Item {
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
  
    init(title: String, isCompleted: Bool,dueDate: Date? = nil){
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
}
