//
//  WidgetStepCountBundle.swift
//  WidgetStepCount
//
//  Created by alan eckhaus on 4/15/25.
//

import WidgetKit
import SwiftUI

@main
struct WidgetStepCountBundle: WidgetBundle {
    var body: some Widget {
        WidgetStepCount()
        WidgetStepCountControl()
    }
}
