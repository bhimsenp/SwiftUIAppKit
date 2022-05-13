import Foundation
import Alamofire
import AlamofireImage
import Combine

public extension DataRequest {
    func publishResponse<T: Decodable>() async throws -> T {
        try await withUnsafeThrowingContinuation { contun in
            responseData { resData in
                guard let data = resData.data, let statusCode = resData.response?.statusCode else {
                    contun.resume(throwing: Error(message: "Network call failed"))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            let serverError = try JSONDecoder().decode(Error.self, from: data)
                            contun.resume(throwing: serverError)
                        } else {
                            let response = try JSONDecoder().decode(T.self, from: data)
                            contun.resume(returning: response)
                        }
                    } catch {
                        contun.resume(throwing: Error(message: error.localizedDescription))
                    }
                }
            }
        }
    }

    func publishResponseForMultipart() async throws {
        try await withUnsafeThrowingContinuation { (contun: UnsafeContinuation<Void, Swift.Error>) in
            responseData { resData in
                guard let statusCode = resData.response?.statusCode else {
                    contun.resume(throwing: Error(message: "Network call failed"))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            if let data = resData.data {
                                let serverError = try JSONDecoder().decode(Error.self, from: data)
                                contun.resume(throwing: serverError)
                            } else {
                                contun.resume(throwing: Error(message: "Network call failed"))
                            }
                        } else {
                            contun.resume()
                        }
                    } catch {
                        contun.resume(throwing: Error(message: error.localizedDescription))
                    }
                }
            }
        }
    }

    func publishImage() async throws -> Data {
        try await withUnsafeThrowingContinuation { contun in
            responseImage { resData in
                guard let data = resData.data, let statusCode = resData.response?.statusCode else {
                    contun.resume(throwing: Error(message: "Network call failed"))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            let serverError = try JSONDecoder().decode(Error.self, from: data)
                            contun.resume(throwing: serverError)
                        } else {
                            contun.resume(returning: data)
                        }
                    } catch {
                        contun.resume(throwing: Error(message: error.localizedDescription))
                    }
                }
            }
        }
    }
}

public struct EmptyResponse: Decodable {

}
