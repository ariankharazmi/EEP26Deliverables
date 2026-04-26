import Foundation

struct FaceScan: Identifiable, Codable {
    let id: UUID
    let date: Date

    var swellingScore: Int
    var tightnessScore: Int
    var numbnessScore: Int
    var notes: String
    var imageData: Data?

    var faceWidth: Float?
    var cheekWidth: Float?
    var jawWidth: Float?
    var lowerFaceHeight: Float?
    var asymmetryScore: Float?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        swellingScore: Int,
        tightnessScore: Int,
        numbnessScore: Int,
        notes: String,
        imageData: Data? = nil,
        faceWidth: Float? = nil,
        cheekWidth: Float? = nil,
        jawWidth: Float? = nil,
        lowerFaceHeight: Float? = nil,
        asymmetryScore: Float? = nil
    ) {
        self.id = id
        self.date = date
        self.swellingScore = swellingScore
        self.tightnessScore = tightnessScore
        self.numbnessScore = numbnessScore
        self.notes = notes
        self.imageData = imageData
        self.faceWidth = faceWidth
        self.cheekWidth = cheekWidth
        self.jawWidth = jawWidth
        self.lowerFaceHeight = lowerFaceHeight
        self.asymmetryScore = asymmetryScore
    }

    static let sample = FaceScan(
        swellingScore: 5,
        tightnessScore: 4,
        numbnessScore: 6,
        notes: "Sample recovery scan",
        faceWidth: 0.145,
        cheekWidth: 0.132,
        jawWidth: 0.118,
        lowerFaceHeight: 0.091,
        asymmetryScore: 0.012
    )
}
