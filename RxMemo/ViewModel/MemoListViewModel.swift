//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxDataSources

// 우리가 사용할 섹션 모델: 섹션데이터 타입은 Int, 로우데이터 타입은 Memo
typealias MemoSectionModel = AnimatableSectionModel<Int, Memo>

class MemoListViewModel: CommonViewModel{
    
    // table view 바인딩에 사용할 dataSource를 선언
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        //
        let ds = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: { (dataSource, tableView, indexPath, memo) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = memo.content
            
            return cell
        })
        
        ds.canEditRowAtIndexPath = { _, _ in return true }
        return ds
    }()
    
    
    // table view 와 바인딩할 속성을 추가
    var memoList: Observable<[MemoSectionModel]>{
        return self.storage.memoList()
    }
    
    
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action{ input in
            // 작업은 save인데 왜 메모를 update하냐면, 아래 makeCreateAction에서 self.storage.createMemo를 호출하고 있다. 미리 Memo를 생성하고 있음. 이 생성한 메모를 업데이트 하는 방식임.
            // Action을 보면 입력이 String으로 되어 있다. Action<String, ...>
            // 출력이 Void로 되어 있음. Action<..., Void> 다시 말해 Observable이 방출하는 형식이 Void라는 얘기
            // 그러나 update 메서드가 방출하는 Observable은 편집된 메모를 방출함. Observable<Memo> 형식임.
            // .map을 이용해 간단하게 해결 가능
            return self.storage.update(memo: memo, content: input)
                .map{ _ in
                    
                }
            
        }
    }
    
    func performCancel(memo: Memo) -> CocoaAction{
        return Action{
            // 생성된 메모를 삭제
            // 작업은 cancel인데 왜 메모를 삭제하냐면, 아래 makeCreateAction에서 self.storage.createMemo를 호출하고 있다. 미리 Memo를 생성하고 있음. 따라서 메모를 삭제
            return self.storage.delete(memo: memo).map { _ in
                
            }
        }
    }
    
    // addButton 과 바인딩할 action 구현
    func makeCreateAction() -> CocoaAction{
        return CocoaAction{ _ in
            // createMemo를 호출하면 새로운 memo가 생성되고 이 메모를 방출하는 observable이 리턴됨. MemoryStorage.swift
            // flatMap을 호출하고 flatMap의 closure에서 화면전환을 처리
            return self.storage.createMemo(content: "")
                .flatMap { memo -> Observable<Void> in
                    // view model 생성
                    let composeViewModel = MemoComposeViewModel(title: "새 메모", sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: memo), cancelAction: self.performCancel(memo: memo))
                    
                    // compseScene을 생성 연관값으로 view model을 저장
                    let composeScene = Scene.compose(composeViewModel)
                    // sceneCoordinator를 통해 transition 메서드를 호출하고 scene을 modal방식으로 표시
                    // transition메서드는 completable을 리턴하고 있음. 따라서 asObservable로 Observable을 방출하고 map 연산자로 Observable<Void> 연산자로 바꿔줘야 함.
                    return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true).asObservable().map { _ in
                        
                    }
                }
        }
    }
    
    // 입력은 Memo
    // 출력은 Void
    // closure 내부에서 self로 접근해야 하기 때문에 lazy로 선언
    lazy var detailAction: Action<Memo, Void> = {
        return Action{ memo in
            // view model을 생성 하고
            let detailViewModel = MemoDetailViewModel(memo: memo, title: "메모 보기", sceneCoordinator: self.sceneCoordinator, storage: self.storage)
            
            // scene을 생성하고
            let detailScene: Scene = Scene.detail(detailViewModel)
            
            // transition 메서드를 호출하고 observable을 이용해 action을 return 해준다. push방식으로 표시
            return self.sceneCoordinator.transition(to: detailScene, using: .push, animated: true).asObservable().map{ _ in }
        }
    }()
    
    // 삭제 기능
    lazy var deleteAction: Action<Memo, Swift.Never> = {
        // 메모를 삭제하는 기능만 구현하면 된다. 이전으로 돌아가는 액션은 필요없음
        return Action{ memo in
            return self.storage.delete(memo: memo).ignoreElements()
        }
    }()
    
    
}
