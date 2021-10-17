//
//  Model.swift
//  RxMemo
//
//  Created by Gihyun Kim on 2021/10/14.
//

import Foundation
// RxDataSources는 table view와 collection view의 바인딩할 수 잇는 데이터 소스를 제공한다.
import RxDataSources

// DataSource에 저장되는 모든 데이터는 반드시 IdentifiableType을 채용해야함.
struct Memo: Equatable, IdentifiableType{
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
