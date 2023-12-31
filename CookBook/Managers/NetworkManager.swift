import UIKit

class NetworkManager {
    
    static let shared    = NetworkManager()
    private let baseURL  = "https://www.themealdb.com/api/json/v1/1/"
    private let cache    = NSCache<NSString, UIImage>()
    
    private init() {}
    
    
    //   FUNCTION TO GET CATEGORY DATA & DECODE JSON
    
    func getCategories(completed: @escaping (Result<CategoryAPIResponse, ErrorMessages>) -> Void) {
        
        let endpoint = baseURL + "categories.php"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let categories = try decoder.decode(CategoryAPIResponse.self, from: data)
                completed(.success(categories))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    //    FUNCTION TO GET MEAL DATA & DECODE JSON
    
    func getMeals(for category: String, completed: @escaping (Result<MealAPIResponse, ErrorMessages>) -> Void) {
        
        let endpoint = baseURL + "filter.php?c=\(category)"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let meals = try decoder.decode(MealAPIResponse.self, from: data)
                completed(.success(meals))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    //   FUNCTION TO GET MEAL DETAILS DATA & DECODE JSON
    
    func getMealDetails(for mealID: String, completed: @escaping (Result<MealDetailsAPIResponse, ErrorMessages>) -> Void) {
        
        let endpoint = baseURL + "lookup.php?i=\(mealID)"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()

                let mealDetails = try decoder.decode(MealDetailsAPIResponse.self, from: data)
                completed(.success(mealDetails))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    //    FUNCTION TO GET IMAGE FROM URL & CACHE IT
    
    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        
        //     CHECKING IF IMAGE IS IN CACHE
        
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self,
                error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data) else {
                    completed(nil)
                    return
                }
            
            //     PUTTING IMAGE IN CACHE
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }
    
}

