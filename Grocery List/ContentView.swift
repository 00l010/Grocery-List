
import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var item: String  = ""
    @State private var itemToEdit: Item?
    @State private var editedTitle: String = ""
    @State private var editedDueDate: Date = Date()
    @State private var dueDate: Date? = nil

  
    @FocusState private var isFocused: Bool
    
    let buttonTip = ButtonTip()
    
    func setupTips(){
        do{
            try Tips.resetDatastore()
            try Tips.configure([
                .displayFrequency(.immediate)
            ])
        }catch{
            print("Error initializing TipKit\(error.localizedDescription)")
        }
    }
    
    init(){
        setupTips()
    }
    
    func addEssentialFoods(){
        modelContext.insert(Item(title: "Bakery and Bread", isCompleted: false))
        modelContext.insert(Item(title: "Meat and SeaFood", isCompleted: true))
        modelContext.insert(Item(title: "Sweets", isCompleted: .random()))
        modelContext.insert(Item(title: "Pasta and Rices", isCompleted: .random()))
        modelContext.insert(Item(title: "Vegatables", isCompleted: .random()))
    }
    var body: some View {
        NavigationStack{
            List{
                ForEach(items){item in
                  VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                      .font(.title.weight(.light))
                      .foregroundStyle(item.isCompleted == false ? Color.primary:Color.accentColor)
                      .strikethrough(item.isCompleted)
                      .italic(item.isCompleted)
                    
                    if let due = item.dueDate {
                           Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                               .font(.caption)
                               .foregroundStyle(.secondary)
                       }
                   }
                   .padding(.vertical, 2)
                   .swipeActions {
                       Button(role: .destructive) {
                           withAnimation {
                               modelContext.delete(item)
                           }
                       } label: {
                           Label("Delete", systemImage: "trash")
                       }
                   }
                   .swipeActions(edge: .leading) {
                       Button("Done", systemImage: item.isCompleted ? "x.circle" : "checkmark.circle") {
                           item.isCompleted.toggle()
                       }
                       .tint(item.isCompleted ? .accentColor : .green)

                       Button("Edit") {
                           itemToEdit = item
                           editedTitle = item.title
                           editedDueDate = item.dueDate ?? Date()
                       }
                       .tint(.blue)
                }
              }
            }
            .navigationTitle("Grocery List")
            .toolbar{
                if items.isEmpty{
                    ToolbarItem(placement: .topBarTrailing){
                        Button{
                            addEssentialFoods()
                        }label:{
                           Image(systemName: "carrot")
                        }
                        .popoverTip(buttonTip)
                    }
                }
            }
            .overlay{
                if items.isEmpty{
                    ContentUnavailableView("Empty Cart",systemImage:"cart.circle",
                                           description: Text("Add some items to the shopping list."))
                }
            }
            .sheet(item: $itemToEdit) { item in
                NavigationStack {
                    Form {
                        Section("Edit Item") {
                            TextField("Item Title", text: $editedTitle)
                            DatePicker("Due Date", selection: $editedDueDate, displayedComponents: .date)
                        }
                        Section {
                            Button("Save") {
                                item.title = editedTitle
                                item.dueDate = editedDueDate
                                itemToEdit = nil
                            }
                            Button("Cancel", role: .cancel) {
                                itemToEdit = nil
                            }
                        }
                    }
                    .navigationTitle("Edit Item")
                }
            }
            .safeAreaInset(edge: .bottom){
                VStack(spacing: 12){
                    TextField("", text: $item)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.tertiary)
                        .cornerRadius(12)
                        .font(.title.weight(.light))
                        .focused($isFocused)
                    DatePicker(
                      "Due Date (optional)",
                        selection: Binding(
                          get: { dueDate ?? Date() },
                          set: { dueDate = $0 }
                        ),
                        displayedComponents: [.date]
                       )
                    .datePickerStyle(.compact)
                    .padding(.horizontal)

                    Button("Save"){
                        guard !item.isEmpty else{
                            return
                        }
                        let newItem = Item(title: item, isCompleted: false,dueDate: dueDate)
                        modelContext.insert(newItem)
                        item = ""
                        dueDate = nil
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
    }
}

#Preview("Sample Data"){
    let sampleData: [Item]=[
        Item(title: "Bakery and Bread", isCompleted: false),
        Item(title: "Meat and SeaFood", isCompleted: true),
        Item(title: "Sweets", isCompleted: .random()),
        Item(title: "Pasta and Rices", isCompleted: .random()),
        Item(title: "Vegatables", isCompleted: .random())
    ]
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    for item in sampleData{
        container.mainContext.insert(item)
    }
    return ContentView()
        .modelContainer(container)
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
