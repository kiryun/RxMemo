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
    }
}
