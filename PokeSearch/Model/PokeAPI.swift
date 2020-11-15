//
//  PokeAPI.swift
//  PokeSearch
//
//  Created by Ryota Miyazaki on 2020/11/14.
//

import Foundation
import Alamofire
import RxSwift

final class PokeAPI {
    
    static let shared = PokeAPI()
    private init() {}
    
    let dammyModel = PokemonModel(id: 000, name: "MissingNo.", image: PokemonModel.Sprites(defaultImage: "MissingNo."))

    
    func get(searchID: String, success: ((PokemonModel) -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        guard searchID.count > 0 else {
            success?(dammyModel)
            return
        }
        AF.request("https://pokeapi.co/api/v2/pokemon/\(searchID)/").response { (responce) in
            switch responce.result {
            case .success:
                guard let data = responce.data,
                      let pokeAPI = try? JSONDecoder().decode(PokemonModel.self, from: data)
                else {
                    success?(self.dammyModel)
                    return
                }
                success?(pokeAPI)
            case .failure(let err):
                error?(err)
            }
        }
    }
}

extension PokeAPI: ReactiveCompatible {}
extension Reactive where Base: PokeAPI {
    func get(searchID: String) -> Observable<PokemonModel> {
        return Observable.create { observer in
            PokeAPI.shared.get(searchID: searchID, success: { (model) in
                observer.on(.next(model))
            }, error: { (err) in
                observer.on(.error(err))
            })
            return Disposables.create()
        }.share(replay: 1, scope: .whileConnected)
    }
}
