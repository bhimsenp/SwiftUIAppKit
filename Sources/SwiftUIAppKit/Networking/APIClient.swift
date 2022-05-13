import Foundation
import Combine
import Alamofire
import AlamofireImage
import UIKit

public class APIClient {

    public static let shared = APIClient()
    public let baseUrl: String

    init() {
        self.baseUrl = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    }

    public func get<T: Decodable>(url: String) async throws -> T {
        try await AF.request("\(baseUrl)\(url)", headers: commonHeaders()).publishResponse()
    }

    public func post<T: Decodable, U: Encodable>(url: String, body: U, headers: [String: String] = [:]) async throws -> T {
        try await AF.request("\(baseUrl)\(url)", method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: commonHeaders(headers)).publishResponse()
    }

    public func put<T: Decodable, U: Encodable>(url: String, body: U) async throws -> T {
        try await AF.request("\(baseUrl)\(url)", method: .put, parameters: body, encoder: JSONParameterEncoder.default, headers: commonHeaders()).publishResponse()
    }

    public func delete<T: Decodable>(url: String, headers: [String: String] = [:]) async throws -> T {
        try await AF.request("\(baseUrl)\(url)", method: .delete, headers: commonHeaders(headers)).publishResponse()
    }

    public func uploadImage(url: String, imageData: Data, name: String, imageFieldName: String = "image", formData: [String: String]? = nil) async throws {
        try await AF.upload(multipartFormData: { allFormData in
            formData?.forEach { (key, value) in
                allFormData.append(value.data(using: .utf8)!, withName: key)
            }
            allFormData.append(imageData, withName: imageFieldName, fileName: name, mimeType: "image/jpeg")
        }, to: "\(baseUrl)\(url)", method: .put, headers: commonHeaders()).publishResponseForMultipart()
    }

    public func fetchImage(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw Error(message: "Invalid url")
        }
        let config = ImageDownloader.defaultURLSessionConfiguration()
        // This is because we are caching image on our own and ImageDownloader's default caching behaves weirdly
        config.urlCache = nil
        let imageDownloader = ImageDownloader(
            configuration: config,
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 10,
            imageCache: AutoPurgingImageCache()
        )
        let urlRequest = URLRequest(url: url)
        return try await imageDownloader.download(urlRequest)!.request.publishImage()
    }

    private func commonHeaders(_ headers: [String: String] = [:]) -> HTTPHeaders {
        let token = UserDefaultsService.shared.getString(withKey: "token")
        let headers = token != nil ? ["Authorization": "Bearer \(token!)"] : [:]
        return HTTPHeaders(headers.merging(headers, uniquingKeysWith: {$1}))
    }
}

public extension APIClient {
    func getFuture<T: Decodable>(url: String) -> Future<T, Error> {
        AF.request("\(baseUrl)\(url)", headers: commonHeaders()).publishResponseFuture()
    }

    func postFuture<T: Decodable, U: Encodable>(url: String, body: U, headers: [String: String] = [:]) -> Future<T, Error> {
        AF.request("\(baseUrl)\(url)", method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: commonHeaders(headers)).publishResponseFuture()
    }

    func putFuture<T: Decodable, U: Encodable>(url: String, body: U) -> Future<T, Error> {
        AF.request("\(baseUrl)\(url)", method: .put, parameters: body, encoder: JSONParameterEncoder.default, headers: commonHeaders()).publishResponseFuture()
    }

    func deleteFuture<T: Decodable>(url: String, headers: [String: String] = [:]) -> Future<T, Error> {
        AF.request("\(baseUrl)\(url)", method: .delete, headers: commonHeaders(headers)).publishResponseFuture()
    }

    func uploadImageFuture(url: String, imageData: Data, name: String, imageFieldName: String = "image", formData: [String: String]? = nil) -> Future<EmptyResponse, Error> {
        AF.upload(multipartFormData: { allFormData in
            formData?.forEach { (key, value) in
                allFormData.append(value.data(using: .utf8)!, withName: key)
            }
            allFormData.append(imageData, withName: imageFieldName, fileName: name, mimeType: "image/jpeg")
        }, to: "\(baseUrl)\(url)", method: .post).publishResponseForMultipartFuture()
    }

    func fetchImageFuture(url: String) -> Future<Data, Error> {
        guard let url = URL(string: url) else {
            return Future { promise in
                promise(.failure(Error(message: "Invalid url")))
            }
        }
        let config = ImageDownloader.defaultURLSessionConfiguration()
        let imageDownloader = ImageDownloader(
            configuration: config,
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 10,
            imageCache: AutoPurgingImageCache()
        )
        let urlRequest = URLRequest(url: url)
        return imageDownloader.download(urlRequest)!.request.publishImageFuture()
    }
}

public extension Publisher {
    func finish(success: @escaping ((Output) -> Void), failure: @escaping ((Failure) -> Void)) {
        var cancellable = Set<AnyCancellable>()
        sink { completion in
            cancellable.removeAll()
            guard case .failure(let error) = completion else {
                return
            }
            failure(error)
        } receiveValue: { value in
            success(value)
        }.store(in: &cancellable)
    }
}

public struct Error: Swift.Error, Decodable {
    public let message: String
    public let code: String?

    public init(message: String) {
        self.init(message: message, code: nil)
    }

    public init(message: String, code: String?) {
        self.message = message
        self.code = code
    }
}
