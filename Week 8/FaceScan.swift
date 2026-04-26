import Foundation

struct FaceScan: Identifiable, Codable {
    let id: UUID
    let date: Date
    var swellingScore: Int
    var tightnessScore: Int
    var numbnessScore: Int
    var notes: String
    var imageData: Data?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        swellingScore: Int,
        tightnessScore: Int,
        numbnessScore: Int,
        notes: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.swellingScore = swellingScore
        self.tightnessScore = tightnessScore
        self.numbnessScore = numbnessScore
        self.notes = notes
        self.imageData = imageData
    }

    static let sample = FaceScan(
        swellingScore: 5,
        tightnessScore: 4,
        numbnessScore: 6,
        notes: "Sample recovery scan"
    )
}
