//
//  APIClient.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 26/07/23.
//


import UIKit

class APIClient {
    
    static let shared = APIClient()
    
    private init() {}
    
    private var activityIndicator: UIActivityIndicatorView?
    private var lastAPICallTime: Date?
    private let minimumAPICallInterval: TimeInterval = 1.0
    
    // MARK: - Public Methods
    
    
    func get<T: Codable>(url: String, parameters: [String: String]? = nil, responseType: T.Type) async throws -> T {
        guard let nUrl = URL(string: url) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }
        
        var urlComponents = URLComponents(url: nUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURL = urlComponents?.url else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }
        
        // Check if the minimum time interval has passed since the last API call
        let now = Date()
        if let lastCallTime = lastAPICallTime, now.timeIntervalSince(lastCallTime) < minimumAPICallInterval {
            // Throttle the call by returning a default value or an error, or simply do nothing.
            // You can also consider queuing the requests and handling them later.
            throw NSError(domain: "ThrottledAPIRequest", code: -1, userInfo: nil)
        }
        
        // Record the current time as the last API call time
        lastAPICallTime = now
        
        let (data, response) = try await performRequest(url: finalURL, httpMethod: "GET")
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NSError(domain: "InvalidResponse", code: -1, userInfo: nil)
        }
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(T.self, from: data)
        return decodedResponse
    }
    
    func post<T: Codable>(url: String, body: [String: Any], responseType: T.Type) async throws -> T {
        
        guard let nUrl = URL(string: url) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }
        
        let now = Date()
        if let lastCallTime = lastAPICallTime, now.timeIntervalSince(lastCallTime) < minimumAPICallInterval {
            // Throttle the call by returning a default value or an error, or simply do nothing.
            // You can also consider queuing the requests and handling them later.
            throw NSError(domain: "ThrottledAPIRequest", code: -1, userInfo: nil)
        }
        
        // Record the current time as the last API call time
        lastAPICallTime = now
        
        
        let (data, response) = try await performRequest(url: nUrl, httpMethod: "POST", body: body)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NSError(domain: "InvalidResponse", code: -1, userInfo: nil)
        }
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(T.self, from: data)
        return decodedResponse
    }
    
    // MARK: - Private Methods
    
    private func performRequest(url: URL, httpMethod: String, body: [String: Any]? = nil) async throws -> (Data, URLResponse) {
        let requestId = UUID().uuidString
        logRequestStarted(requestId: requestId, method: httpMethod, url: url, headers: nil, body: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw error
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            logRequestReceivedResponse(requestId: requestId, response: response, data: data)
            return (data, response)
        } catch {
            throw error
        }
    }
    private func logRequestStarted(requestId: String, method: String, url: URL, headers: [AnyHashable: Any]?, body: Any?) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("\(timestamp) ⚪️ Request started\n\n       id: \(requestId)\n   method: \(method)\n      url: \(url.absoluteString)\n  headers: \(headers ?? [:])\n     body: \(body ?? "None")\n")
    }
    
    private func logRequestReceivedResponse(requestId: String, response: URLResponse?, data: Data) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        if let httpResponse = response as? HTTPURLResponse {
            print("\(timestamp) ⚪️ Request response received\n\n       id: \(requestId)\n   status: \(httpResponse.statusCode)\n  headers: \(httpResponse.allHeaderFields)\n     body: \(String(data: data, encoding: .utf8) ?? "")\n")
        }
    }
    
    private func logRequestFailed(requestId: String, error: Error) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("\(timestamp) ⚪️ Request failed\n\n       id: \(requestId)\n   error: \(error.localizedDescription)\n")
    }
    
    
    private func showActivityIndicator() {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                self.activityIndicator = UIActivityIndicatorView(style: .medium)
                self.activityIndicator?.center = keyWindow.center
                keyWindow.addSubview(self.activityIndicator!)
                self.activityIndicator?.startAnimating()
            }
        }
    }
    
    private func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}
