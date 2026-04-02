import Foundation

struct Recipe: Decodable, Identifiable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?
    let sourceURL: String?
    let summary: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case readyInMinutes
        case servings
        case sourceURL = "sourceUrl"
        case summary
    }
}
