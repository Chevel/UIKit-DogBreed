//
//  Bundle+Configuration.swift
//  DogBreed
//
//  Created by Matej on 12/11/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

extension Bundle {
    
    enum Configuration {
        enum Scene {
            static var configurationName: String {
                guard
                    let appManifest = Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") as? Dictionary<String, Any>,
                    let sceneConfig = appManifest["UISceneConfigurations"] as? Dictionary<String, Any>,
                    let windowSceneSessionRoleApp = sceneConfig["UIWindowSceneSessionRoleApplication"] as? [Dictionary<String, Any>],
                    let name = windowSceneSessionRoleApp[0]["UISceneConfigurationName"] as? String
                else {
                    preconditionFailure("Project configuration error. Missing configuration for Scene entry in info.plist")
                }
                
                return name
            }
        }
        enum CoreData {
            static var persistenceContainerName: String {
                guard
                    let appManifest = Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") as? Dictionary<String, Any>,
                    let sceneConfig = appManifest["UISceneConfigurations"] as? Dictionary<String, Any>,
                    let custom = sceneConfig["Custom"] as? Dictionary<String, Any>,
                    let coreData = custom["CoreData"] as? Dictionary<String, Any>,
                    let name = coreData["PersistentContainer"] as? String
                else {
                    preconditionFailure("Project configuration error. Missing configuration for CoreData persistence container entry in info.plist")
                }
                
                return name
            }
        }
    }

}
