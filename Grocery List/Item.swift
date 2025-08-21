
import Foundation
import SwiftData

@Model
class Item: Hashable {
  var id: UUID = UUID()
  var title: String
  var isCompleted: Bool
  var dueDate: Date?
  
  static func == (lhs: Item, rhs: Item) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  init(title: String, isCompleted: Bool,dueDate: Date? = nil){
    self.title = title
    self.isCompleted = isCompleted
    self.dueDate = dueDate
  }
}
