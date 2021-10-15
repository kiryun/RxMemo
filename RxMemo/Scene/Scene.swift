//
//  Scene.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import UIKit


// 앱에서 구현할 Scene을 열거형으로 선언
enum Scene{
    case list(MemoListViewModel)
    case detail(MemoDetailViewModel)
    case compose(MemoComposeViewModel)
}

// storyboard에 있는 Scene을 생성하고 연관값에 저장된 ViewModel을 바인딩해서 return 하는 메서드 구현
extension Scene{
    func instantiate(from storyboard: String = "Main") -> UIViewController{
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self{
        case .list(let viewModel):
            // 메모목록을 생성한 다음 viewmodel을 바인딩해서 return
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ListNav") as? UINavigationController else{
                fatalError()
            }
            
            guard var listVC = nav.viewControllers.first as? MemoListViewController else{
                fatalError()
            }
            
            // viewModel은 NavigationController에 임베드되어 있는 rootViewController 바인딩하고
            listVC.bind(viewModel: viewModel)
            // return할 때는 navigation controller를 return
            return nav
        case .detail(let viewModel):
            // detailVC의 경우 항상 navigation stack에 push되기 때문에 navigation controller를 고려할 필요가 없음
            guard var detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? MemoDetailViewController else{
                fatalError()
            }
            detailVC.bind(viewModel: viewModel)
            return detailVC
        case .compose(let viewModel):
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController else{
                fatalError()
            }
            
            guard var composeVC = nav.viewControllers.first as? MemoComposeViewController else{
                fatalError()
            }
            
            composeVC.bind(viewModel: viewModel)
            return nav
        }
    
    }
}
