//
//  MemoComposeViewController.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

class MemoComposeViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoComposeViewModel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        // navigation title을 바인딩
        self.viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        // initialText를 contentTextView에 바인딩
        // 메모 쓰기에서는 빈 문자열이 표시 되고
        // 편집 에서는 편집할 메모가 표시됨
        self.viewModel.initialText
            .drive(self.contentTextView.rx.text)
            .disposed(by: rx.disposeBag)
        
        
        // cancelButton은 cancelAction과 바인딩
        // action패턴으로 action을 구현할 때는 이렇게 action속성에 저장하는 방식으로 바인딩한다.
        // 취소 버튼을 탭하면 cancelAction에 래핑되어 있는 코드가 실행된다.
        self.cancelButton.rx.action = self.viewModel.cancelAction
        
        // saveButton을 탭하면 현재 메모를 저장해야 함.
        // tap속성에 바인딩 할건데
        // 더블탭 방지를 위해 throttle을 이용해 0.5초 마다 한번씩만 탭을 처리
        // withLatestFrom으로 contentTextView에 입력된 텍스트를 방출
        // 방출된 텍스트를 saveAction과 바인딩
        self.saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(self.contentTextView.rx.text.orEmpty)
            .bind(to: self.viewModel.saveAction.inputs)
            .disposed(by: rx.disposeBag)
    }
    
    // 키보드가 바로 활성화 될 수 있도록 becomeFirstResponder 설정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contentTextView.becomeFirstResponder()
    }
    
    // 이전 Scene으로 돌아가기 이전에 firstResponder 해제
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.contentTextView.isFirstResponder{
            self.contentTextView.resignFirstResponder()
        }
    }

}
