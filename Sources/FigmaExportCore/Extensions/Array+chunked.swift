//
//  File.swift
//  
//
//  Created by i.kharabet on 19.02.2021.
//

import Foundation

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
