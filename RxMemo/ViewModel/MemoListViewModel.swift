//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/15.
//

import Foundation
import RxSwift
import RxCocoa

class MemoListViewModel: CommonViewModel{
    // table view 와 바인딩할 속성을 추가
    var memoList: Observable<[Memo]>{
        return self.storage.memoList()
    }
    
    
}
