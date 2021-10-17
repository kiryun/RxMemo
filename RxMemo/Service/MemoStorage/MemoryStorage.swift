//
//  MemoryStorage.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/14.
//

import Foundation
import RxSwift

// 메모리에 메모를 저장
class MemoryStorage: MemoStorageType{
    // 메모를 저장할 배열
    // 배열은 Observable로만 접근이 가능
    private var list = [
        // 더미데이터 2개 넣어주자
        Memo(content: "Hello World!", insertDate: Date().addingTimeInterval(-10)),
        Memo(content: "Wimes", insertDate: Date().addingTimeInterval(-20))
    ]
    
    private lazy var sectionModel = MemoSectionModel(model: 0, items: list)
    
    // Observable은 배열이 업데이트 될 때 마다 새로운 이벤트를 방출해야 하는데
    // 그냥 Observable로만은 불가능해서 subject로 구현해야 함
    // 초기에 더미 데이터를 보여줘야 하기 때문에 behavior subject를 사용해야 함
    // 기본값을 self.list로 하기 위해서 lazy로 선언했고
    // subject 역시 외부에서 집적접근이 불가능하게 private로 선언
    private lazy var store = BehaviorSubject<[MemoSectionModel]>(value: [self.sectionModel])
    
    @discardableResult
    func createMemo(content: String) -> Observable<Memo> {
        // 새로운 메모 생성 후 배열에 추가
        let memo = Memo(content: content)
        self.sectionModel.items.insert(memo, at: 0)
        
        // 그리고 subject에서 새로운 next 이벤트를 방출
        self.store.onNext([self.sectionModel])
        
        // 새로운 memo를 방출하는 Observable를 리턴
        return Observable.just(memo)
    }
    
    // 항상 얘를 통해서 subject에 접근
    @discardableResult
    func memoList() -> Observable<[MemoSectionModel]> {
        return self.store
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo> {
        let updated = Memo(original: memo, updatedContent: content)
        
        // 배열에 있는 원본 인스턴스를 새로운 인스턴스로 교체
        if let index = self.sectionModel.items.firstIndex(where: { $0 == memo }){
            self.sectionModel.items.remove(at: index)
            self.sectionModel.items.insert(updated, at: index)
        }
        
        // 그리고 subject에서 새로운 next 이벤트를 방출
        self.store.onNext([self.sectionModel])
        
        // 업데이트된 memo를 방출하는 Observable를 리턴
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {
        if let index = self.sectionModel.items.firstIndex(where: { $0 == memo} ){
            self.sectionModel.items.remove(at: index)
        }
        
        // 그리고 subject에서 새로운 next 이벤트를 방출
        self.store.onNext([self.sectionModel])
        
        // 삭제한 memo를 방출하는 Observable를 리턴
        return Observable.just(memo)
    }
    
    
}

/*
 위에 구현된 방식을 보면 배열을 변경한 다음 subject를 새로운 next 이벤트를 방출하고 있다.
 이러한 방식으로 구현해야 나중에 table view 바인딩할 때 정상적으로 업데이트 됨
 cocoa에서 사용하던 reloaddata로는 table view가 업데이트가 안된다.
 */
