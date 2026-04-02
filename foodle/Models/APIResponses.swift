import Foundation

struct RestaurantSearchResponse: Decodable {
    let featured: Restaurant
    let others: [Restaurant]

    enum CodingKeys: String, CodingKey {
        case featured = "restaurant_featured"
        case others = "restaurant_others"
    }
}

struct RestaurantDetailResponse: Decodable {
    let restaurant: Restaurant
}

struct WebsiteResponse: Decodable {
    let businessWebsite: String?

    enum CodingKeys: String, CodingKey {
        case businessWebsite = "business_website"
    }
}

struct RecipeSearchResponse: Decodable {
    let featured: Recipe
    let others: [Recipe]

    enum CodingKeys: String, CodingKey {
        case featured = "recipe_featured"
        case others = "recipe_others"
    }
}

struct RecipeDetailResponse: Decodable {
    let recipe: Recipe
}

struct APIErrorResponse: Decodable {
    let error: String
}
