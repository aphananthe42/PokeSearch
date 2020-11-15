//
//  SearchPokemonViewController.swift
//  PokeSearch
//
//  Created by Ryota Miyazaki on 2020/11/14.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import NSObject_Rx

final class PokeSearchViewController: UIViewController, HasDisposeBag {

    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    private let viewModel = PokeSearchViewModel()
    private lazy var input: PokeSearchViewModelInput = viewModel
    private lazy var output: PokeSearchViewModelOutput = viewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputStream()
        bindOutputStream()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func bindInputStream() {
        let searchPokemonObservable = searchTextField.rx.text
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filterNil()
        
        searchPokemonObservable.bind(to: input.searchPokemonObserver).disposed(by: disposeBag)
    }
    
    private func bindOutputStream() {
        output.changeModelObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: {
            self.numberLabel.text = String(self.output.model.id)
            self.nameLabel.text = self.output.model.name
            self.imageView.image = self.getImageByUrl(url: self.output.model.image.defaultImage)
            print(self.output.model.image.defaultImage)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    private func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch {
            return UIImage(named: "MissingNo.")!
        }
    }

}
