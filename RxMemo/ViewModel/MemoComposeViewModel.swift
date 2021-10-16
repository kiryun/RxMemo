//
//  MemoComposeViewModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift
import RxCocoa
// 해당 모듈은 compose scene에서 사용. compose scene은 새로운 메모를 추가할 때, 편집할 때 공통적으로 사용한다.
import Action

class MemoComposeViewModel: CommonViewModel{
    private let content: String?
    
    var initialText: Driver<String?> {
        return Observable.just(self.content).asDriver(onErrorJustReturn: nil)
    }
    
    let saveAction: Action<String, Void>
    let cancelAction: CocoaAction
    
    // view model에서 취소 코드와 저장코드를 직접 구현해도 되지만 처리방식이 하나로 고정된다.
    // 반면 이렇게 파라미터로 받으면 이전화면에서 처리방식을 동적으로 결정할 수 있다는 장점이 있다.
    init(title: String, content: String? = nil, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType, saveAction: Action<String, Void>? = nil, cancelAction: CocoaAction? = nil){
        self.content = content
        
        // saveAction이 optional로 선언되어 있다.
        // saveAction에 그대로 저장하지 않고 전달된 Action을 Action으로 한번 더 래핑해서 저장
        self.saveAction = Action<String, Void> { input in
            // action이 전달되었다면 실제로 action을 실행하고 화면을 닫는다.
            if let action = saveAction{
                action.execute(input)
            }
            
            // 반대로 action이 전달되지 않았다면 화면만 닫고 끝난다.
            return sceneCoordinator.close(animated: true).asObservable().map { _ in
                
            }
        }
        
        // cancelAction도 같은 방법
        self.cancelAction = CocoaAction{
            if let action = cancelAction{
                action.execute()
            }
            
            return sceneCoordinator.close(animated: true).asObservable().map { _ in
                
            }
        }
        
        //
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
}
