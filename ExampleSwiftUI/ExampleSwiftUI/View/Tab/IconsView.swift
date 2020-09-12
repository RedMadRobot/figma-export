//
//  IconsView.swift
//  ExampleSwiftUI
//
//  Created by Daniil Subbotin on 11.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SwiftUI

struct IconsView: View {
    var body: some View {
        TabStackedView(tabTitle: "Icons") {
            Image.ic16KeyEmergency
            Spacer()
        }
        .foregroundColor(.tint)
    }
}

struct IconsView_Previews: PreviewProvider {
    static var previews: some View {
        IconsView()
    }
}
