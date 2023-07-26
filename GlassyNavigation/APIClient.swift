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
    
    // MARK: - Public Methods
    
    func get<T: Codable>(url: String, parameters: [String: String]? = nil, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let nUrl = URL(string: url) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: nil)
            completion(.failure(error))
            return
        }
        
           var urlComponents = URLComponents(url: nUrl, resolvingAgainstBaseURL: false)
           urlComponents?.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
           
           guard let finalURL = urlComponents?.url else {
               let error = NSError(domain: "InvalidURL", code: -1, userInfo: nil)
               completion(.failure(error))
               return
           }
           
           performRequest(url: finalURL, httpMethod: "GET", responseType: responseType, completion: completion)
       }
    
    func post<T: Codable>(url: String, body: [String: Any], responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let nUrl = URL(string: url) else {return}
        performRequest(url: nUrl, httpMethod: "POST", body: body, responseType: responseType, completion: completion)
    }
    
    // MARK: - Private Methods
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(url: URL, httpMethod: String, body: [String: Any]? = nil, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        let requestId = UUID().uuidString
        
        logRequestStarted(requestId: requestId, method: httpMethod, url: url, headers: nil, body: body)
        
        //showActivityIndicator()
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
               // hideActivityIndicator()
                completion(.failure(error))
                logRequestFailed(requestId: requestId, error: error)
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           
          //  self.hideActivityIndicator()
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: error.localizedDescription)
                }
                completion(.failure(error))
                self.logRequestFailed(requestId: requestId, error: error)
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "No data received from server.")
                }
                completion(.failure(error))
                self.logRequestFailed(requestId: requestId, error: error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                completion(.success(decodedResponse))
                self.logRequestReceivedResponse(requestId: requestId, response: response, data: data)
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to decode response.")
                }
                completion(.failure(error))
                self.logRequestFailed(requestId: requestId, error: error)
            }
        }
        
        task.resume()
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
