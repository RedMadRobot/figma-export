//
//  IllustrationsView.swift
//  ExampleSwiftUI
//
//  Created by Daniil Subbotin on 11.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SwiftUI

struct IllustrationsView: View {
    var body: some View {
        TabStackedView(tabTitle: "Illustrations") {
            Image.imgZeroEmpty
            Image.imgZeroError
            Image.imgZeroInternet
            Spacer()
        }
    }
}

struct IllustrationsView_Previews: PreviewProvider {
    static var previews: some View {
        IllustrationsView()
    }
}
