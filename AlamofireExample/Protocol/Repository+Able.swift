//
//  HttpRequestPresentable.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/16.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//
import Alamofire
import ObjectMapper
import RxSwift

protocol HttpRequestable {
    func createSingle<T: Mappable>(withEndpoint endpoint: String, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding) -> Single<T>
}

extension HttpRequestable {
    func createSingle<T>(withEndpoint endpoint: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default) -> PrimitiveSequence<SingleTrait, T> where T : Mappable {
        return Single<T>.create { singleEvent in
            let request = APIManager.shared.request(endpoint,
                                            method: method,
                                            parameters: parameters,
                                            encoding: encoding)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        guard let entity = Mapper<T>().map(JSONObject: data) else { singleEvent(.error(AppError.generic("JSON Parse error!"))); return }
                        singleEvent(.success(entity))
                    case .failure(let error):
                        singleEvent(.error(AppError.network(error)))
                    }
            }
            return Disposables.create { request.cancel() }
        }
    }
}
