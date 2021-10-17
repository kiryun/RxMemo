//
//  MemoListViewController.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx


class MemoListViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoListViewModel!
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func bindViewModel() {
        // viewModel의 title을 navigation title과 바인딩
        self.viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        // 메모 목록을 table view에 바인딩
        // observable과 tableview를 바인딩
        self.viewModel.memoList
            .bind(to: self.listTableView.rx.items(cellIdentifier: "cell")){ row, memo, cell in
                // datasource 구현 없이 이렇게 짧은 코드로 table view의 데이터를 표시 할 수 있음.
                // closure에서 cell구성만 구현해주면 된다.
                cell.textLabel?.text = memo.content
            }
            .disposed(by: rx.disposeBag)
        
        // addButton과 action을 바인딩한다.
        self.addButton.rx.action = self.viewModel.makeCreateAction()
        
        // 1. table view에서 memo를 선택하면 view model을 통해 detail action을 전달하고
        // 2. 선택한 cell은 선택 해제 한다.
        // 1. 번은 선택한 메모가 필요하고
        // 2. 번은 indexPath가 필요하다.
        // RxCocoa는 선택 이벤트에 사용하는 다양한 멤버를 extension으로 제공한다.
        // 선택한 indexPath가 필요한 경우 itemSelected 속성을 사용하고
        // 선택한 data 즉, 메모가 필요하다면 modelSelected를 활용
        // 여기서는 두 멤버를 모두 활용
        // 먼저 zip 연산자로 두멤버가 리턴하는 Observable을 병합한다. -> 이렇게 하면 선택된 메모와 indexPath가 튜플형태로 방출됨
        // do연산자를 추가하고 next 이벤트가 전달되면 선택상태를 해제
        // 선택 상태를 처리했기 때문에 이후에는 indexPath가 필요없음 그래서 맵연사자를 통해 data만 방출하도록 한다
        // 마지막으로 전달된 액션을 detailAction과 바인딩
        // 이렇게 하면 선택된 메모가 Action으로 전달되고 Action에 구현되어 있는 코드가 실행된다.
        Observable.zip(listTableView.rx.modelSelected(Memo.self), self.listTableView.rx.itemSelected)
            .do(onNext: { [unowned self] (_, IndexPath) in
                self.listTableView.deselectRow(at: IndexPath, animated: true)
            })
                .map { $0.0 }
                .bind(to: self.viewModel.detailAction.inputs)
                .disposed(by: rx.disposeBag)
        
        // swipe to delete 모드를 활성화 delegate method를 활용하지 않고 RxCocoa가 제공해주는 메서드를 활용(modelDeleted)
        // modelDelted는 ControlEvent를 리턴한다. 그리고 메모를 삭제할 때마다 next이벤트를 방출한다.
        // ControlEvent와 액션을 바인딩
        // 이렇게 삭제와 관련된 ControlEvent를 구독하면 swipe to delete가 자동으로 활성화 된다.
        self.listTableView.rx.modelDeleted(Memo.self)
            .bind(to: self.viewModel.deleteAction.inputs)
            .disposed(by: rx.disposeBag)
    }
}
