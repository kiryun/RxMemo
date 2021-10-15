//
//  TransitionModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation

// 화면 전환 방식
enum TransitionStyle{
    case root
    case push
    case modal
}

// 화면 전환 시 에러 정의
enum TransitionError: Error{
    case navigationControllerMissing
    case cannotPop
    case unknown
}
