//
//  SearchPokemonViewModel.swift
//  PokeSearch
//
//  Created by Ryota Miyazaki on 2020/11/14.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

protocol PokeSearchViewModelInput {
    var searchPokemonObserver: AnyObserver<String> { get }
}

protocol PokeSearchViewModelOutput {
    var changeModelObservable: Observable<Void> { get }
    var model: PokemonModel { get }
}

final class PokeSearchViewModel: PokeSearchViewModelInput, PokeSearchViewModelOutput, HasDisposeBag {
    
    private let _searchPokemon = PublishRelay<String>()
    lazy var searchPokemonObserver: AnyObserver<String> = .init(eventHandler: { (event) in
        guard let e = event.element else { return }
        self._searchPokemon.accept(e)
    })
    
    private let _changeModelObservable = PublishRelay<Void>()
    lazy var changeModelObservable = _changeModelObservable.asObservable()
    
    private(set) var model = PokemonModel(id: 000, name: "MissingNo.", image: PokemonModel.Sprites(defaultImage: "MissingNo."))
    
    init() {
        _searchPokemon.flatMapLatest({ (searchPokemon) -> Observable<PokemonModel> in
            PokeAPI.shared.rx.get(searchID: searchPokemon)
        }).map { [weak self] (model) -> Void in
            self?.model = model
            return
        }.bind(to: _changeModelObservable).disposed(by: disposeBag)
    }
}
