import Foundation

enum APIClientError: LocalizedError {
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case let .serverError(message):
            return message
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private init() {}

    private func request(
        path: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        let url = APIEnvironment.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIClientError.serverError(apiError.error)
            }
            throw APIClientError.serverError("Request failed with status \(httpResponse.statusCode).")
        }

        return (data, httpResponse)
    }

    func searchRestaurants(location: String, item: String) async throws -> RestaurantSearchResponse {
        let payload: [String: String] = [
            "location": location,
            "item": item
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let (data, _) = try await request(path: "api/v1/restaurants/search", method: "POST", body: body)
        return try decoder.decode(RestaurantSearchResponse.self, from: data)
    }

    func getRestaurant(id: String) async throws -> Restaurant {
        let (data, _) = try await request(path: "api/v1/restaurants/\(id)")
        return try decoder.decode(RestaurantDetailResponse.self, from: data).restaurant
    }

    func getRestaurantWebsite(id: String) async throws -> String? {
        let (data, _) = try await request(path: "api/v1/restaurants/\(id)/website")
        return try decoder.decode(WebsiteResponse.self, from: data).businessWebsite
    }

    func searchRecipes(item: String) async throws -> RecipeSearchResponse {
        let payload: [String: String] = ["item": item]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let (data, _) = try await request(path: "api/v1/recipes/search", method: "POST", body: body)
        return try decoder.decode(RecipeSearchResponse.self, from: data)
    }

    func getRecipe(id: Int) async throws -> Recipe {
        let (data, _) = try await request(path: "api/v1/recipes/\(id)")
        return try decoder.decode(RecipeDetailResponse.self, from: data).recipe
    }
}
