//
//  URLSession+Extension.swift
//  URLSession_Week9
//
//  Created by SeungYeon Yoo on 2022/08/30.
//

import Foundation

extension URLSession {
    
    typealias completionHandler = (Data?, URLResponse?, Error?) -> Void
    
    @discardableResult
    func customDataTask(_ endpoint: URLRequest, completionHandler: @escaping completionHandler) -> URLSessionDataTask {
        let task = dataTask(with: endpoint, completionHandler: completionHandler)
        task.resume()
        
        return task
    }
    
    static func request<T: Codable>(_ session: URLSession = .shared, endpoint: URLRequest, completion: @escaping (T?, APIError?) -> Void ) {
        
//        URLSession.shared.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>).resume() 위 코드를 아래와 같이 줄임
        
        session.customDataTask(endpoint) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Failed Request")
                    completion(nil, .failedRequest)
                    return
                }
                
                guard let data = data else {
                    print("No Data Returned")
                    completion(nil, .noData)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("Unable Response")
                    completion(nil, .invalidResponse)
                    return
                }
                
                guard response.statusCode == 200 else {
                    print("Failed Response")
                    completion(nil, .failedRequest)
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data) //데이터를 해당파일에 코딩해서 넣겠다. (decodable)
                    completion(result, nil)
                } catch {
                    print(error)
                    completion(nil, .invalidData)
                }
            }
        }
        
    }
}
