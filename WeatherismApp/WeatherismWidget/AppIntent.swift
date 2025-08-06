//
//  AppIntent.swift
//  WeatherismWidget
//
//  Created by Ammar Sufyan on 06/08/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Weather Configuration" }
    static var description: IntentDescription { "Configure your weather widget settings." }

    // Widget refresh interval preference
    @Parameter(title: "Auto Refresh", default: true)
    var autoRefresh: Bool
}
