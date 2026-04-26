import Foundation

struct FaceMetrics: Codable, Equatable {
    var faceWidth: Float
    var faceHeight: Float
    var faceDepth: Float
    var midFaceWidth: Float
    var lowerFaceWidth: Float
    var lowerFaceHeight: Float
    var asymmetryScore: Float
}

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

    var faceHeight: Float?
    var faceDepth: Float?
    var midFaceWidth: Float?
    var lowerFaceWidth: Float?

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
        asymmetryScore: Float? = nil,
        faceHeight: Float? = nil,
        faceDepth: Float? = nil,
        midFaceWidth: Float? = nil,
        lowerFaceWidth: Float? = nil
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

        self.faceHeight = faceHeight
        self.faceDepth = faceDepth
        self.midFaceWidth = midFaceWidth
        self.lowerFaceWidth = lowerFaceWidth
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        swellingScore: Int,
        tightnessScore: Int,
        numbnessScore: Int,
        notes: String,
        imageData: Data? = nil,
        metrics: FaceMetrics?
    ) {
        self.id = id
        self.date = date
        self.swellingScore = swellingScore
        self.tightnessScore = tightnessScore
        self.numbnessScore = numbnessScore
        self.notes = notes
        self.imageData = imageData

        self.faceWidth = metrics?.faceWidth
        self.faceHeight = metrics?.faceHeight
        self.faceDepth = metrics?.faceDepth
        self.midFaceWidth = metrics?.midFaceWidth
        self.lowerFaceWidth = metrics?.lowerFaceWidth
        self.lowerFaceHeight = metrics?.lowerFaceHeight
        self.asymmetryScore = metrics?.asymmetryScore
        self.cheekWidth = metrics?.midFaceWidth
        self.jawWidth = metrics?.lowerFaceWidth
    }

    
    static let sample = FaceScan(
        swellingScore: 5,
        tightnessScore: 4,
        numbnessScore: 6,
        notes: "Sample Snapshot Metrics",
        metrics: FaceMetrics(
            faceWidth: 0.145,
            faceHeight: 0.190,
            faceDepth: 0.075,
            midFaceWidth: 0.132,
            lowerFaceWidth: 0.118,
            lowerFaceHeight: 0.091,
            asymmetryScore: 0.012
        )
    )
}
