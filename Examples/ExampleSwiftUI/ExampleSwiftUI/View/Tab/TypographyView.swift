//
//  TypographyView.swift
//  ExampleSwiftUI
//
//  Created by Daniil Subbotin on 10.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SwiftUI

struct TypographyView: View {
    
    var body: some View {
        TabStackedView(tabTitle: "Typography") {
            Text("Header")
                .font(.header())
                .foregroundColor(.textPrimary)
            Text("Body")
                .font(.body())
                .foregroundColor(.textPrimary)
            Text("Caption")
                .font(.caption())
                .foregroundColor(.textPrimary)
            Spacer()
        }
    }
}

struct TypographyView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyView()
    }
}
