//
//  MemoDetailViewController.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit
import RxSwift
import RxCocoa

class MemoDetailViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoDetailViewModel!
    
    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func bindViewModel() {
        // navigation title을 바인딩 한다.
        self.viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        // table view를 바인딩
        self.viewModel.contents
            .bind(to: self.listTableView.rx.items){ tableView, row, value in
                switch row{
                case 0:
                    // 0번째 cell이면 contentCell을 받아와서 label에 문자열을 표시하고 리턴
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell")!
                    cell.textLabel?.text = value
                    
                    return cell
                case 1:
                    // 1번째 cell이면 dateCell을 받아와서 label에 문자열을 표시하고 리턴
                    let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell")!
                    cell.textLabel?.text = value
                    
                    return cell
                default:
                    fatalError()
                }
            }
            .disposed(by: rx.disposeBag)
        
        // editButton의 액션에 view model의 makeEditAction 과 바인딩해 준다.
        self.editButton.rx.action = self.viewModel.makeEditAction()
        
        // 삭제 버튼과 삭제 액션을 바인딩
        self.deleteButton.rx.action = self.viewModel.makeDeleteAction()
        
        // 공유 버튼 바인딩
        // 더블 탭 방지
        // 구독자 추가
        self.sharebutton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let memo = self?.viewModel.memo.content else { return }
                
                let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: rx.disposeBag)

    }
}
