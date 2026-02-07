import Foundation

struct Card: Identifiable {
    let id: UUID
    let front: String
    let back: String
    let dueDate: Date
    let box: Int

    init(
        id: UUID = UUID(),
        front: String,
        back: String,
        dueDate: Date,
        box: Int
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.dueDate = dueDate
        self.box = box
    }
}
