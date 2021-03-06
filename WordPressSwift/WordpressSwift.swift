//
//  WordpressSwift.swift
//  Wordpress Swift
//
//  Created by Ruben Fernandez on 4/3/18.
//  Copyright © 2018 Ruben Fernandez. All rights reserved.
//

import Foundation

public struct WPPost: Codable {
    
    public struct Title: Codable {
        public let text: String
        private enum CodingKeys: String, CodingKey {
            case text = "rendered"
        }
    }
    
    public struct Content: Codable {
        public let text: String
        public let protected: Bool
        private enum CodingKeys: String, CodingKey {
            case text = "rendered"
            case protected
        }
    }
    
    public struct Excerpt: Codable {
        public let text: String
        public let protected: Bool
        private enum CodingKeys: String, CodingKey {
            case text = "rendered"
            case protected
        }
    }
    
    public let id: Int
    public let date: String
    public let date_gmt: String
    public let modified: String
    public let modified_gmt: String
    public let slug: String
    public let status: String
    public let type: String
    public let link: String
    public let title: Title
    public let content: Content
    public let excerpt: Excerpt
    public let author: Int
    public let featured_media: Int
    public let comment_status: String
    public let ping_status: String
    public let sticky: Bool
    public let template: String
    public let format: String
    public let categories: [Int]
    public let tags: [Int]
    
}

public struct WPCategory: Codable {
    
    public let id: Int
    public let count: Int
    public let description: String
    public let link: String
    public let name: String
    public let slug: String
    public let taxonomy: String
    public let parent: Int
    
}

public struct WPFeaturedImage: Codable {
    
    public struct MediaDetails: Codable {
        public let width: Int
        public let height: Int
        public let file: String
    }
    
    public let id: Int
    public let image: String
    public let type: String
    public let media_type: String
    public let media_details: MediaDetails
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case image = "source_url"
        case type
        case media_type
        case media_details
        
    }
    
    
}

public class WordpressSwift {
    
    public init(){}
    
/**
Get categories of a Wordpress site
 - parameter blogURL: URL of the Wordpress blog. Like: http://myblog.com
 */
    public func getCategories(blogURL: String, completionHandler: @escaping ([WPCategory]) -> Void) {
        
        var categories = [WPCategory]()
        
        let baseURL = blogURL + "/wp-json/wp/v2/categories"
        
        guard let url = URL(string: baseURL) else {
            print("ERROR: Please, type a correct URL, like:  http://myblog.com")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            do {
                
                categories = try JSONDecoder().decode([WPCategory].self, from: data)
                DispatchQueue.main.async {
                    completionHandler(categories)
                }
                
            } catch {
                print("ERROR")
            }
            
            }.resume()
        
    }
    
    
/**
Get posts published on Wordpress blog
 - parameter blogURL: URL of the Wordpress blog. Like: http://myblog.com
 - parameter page: Number of page. Use it to load content step by step.  *Must be 1 or higher*
 - parameter postPerPage: Number of posts for each page.  *Must be 1 or higher*
 - parameter categoryID: Array of category ID. Use it to filter by category.  *Enter [0] for show all categories*
 */
    public func getPosts(blogURL: String, page: Int, postPerPage: Int, categoryID: [Int], completionHandler: @escaping ([WPPost]) -> Void) {
        
        var posts = [WPPost]()
        
        if categoryID.isEmpty == false && postPerPage > 0 && page > 0 && blogURL.isEmpty == false{
            
            var baseURL = blogURL + "/wp-json/wp/v2/posts?page=\(page)&per_page=\(postPerPage)"
            
            if categoryID.first != 0 {
                
                var categories = "\(categoryID.first!)"
                
                if categoryID.count > 1 {
                    
                    for i in 1...categoryID.count-1 {
                        
                        categories += ",\(categoryID[i])"
                        
                    }
                    
                }
                
                baseURL += "&categories=\(categories)"
                
            }
        
            guard let url = URL(string: baseURL) else {
                
                print("ERROR: Please, type a correct URL, like:  http://myblog.com")
                return
                
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
                do {
                    
                    posts = try JSONDecoder().decode([WPPost].self, from: data)
                    
                    DispatchQueue.main.async {
                        completionHandler(posts)
                    }
                    
                } catch {
                    print("ERROR")
                }
                
                }.resume()
            
        } else {
            
            print("Please, complete all parameters with correct values")
            
        }
        
    }
    
    
    
    
    public func featuredImage(blogURL: String, post: WPPost, completionHandler: @escaping (WPFeaturedImage) -> Void) {
        
        let baseURL = blogURL + "/wp-json/wp/v2/media/" + "\(post.featured_media)"
        
        guard let url = URL(string: baseURL) else {
            
            print("ERROR: Please, type a correct URL, like:  http://myblog.com")
            return
            
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            do {
                
                let image = try JSONDecoder().decode(WPFeaturedImage.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(image)
                }
                
            } catch {
                print("ERROR")
            }
            
            }.resume()
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
