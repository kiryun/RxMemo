//
//  MemoDetailViewModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift
import RxCocoa
import Action


class MemoDetailViewModel: CommonViewModel{
    
    // 이전 scene에서 전달된 메모가 저장
    let memo: Memo
    
    // formatter는 날짜를 string으로 변환해준다.
    private var formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "Ko_kr")
        f.dateStyle = .medium
        f.timeStyle = .medium
        
        return f
    }()
    
    
    // 첫번째 cell에는 메모 목록이 표시되고, 두번째 cell에는 날짜가 표시됨.
    // table view의 데이터를 표시할 때는 observable과 바인딩함.
    // table view에 표시할 데이터는 문자열 2개인데 그래서 [String]으로 배열로 지정
    // 왜 BehaviorSubject를 사용했냐면, 메모를 편집한 다음에 다시 보기화면으로 오면 편집한 내용이 반영되어야 함.
    // 이렇게 하려면 새로운 문자열 배열을 방출해야함 일반 Observable을 방출하면 이게 안됨. 그래서 BehaviorSubject를 사용
    var contents: BehaviorSubject<[String]>
    
    init(memo: Memo, title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType){
        self.memo = memo
        
        self.contents = BehaviorSubject<[String]>(value: [
            memo.content,
            self.formatter.string(from: memo.insertDate)
        ])
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    // 뒤로가기 버튼(나의 메모 버튼) 과 바인딩할 Action 추가
    lazy var popAction = CocoaAction{ [unowned self] in
        // Action 내부에서는 sceneCoordinator에 있는 close 메서드를 호출
        return self.sceneCoordinator.close(animated: true).asObservable().map{ _ in }
        
    }
    
    // 메모를 편집하고 저장버튼을 탭하면 이 메서드가 호출
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action{ input in
            // 새로운 subscribe를 추가하고 subject로 업데이트된 메모를 전달
            // disposeBag으로 리소스를 정리
            self.storage.update(memo: memo, content: input)
                .subscribe { updated in
                    // 여기서 새로운 내용을 subject로 전달하니까 subject는 이 내용을 next이벤트에 담아서 방출
                    // 그럼 subject와 바인딩되어 있는 table view가 새로운 내용으로 업데이트 된다.
                    self.contents.onNext([
                        updated.content,
                        self.formatter.string(from: updated.insertDate)
                    ])
                }
                .disposed(by: self.rx.disposeBag)
            
            // 빈 Observable을 리턴
            return Observable.empty()
            
        }
    }
    
    func makeEditAction() -> CocoaAction{
        return CocoaAction{ _ in
            // 새로운 메모 생성
            // title은 "메모 편집"
            // content에 들어갈 내용은 self.content
            // cancel은 따로 Action이 필요가 없음.
            // 나머지는 ListViewModel과 동일
            let composeViewModel = MemoComposeViewModel(title: "메모 편집", content: self.memo.content, sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: self.memo))
            
            let composeScene = Scene.compose(composeViewModel)
            
            return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true).asObservable().map { _ in
                
            }
        }
    }
}
