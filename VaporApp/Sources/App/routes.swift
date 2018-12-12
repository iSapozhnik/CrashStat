import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example

    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.get("1", use: todoController.customTodos)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    
    let appInfoController = AppInfoController()
    router.get { req in
        return try appInfoController.index(req)
    }
    
    router.get("crash", use: appInfoController.crash)
    
//    router.post("crash/ios/prod") { req in
//        return HTTPStatus.ok
//    }
//    router.post("crash/android/prod") { req in
//        return HTTPStatus.ok
//    }
    router.post("crash/ios/prod", use: appInfoController.createIOSCrashProd)
    router.post("crash/ios/alpha", use: appInfoController.createIOSCrashAlpha)
    router.post("crash/ios/beta", use: appInfoController.createIOSCrashBeta)
    router.post("crash/ios/dev", use: appInfoController.createIOSCrashDev)
    
    router.post("crash/android/prod", use: appInfoController.createAndroidCrashProd)
    router.post("crash/android/alpha", use: appInfoController.createAndroidCrashAlpha)
    router.post("crash/android/beta", use: appInfoController.createAndroidCrashBeta)
    router.post("crash/android/dev", use: appInfoController.createAndroidCrashDev)

}
