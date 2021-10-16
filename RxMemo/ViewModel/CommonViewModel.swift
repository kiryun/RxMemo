//
//  CommonViewModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/16.
//

import Foundation
import RxSwift
import RxCocoa


class CommonViewModel: NSObject{
    // 앱을 구성하는 모든 Scnene은 navigationcotroller에 임베드 되기 때문에 navigation title이 필요하다.
    
    // navigation item에 쉽게 바인딩 할 수 있다.
    let title: Driver<String>
    
    //
    let sceneCoordinator: SceneCoordinatorType
    let storage: MemoStorageType
    
    init(title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType){
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.sceneCoordinator = sceneCoordinator
        self.storage = storage
    }
}
