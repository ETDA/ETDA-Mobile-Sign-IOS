//
//  UserDefaultsExtension.swift
//  tedasign
//
//  Created by Pawan Pankhao on 6/9/2564 BE.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: "tedasign.app")
        return combined
    }
}
