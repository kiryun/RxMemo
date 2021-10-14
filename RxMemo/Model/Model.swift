//
//  Model.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/14.
//

import Foundation

struct Memo: Equatable{
    var content: String
    var insertDate: Date
    var identity: String
    
    init(content: String, insertDate: Date = Date()){
        self.content = content
        self.insertDate = insertDate
        // 시간 값으로 identity 생성
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    // 업데이트된 내용으로 새로운 인스턴스를 생성할 때 사용
    init(original: Memo, updatedContent: String){
        self = original
        self.content = updatedContent
    }
}
