import Foundation

struct Restaurant: Decodable, Identifiable {
    let id: String
    let name: String
    let imageURL: String?
    let price: String?
    let rating: Double?
    let categories: [RestaurantCategory]
    let displayPhone: String?
    let websiteURL: String?
    let yelpURL: String?
    let location: RestaurantLocation?
    let coordinates: RestaurantCoordinates?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
        case price
        case rating
        case categories
        case displayPhone = "display_phone"
        case websiteURL = "business_website"
        case yelpURL = "url"
        case location
        case coordinates
    }
}

struct RestaurantCategory: Decodable {
    let title: String
}

struct RestaurantLocation: Decodable {
    let displayAddress: [String]
    let city: String?
    let state: String?

    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
        case city
        case state
    }
}

struct RestaurantCoordinates: Decodable {
    let latitude: Double?
    let longitude: Double?
}
