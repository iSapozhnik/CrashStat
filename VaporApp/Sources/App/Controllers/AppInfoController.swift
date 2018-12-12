//
//  AppInfoController.swift
//  App
//
//  Created by Ivan Sapozhnik on 11/9/18.
//

import Vapor
import Fluent

final class AppInfoController {
    func index(_ req: Request) throws -> Future<[AppInfo]> {
        return AppInfo.query(on: req).all()
    }
    
    func crash(_ req: Request) throws -> Future<Crash> {
        let androidCrashes = AppInfo.query(on: req).filter(\.appPlatform == "android").all()
        let iosCrashes = AppInfo.query(on: req).filter(\.appPlatform == "ios").all()
        
        return [androidCrashes, iosCrashes].flatten(on: req).map({ array -> (Crash) in
            var ios = 0
            var android = 0
            
            array.forEach({ appInfosArray in
                appInfosArray.forEach({ info in
                    if info.appPlatform == "ios" {
                        ios += info.crashes ?? 0
                    } else {
                        android += info.crashes ?? 0
                    }
                })
            })
            
            return Crash(iosCount: ios, androidCount: android)
        })
        
        
//        let android = AppInfo.query(on: req).filter(\.appPlatform == "android").count()
//        return AppInfo.query(on: req).filter(\.appPlatform == "ios").count().and(android).map { (ios, android) -> Crash in
//            return Crash(iosCount: ios, androidCount: android)
//        }
    }
    
    func createIOSCrashProd(_ req: Request) throws -> Future<AppInfo> {
        let decode = try req.content.decode(AppInfo.self)
        return decode.flatMap { appInfo -> EventLoopFuture<AppInfo> in
            let query = AppInfo.query(on: req).filter(\AppInfo.issueId == appInfo.issueId).first()
            return query.flatMap({ existingIssue -> EventLoopFuture<AppInfo> in
                if let issueId = existingIssue?.id {
                    appInfo.id = issueId
                    return appInfo.update(on: req)
                } else {
                    return appInfo.save(on: req)
                }
            })
        }
    }
    
    func createIOSCrashAlpha(_ req: Request) throws -> Future<AppInfo> {
        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            appInfo.platform = Platform.ios.rawValue
//            appInfo.app = App.alpha.rawValue
            return appInfo.save(on: req)
        }
    }
    
    func createIOSCrashBeta(_ req: Request) throws -> Future<AppInfo> {
        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            appInfo.platform = Platform.ios.rawValue
//            appInfo.app = App.beta.rawValue
            return appInfo.save(on: req)
        }
    }
    
    func createIOSCrashDev(_ req: Request) throws -> Future<AppInfo> {
        print("CRASH!")

//        AppInfo.query(on: req).filter(\.issueId == "issueId").first().flatMap { info -> AppInfo? in
//            return info.update(on: req)
//        }

        
//        let iOSCrashes = Future<Int>
//        let androidCrashes = Future<Int>
//        return [iOSCrashes, androidCrashes].flatten().map { return $0 }
        
        let decode = try req.content.decode(AppInfo.self)
        return decode.flatMap { appInfo -> EventLoopFuture<AppInfo> in
            let query = AppInfo.query(on: req).filter(\AppInfo.issueId == appInfo.issueId).first()
            return query.flatMap({ existingIssue -> EventLoopFuture<AppInfo> in
                if let issueId = existingIssue?.id {
                    appInfo.id = issueId
                    return appInfo.update(on: req)
                } else {
                    return appInfo.save(on: req)
                }
            })
        }
        
//        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            return AppInfo.query(on: req).filter(\AppInfo.issueId == appInfo.issueId).first().flatMap({ info -> AppInfo in
//                guard let info = info, let infoId = info.id else { return appInfo.save(on: req) }
//                info.update(on: req)
//            })
//        }
    }
    
    ////////////////////
    
    func createAndroidCrashProd(_ req: Request) throws -> Future<AppInfo> {
        let decode = try req.content.decode(AppInfo.self)
        return decode.flatMap { appInfo -> EventLoopFuture<AppInfo> in
            let query = AppInfo.query(on: req).filter(\AppInfo.issueId == appInfo.issueId).first()
            return query.flatMap({ existingIssue -> EventLoopFuture<AppInfo> in
                if let issueId = existingIssue?.id {
                    appInfo.id = issueId
                    return appInfo.update(on: req)
                } else {
                    return appInfo.save(on: req)
                }
            })
        }
    }
    
    func createAndroidCrashAlpha(_ req: Request) throws -> Future<AppInfo> {
        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            appInfo.platform = Platform.android.rawValue
//            appInfo.app = App.alpha.rawValue
            return appInfo.save(on: req)
        }
    }
    
    func createAndroidCrashBeta(_ req: Request) throws -> Future<AppInfo> {
        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            appInfo.platform = Platform.android.rawValue
//            appInfo.app = App.beta.rawValue
            return appInfo.save(on: req)
        }
    }
    
    func createAndroidCrashDev(_ req: Request) throws -> Future<AppInfo> {
        return try req.content.decode(AppInfo.self).flatMap { appInfo in
//            appInfo.platform = Platform.android.rawValue
//            appInfo.app = App.dev.rawValue
            return appInfo.save(on: req)
        }
    }
}
