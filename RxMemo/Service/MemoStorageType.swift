//
//  MemoStorageType.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/14.
//

import Foundation
import RxSwift

// MARK: CRUD
protocol MemoStorageType{
    // 구독자가 원하는 방식으로 처리학 위해 Observable 로 리턴
    @discardableResult
    func createMemo(content: String) -> Observable<Memo>
    
    @discardableResult
    func memoList() -> Observable<[Memo]>
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo>
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo>
}
