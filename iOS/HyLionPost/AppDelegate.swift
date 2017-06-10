import UIKit
import CoreData
import CoreLocation
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

/**
 *  @author
 *      이영식
 *  @date
 *      17` 05. 19
 *  @brief
 *      어플리케이션 Delegate
 *  @discussion
 *
 *  @todo :
 *      - 아카이브 데이터 불러오기/저장하기
 *      - 푸시알림이 포어그라운드/백그라운드 에서 발생할 경우 각각 처리
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    var window: UIWindow?
    var dataManager = DataManager()
    
    /// Firebase에 연결
    func connectToFcm() {
        // 토큰 생성이 되지 않을 경우 return
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        
        // 만약 이전 연결이 존재 하는 경우 끊고 다시 연결
        FIRMessaging.messaging().disconnect()
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    /// 토큰 값 변경 관찰자가 수행할 함수
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // 토큰이 생성되기 전에 연결을 시도하면, 연결에 실패하게 됨
        connectToFcm()
    }
    
    /// 앱이 시작할 준비를 마치고 실행되기 전 실행되는 함수
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /**
            @TEST
                테스트를 위해 실행되는 코드
         */
        dataManager.supportedBoards["csnotice"]?.articles = ["2232" : Article(title:"2017-1학기 공통기초과학과목 기말시험 일정 안내", groupid:"csnotice", key:"2232", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-23", archived:false),
            "1332" : Article(title:"2017-2학기 국가장학금1,2유형 (1차) 신청 안내", groupid:"csnotice", key:"1332", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-22", archived:false),
            "65785" : Article(title:"2016-2학기 공통기초과학과목 기말시험 일정 안내", groupid:"csnotice", key:"65785", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2016-11-23", archived:false),
            "63465" : Article(title:"2017-1학기 국가장학금1,2유형 (1차) 신청 안내", groupid:"csnotice", key:"63465", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2016-11-22", archived:false),
            "95554" : Article(title:"2017-1학기 교내장학 신청 일정 안내", groupid:"csnotice", key:"95554", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2016-11-21", archived:false)]
        
        dataManager.supportedBoards["csck2notice"]?.articles = ["321" : Article(title:"창의융합교육원 2017학년도 2학기 교양교육 설명회 안내", groupid:"csck2notice", key:"321", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-24", archived:true)]
        
        dataManager.supportedBoards["csgradu"]?.articles = [
            "83456" : Article(title:"2016학년도 2학기 지도교수 간담회 결과 보고", groupid:"csgradu", key:"83456", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2016-11-20", archived:false),
            "10345" : Article(title:"2016학년도 1학기 지도교수 간담회 결과 보고", groupid:"csgradu", key:"10345", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2016-05-20", archived:false),
            "3523" : Article(title:"2017학년도 1학기 지도교수 간담회 결과 보고", groupid:"csgradu", key:"3523", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-20", archived:true)]
        
        dataManager.supportedBoards["csjob"]?.articles = [:]
        
        dataManager.supportedBoards["csstrk"]?.articles = [
            "4456" : Article(title:"삼성전자 SCSC 2017학년도 2학기 설명회 안내", groupid:"csstrk", key:"4456", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-24", archived:false)]
        
        dataManager.supportedBoards["demon"]?.articles = [
            "1232" : Article(title:"2017-2학기 교내장학 신청 일정 안내", groupid:"demon", key:"1232", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-05-21", archived:false),
            "7564" : Article(title:"2017-1학기 교내장학 신청 일정 안내", groupid:"demon", key:"7564", url:"http://cs.hanyang.ac.kr/board/info_board.php", date:"2017-11-21", archived:true)]
         /**/
        
        FIRApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        /// 토큰 값의 변경 관찰자 추가
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            
            connectToFcm()
        }
        
        dataManager.ref = FIRDatabase.database().reference()
        
        return true
    }
    
    /// @brief
    ///     iOS 10 버전 미만에서 앱이 푸시 알림이 오는 경우 실행
    /// @Todo
    ///     - 공통                   알림 메시지 띄우기
    ///     - Active(Foreground)    메인 게시글 테이블의 상단에 데이터를 추가(애니메이션과 함께)
    ///     - Inactive(Foreground)  게시글 배열에 새 게시글 내용 추가
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if (application.applicationState == UIApplicationState.active ||
            application.applicationState == UIApplicationState.inactive) {
            print("userNotificationCenter foreground")
            // At Foreground - Firebaes로 부터 전달된 데이터 콘솔 출력
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            FIRMessaging.messaging().appDidReceiveMessage(userInfo)
            
            print("USERINFO FOREGROUND:")
            print(userInfo)
            
            // Change this to your preferred presentation option
            completionHandler(UIBackgroundFetchResult.noData)
        }
            
        else if (application.applicationState == UIApplicationState.background) {
            print("userNotificationCenter background")
            // At Background - Firebaes로 부터 전달된 데이터 콘솔 출력
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            FIRMessaging.messaging().appDidReceiveMessage(userInfo)
            
            // Firebaes로 부터 전달된 유저정보 출력
            print("USERINFO BACKGROUND:")
            print(userInfo)
            
            // Change this to your preferred presentation option
            completionHandler(UIBackgroundFetchResult.newData)
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
    }
    
    /// 토큰 등록이 성공한 경우 실행되는 함수, 생성된 토큰 값을 전달해준다
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        print("Successful registration. Token is:\(deviceToken)")
    }
    
    
    /// 토큰 등록이 실패한 경우 실행되는 함수, 실패 정보를 갖는 에러를 전달해준다
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// @brief
    ///     앱이 백그라운드 상태로 진입할 때 실행되는 함수
    /// @discussion
    ///     백그라운드 상태를 지원하지 않는 다면 실행되지 않고, applicationWillTerminate가 곧바로 실행 됨에 유의
    /// @Todo
    ///     현재 데이터들을 아카이브화 시켜 저장해야 함
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        dataManager.save()
        print("Disconnected from FCM.")
    }
    
    /// @brief
    ///     앱이 백그라운드에서 포어그라운드로 전환될 때 실행되는 함수
    /// @discussion
    ///     아카이브 된 후, 백그라운드 상태에서 전달된 정보들
    /// @Todo
    ///     아카이브로 부터 데이터들을 다시 불러와 저장해야 함
    func applicationWillEnterForeground(_ application: UIApplication) {
        dataManager = DataManager()
    }
    
    /// 앱이 종료되기 직전에 실행되는 함수
    func applicationWillTerminate(_ application: UIApplication)
    {
        /// @Todo 현재 데이터들을 아카이브화 시켜 저장해야 함
        dataManager.save()
    }

    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // dataManager = DataManager()
        connectToFcm()
        
        FIRMessaging.messaging().connect { error in
            print(error as Any)
        }
    }
    
    func getTopViewController() -> UIViewController?
    {
        var topViewController:UIViewController? = nil
        
        if var topVC = UIApplication.shared.delegate?.window??.rootViewController
        {
            while (topVC.presentedViewController != nil) {
                topVC = topVC.presentedViewController!
            }
            
            topViewController = topVC
        }
        
        return topViewController
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter willPresent")
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let fileName = userInfo["file_name"] as? String, let key = userInfo["inner_idx"] as? String{
            let groupId = fileName.components(separatedBy: ".")[0]
            
            if let title = userInfo["title"] as? String, let link = userInfo["link"] as? String, let datetime = userInfo["datetime"] as? String {
                dataManager.supportedBoards[groupId]?.articles[key] = Article(title: title, groupid: groupId, key: key, url: link, date: datetime, archived: false)
            }
            
            if let topView = getTopViewController(), topView.isKind(of: ArticleViewController.self) {
                let articleVC = topView as! ArticleViewController
                
                articleVC.filterArticles()
                articleVC.articleTable.reloadData()
            }
        }
        
        // Print full message.
        print(userInfo) 
        
        completionHandler([.alert,.badge,.sound])
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("userNotificationCenter didReceive")
//        let userInfo = response.notification.request.content.userInfo
//        // Print message ID.
//        
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        if let fileName = userInfo["file_name"] as? String, let key = userInfo["inner_idx"] as? String{
//            let groupId = fileName.components(separatedBy: ".")[0]
//            
//            if let title = userInfo["title"] as? String, let link = userInfo["link"] as? String, let datetime = userInfo["datetime"] as? String {
//                dataManager.supportedBoards[groupId]?.articles[key] = Article(title: title, groupid: groupId, key: key, url: link, date: datetime, archived: false)
//            }
//            
//            if let topView = getTopViewController(), topView.isKind(of: ArticleViewController.self) {
//                let articleVC = topView as! ArticleViewController
//                
//                articleVC.filterArticles()
//                articleVC.articleTable.reloadData()
//            }
//        }
//
//        // Print full message.
//        print(userInfo)
//
//        completionHandler()
//    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage")
        
        print(remoteMessage.appData)
    }
}
