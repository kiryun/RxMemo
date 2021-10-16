//
//  SceneCoordinator.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift
import RxCocoa

extension UIViewController{
    // 실제로 화면에 표시되고 있는 ViewController를 리턴해주는 속성을 추가 해준다.
    var sceneViewController: UIViewController{
        // navigation controller와 같은 컨테이너 viewcontroller라면 마지막 child를 리턴하고 나머지 경우에는 self를 그대로 리턴하고 있다.
        // 지금은 navigation controller만 고려했지만, tab bar controller나 다른 컨테이터 controller를 사용한다면 거기에 맞게 수정해줘야 함.
        return self.children.first ?? self
    }
}

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
            self.currentVC = target.sceneViewController
            self.window.rootViewController = target
            // 마지막으로 completed 이벤트 발생
            subject.onCompleted()
            
        case .push:
            print(self.currentVC)
            // push는 navigation controller에 임베드되어 있을 때만 의미가 있음.
            guard let nav = self.currentVC.navigationController else{
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            // willShow는 델리게이트 메서드가 호출되는 시점 마다 next 이벤트를 방출하는 컨트롤 이벤트이다.
            // 여기에 구독자를 추가하고 currentVC속성을 업데이트한다.
            nav.rx.willShow
                .subscribe({ evt in
                    if let element = evt.element{
                        self.currentVC = element.viewController.sceneViewController
                    }
                })
                .disposed(by: bag)

            
            nav.pushViewController(target, animated: animated)
            self.currentVC = target.sceneViewController
            
            subject.onCompleted()
            
        case .modal:
            self.currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
        
            self.currentVC = target.sceneViewController
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
                    self.currentVC = presentingVC.sceneViewController
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

