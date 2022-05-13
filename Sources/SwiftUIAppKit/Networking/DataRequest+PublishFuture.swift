import Foundation
import Alamofire
import Combine

extension DataRequest {
    func publishResponseFuture<T: Decodable>() -> Future<T, Error> {
        Future {[unowned self] promise in
            responseData { resData in
                guard let data = resData.data, let statusCode = resData.response?.statusCode else {
                    promise(.failure(Error(message: "Network call failed", code: nil)))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            let response = try JSONDecoder().decode(Error.self, from: data)
                            promise(.failure(response))
                        } else {
                            let response = try JSONDecoder().decode(T.self, from: data)
                            promise(.success(response))
                        }
                    } catch let DecodingError.dataCorrupted(context) {
                        debugPrint(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        debugPrint("Key '\(key)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        debugPrint("Value '\(value)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context) {
                        debugPrint("Type '\(type)' mismatch:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch {
                        promise(.failure(Error(message: error.localizedDescription, code: nil)))
                    }
                }
            }
        }
    }

    func publishResponseForMultipartFuture() -> Future<EmptyResponse, Error> {
        Future {[unowned self] promise in
            responseData { resData in
                guard let statusCode = resData.response?.statusCode else {
                    promise(.failure(Error(message: "Network call failed", code: nil)))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            if let data = resData.data {
                                let response = try JSONDecoder().decode(Error.self, from: data)
                                promise(.failure(response))
                            } else {
                                promise(.failure(Error(message: "Network call failed", code: nil)))
                            }
                        } else {
                            promise(.success(EmptyResponse()))
                        }
                    } catch {
                        promise(.failure(Error(message: error.localizedDescription, code: nil)))
                    }
                }
            }
        }
    }

    func publishImageFuture() -> Future<Data, Error> {
        Future {[unowned self] promise in
            responseImage { resData in
                guard let data = resData.data, let statusCode = resData.response?.statusCode else {
                    promise(.failure(Error(message: "Network call failed", code: nil)))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        if statusCode >= 300 {
                            let response = try JSONDecoder().decode(Error.self, from: data)
                            promise(.failure(response))
                        } else {
                            promise(.success(data))
                        }
                    } catch {
                        promise(.failure(Error(message: error.localizedDescription, code: nil)))
                    }
                }
            }
        }
    }
}
