//
//  SceneCoordinatorType.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift


protocol SceneCoordinatorType{
    // 아래 두 메서드 모두 Completable을 리턴하는데 여기에 구독자를 추가하고 화면 작업이 완료된 다음 원하는 작업을 구현할 수 있음.
    // 새로운 Scene을 표시
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    
    // 현재 Scene을 닫고 이전 Scene으로 돌아감
    @discardableResult
    func close(animated: Bool) -> Completable
}
