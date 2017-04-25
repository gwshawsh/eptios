//
//  ViewController.swift
//  ept
//
//  Created by 临时用户 on 2017/2/8.
//  Copyright © 2017年 临时用户. All rights reserved.
//

import UIKit
import WebKit



class ViewController: UIViewController,WKUIDelegate{

    var webView: WKWebView!
    
    let linkedURLString = "http://121.42.28.12:8888/ept"
    let baseUrl = NSURL(string: "file://eptweb")
    let localUrl = "eptweb/index"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurate()
        self.webView.uiDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "NativeMethod")
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        //debugPrint(message)
        let alert = UIAlertController(title: nil,message:message,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"ok", style:UIAlertActionStyle.cancel,handler:{
            (a) -> Void in completionHandler()
        }))
        self.present(alert,animated:true,completion:nil)
       // completionHandler()
    }
    


}

extension ViewController:WKScriptMessageHandler{
    //window.webkit.messageHandlers.NativeMethod.postMessage("就是一个消息啊");
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 判断是否是调用原生的
        if "NativeMethod" == message.name {
            // 判断message的内容，然后做相应的操作
            debugPrint(message.body)
            let dict = message.body as? Dictionary<String,String>
            if(dict == nil){
                debugPrint("JS请求格式错误")
                return
            }
            let method = dict?["method"]
            let param = dict?["param"]
            let callback = dict?["callback"]
            switch method {
            case "exit"?:
                exit();
                break
            case "update"?:
                update(param: param);
                break
            case "updateEpt"?:
                updateEpt(param: param);
                break
            case "currentAppVersion"?:
                currentAppVersion(callback: callback);
                break;
            default:
                debugPrint("JS请求 method 错误")
                let url = NSURL(string:"itms-apps://itunes.apple.com/app/id444934666")
                UIApplication.shared.openURL(url as! URL)
                break
            }
        }
    }
    
    fileprivate func exit(){
        debugPrint("exit")
        
  //      abort()
    }
    fileprivate func update(param:String?){
        debugPrint("update")
        if(param != nil){
            let url = NSURL(string:param!)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as! URL)
            }
        }
    }
    fileprivate func updateEpt(param:String?){
        debugPrint("updateEpt")
        if(param == nil){
         return
        }
        let url = URL(string:param!)
       
        let session = URLSession.shared
        let downloadTaks = session.downloadTask(with: url!, completionHandler: { (location, response, error) -> Void in
            print("location:\(location)")
            let locationPath = location?.path
            SSZipArchive.unzipFile(atPath: locationPath!, toDestination: DOC_PATH, overwrite: true, password: "", progressHandler: { (entry, zipinfo, entryNumber, total) in
                
            }, completionHandler: { (path, succeed, error) in
                if(succeed){
                    self.webView.reload()
                    let alertController = UIAlertController(title:"系统提示",message:"更新成功！",preferredStyle:.alert)
                    let okAction = UIAlertAction(title:"好的",style:.default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            
            })
        downloadTaks.resume()
    }
    fileprivate func currentAppVersion(callback:String?){
        debugPrint("currentAppVersion")
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
       
        if((callback == nil) || (version == nil)){
            debugPrint("获取当前版本失败")
            return
        }
        debugPrint("当前版本" + version!)
    
        let js = callback!+"('Vios"+version!+"')"
        
        debugPrint(js)
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    fileprivate func configurate() {
        let webConfiguration = WKWebViewConfiguration()
        
        let userContent = WKUserContentController()
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        userContent.add(self, name: "NativeMethod")
        // 将UserConttentController设置到配置文件
        webConfiguration.userContentController = userContent
        webConfiguration.preferences.javaScriptEnabled = true;
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        if #available(iOS 10.0, *) {
            webConfiguration.dataDetectorTypes = [.all]
        } else {
            // Fallback on earlier versions
        }
        // 字体自适应
        let js = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width,initial-scale=1,user-scalable=0'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webConfiguration.userContentController.addUserScript(userScript)
        
        
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        webView.scrollView.bouncesZoom = false
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        view = webView
        
        let url = NSURL.fileURL(withPath: DOC_PATH+"/ept/index.html")
        let allowingRead = NSURL.fileURL(withPath: DOC_PATH+"/ept")
        debugPrint("web地址"+url.absoluteString)
        webView.loadFileURL(url, allowingReadAccessTo: allowingRead)
        
      
        //webView.load(urlRequest)
     //   webView.loadHTMLString(<#T##string: String##String#>, baseURL: <#T##URL?#>)
         //let path = Bundle.main.path(forResource: localUrl, ofType: "html")
//
//        let url = NSURL.fileURL(withPath: path!)
//        let request = NSURLRequest(url:url)
//        let url = NSURL(string: "file://ept")
//        
//        webView.loadFileURL(url as! URL, allowingReadAccessTo: url as! URL)
//        let url = URL(string: linkedURLString)
//        let urlRequest = URLRequest(url: url!)
        //webView.load(request as URLRequest)
        //webView.load(request as URLRequest)
    }
    
}




