//
//  SceneCoordinator.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift
import RxCocoa


class SceneCoordinator: SceneCoordinatorType{
    
    // 리소스 정리
    private let bag = DisposeBag()
    
    // SceneCoordinator는 화면전환을 담당하기 때문에 window 인스턴스와 현재 화면의 scene을 갖고 있어야 함.
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow){
        self.window = window
        self.currentVC  = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        // 전환 결과를 방출할 subject
        let subject = PublishSubject<Void>()
        
        // scene 생성 후 target에 저장
        let target = scene.instantiate()
        
        // transition에 따라서 실제 전환 처리
        switch style{
        case .root:
            // root인 경우는 그냥 rootViewConroller를 바꿔 주면 됨
            self.currentVC = target
            window.rootViewController = target
            // 마지막으로 completed 이벤트 발생
            subject.onCompleted()
            
        case .push:
            // push는 navigation controller에 임베드되어 있을 때만 의미가 있음.
            guard let nav = currentVC.navigationController else{
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            nav.pushViewController(target, animated: animated)
            self.currentVC = target
            
            subject.onCompleted()
            
        case .modal:
            self.currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
        
            self.currentVC = target
        }
        
        // https://hyunsikwon.github.io/swift/Swift-RxSwift-02/
        // subject에 ignoreElements를 호출하면 Observable이 return 되는데
        // Completable로 변환하기 위해 asCompletable 호출 
        return subject.ignoreElements().asCompletable()
    }
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            // view controller가 modal 방식으로 표시되어 있다면 현재 scene을 dismiss
            if let presentingVC = self.currentVC.presentingViewController{
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC
                    completable(.completed)
                }
            }else if let nav = self.currentVC.navigationController{
                // navigation stack 에 push되어 있다면
                // pop
                guard nav.popViewController(animated: animated) != nil else{
                    // pop 못하면 error 전달 후 종료
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                
                self.currentVC = nav.viewControllers.last!
                completable(.completed)
            }else{
                completable(.error(TransitionError.unknown))
            }
            
            return Disposables.create()
        }
    }
    
    
}

