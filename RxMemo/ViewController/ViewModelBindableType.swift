//
//  ViewModelBindableType.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit

protocol ViewModelBindableType{
    // ViewModel의 타입은 ViewController마다 달라짐 따라서 Generic으로 선언
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

// ViewController에 추가된 ViewModel속성에 실제 ViewModel을 저장하고
// bindViewModel을 자동으로 호출하는 메서드를 구현
extension ViewModelBindableType where Self: UIViewController{
    mutating func bind(viewModel: Self.ViewModelType){
        // 개별 ViewController에서 bindViewModel을 직접 호출 할 필요가 없어짐
        self.viewModel = viewModel
        loadViewIfNeeded()
        
        self.bindViewModel()
    }
}
