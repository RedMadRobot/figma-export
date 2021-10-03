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
            Text("Body")
                .font(.body())
            Text("Caption")
                .font(.caption())
            if #available(iOS 14.0, *) {
                Text("Uppercased")
                    .textCase(.uppercase)
                    .font(.uppercased())
            }
            Spacer()
        }
        .foregroundColor(.textSecondary)
    }
}

struct TypographyView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyView()
    }
}
