import Foundation
import SwiftData

@Model
final class TaskCategory {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \TodoTask.category)
    var tasks: [TodoTask] = []

    init(name: String, createdAt: Date = .now) {
        self.id = UUID()
        self.name = name
        self.createdAt = createdAt
    }
}

enum CategoryFilter {
    static let allCategoriesID = ""

    static func matches(_ task: TodoTask, selectedCategoryID: String) -> Bool {
        guard !selectedCategoryID.isEmpty else { return true }
        return task.category?.id.uuidString == selectedCategoryID
    }

    @MainActor
    static func category(withID id: UUID, in context: ModelContext) -> TaskCategory? {
        let descriptor = FetchDescriptor<TaskCategory>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descriptor).first
    }

    @MainActor
    static func selectedCategory(in context: ModelContext) -> TaskCategory? {
        let storedID = UserDefaults.standard.string(forKey: EasyTODOSettings.selectedCategoryID) ?? ""
        guard let id = UUID(uuidString: storedID) else { return nil }
        return category(withID: id, in: context)
    }
}
