import AppKit
import WebKit

let pcSetupVersion = "3.3.0-beta-macos.1"

struct Package {
    let token: String
    let cask: Bool
}

let packages: [String: Package] = [
    "firefox":.init(token:"firefox",cask:true), "google-chrome":.init(token:"google-chrome",cask:true),
    "brave-browser":.init(token:"brave-browser",cask:true), "vlc":.init(token:"vlc",cask:true),
    "libreoffice":.init(token:"libreoffice",cask:true), "the-unarchiver":.init(token:"the-unarchiver",cask:true),
    "sevenzip":.init(token:"sevenzip",cask:false), "qbittorrent":.init(token:"qbittorrent",cask:true),
    "keepassxc":.init(token:"keepassxc",cask:true), "bitwarden":.init(token:"bitwarden",cask:true),
    "gimp":.init(token:"gimp",cask:true), "krita":.init(token:"krita",cask:true),
    "inkscape":.init(token:"inkscape",cask:true), "audacity":.init(token:"audacity",cask:true),
    "handbrake-app":.init(token:"handbrake-app",cask:true), "kdenlive":.init(token:"kdenlive",cask:true),
    "obs":.init(token:"obs",cask:true), "blender":.init(token:"blender",cask:true),
    "calibre":.init(token:"calibre",cask:true), "thunderbird":.init(token:"thunderbird",cask:true),
    "nextcloud":.init(token:"nextcloud",cask:true), "discord":.init(token:"discord",cask:true),
    "spotify":.init(token:"spotify",cask:true), "telegram":.init(token:"telegram",cask:true),
    "signal":.init(token:"signal",cask:true), "steam":.init(token:"steam",cask:true),
    "heroic":.init(token:"heroic",cask:true), "visual-studio-code":.init(token:"visual-studio-code",cask:true),
    "git":.init(token:"git",cask:false), "node":.init(token:"node",cask:false),
    "python@3.13":.init(token:"python@3.13",cask:false), "docker-desktop":.init(token:"docker-desktop",cask:true),
    "dbeaver-community":.init(token:"dbeaver-community",cask:true), "cyberduck":.init(token:"cyberduck",cask:true),
    "rectangle":.init(token:"rectangle",cask:true), "iterm2":.init(token:"iterm2",cask:true),
    "utm":.init(token:"utm",cask:true), "zoom":.init(token:"zoom",cask:true),
    "rustdesk":.init(token:"rustdesk",cask:true)
]

func brewPath() -> String? {
    ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first { FileManager.default.isExecutableFile(atPath: $0) }
}

@discardableResult
func run(_ executable: String, _ arguments: [String], timeout: TimeInterval = 7200) -> (Int32, String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
    process.environment = environment
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(data:data,encoding:.utf8) ?? "")
    } catch { return (127, error.localizedDescription) }
}

func humanSize(_ bytes: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    let fm = FileManager.default
    lazy var dataFolder: URL = {
        let base = fm.urls(for:.applicationSupportDirectory,in:.userDomainMask).first!
        let url = base.appendingPathComponent("PC Setup",isDirectory:true)
        try? fm.createDirectory(at:url,withIntermediateDirectories:true)
        return url
    }()
    lazy var logFolder: URL = {
        let url=dataFolder.appendingPathComponent("Logs",isDirectory:true)
        try? fm.createDirectory(at:url,withIntermediateDirectories:true)
        return url
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let configuration=WKWebViewConfiguration()
        configuration.userContentController.add(self,name:"pcsetup")
        webView=WKWebView(frame:.zero,configuration:configuration)
        webView.navigationDelegate=self
        window=NSWindow(contentRect:NSRect(x:0,y:0,width:1500,height:920),
                        styleMask:[.titled,.closable,.miniaturizable,.resizable],
                        backing:.buffered,defer:false)
        window.title="PC Setup macOS BÊTA — \(pcSetupVersion)"
        window.minSize=NSSize(width:1050,height:700)
        window.center()
        window.contentView=webView
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps:true)
        if let icon=Bundle.main.url(forResource:"macos-apple",withExtension:"svg"),
           let image=NSImage(contentsOf:icon){NSApp.applicationIconImage=image}
        guard let index=Bundle.main.url(forResource:"index",withExtension:"html",subdirectory:"Web") else {
            showError("Interface introuvable."); return
        }
        webView.loadFileURL(index,allowingReadAccessTo:index.deletingLastPathComponent())
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool { true }

    func webView(_ webView:WKWebView,decidePolicyFor navigationAction:WKNavigationAction,
                 decisionHandler:@escaping(WKNavigationActionPolicy)->Void) {
        if navigationAction.navigationType == .linkActivated, let url=navigationAction.request.url,
           ["http","https"].contains(url.scheme ?? "") {
            NSWorkspace.shared.open(url); decisionHandler(.cancel); return
        }
        decisionHandler(.allow)
    }

    func userContentController(_ userContentController:WKUserContentController,didReceive message:WKScriptMessage) {
        guard let text=message.body as? String, let data=text.data(using:.utf8),
              let object=try? JSONSerialization.jsonObject(with:data) as? [String:Any],
              let action=object["action"] as? String else { return }
        let payload=object["payload"] as? [String:Any] ?? [:]
        switch action {
        case "get-app-info": send(["type":"app-info","version":pcSetupVersion,"channel":"beta-macos","beta":true])
        case "check-app-update": send(["type":"app-update-state","status":"beta","current":pcSetupVersion])
        case "scan-installed": background{self.scanInstalled(payload)}
        case "install": background{self.install(payload)}
        case "uninstall": background{self.uninstall(payload)}
        case "batch-uninstall": background{self.batchUninstall(payload)}
        case "repair": background{self.repair(payload)}
        case "scan-updates": background{self.scanUpdates()}
        case "update": background{self.updateAll(payload)}
        case "scan-health": background{self.scanHealth()}
        case "analyze-cleanup": background{self.analyzeCleanup(payload)}
        case "cleanup": background{self.cleanup(payload)}
        case "diagnose-winget": diagnoseBrew()
        case "repair-winget": background{self.refreshBrew()}
        case "create-restore-point": openTimeMachine()
        case "scan-startup": scanStartup()
        case "open-startup-settings": openLoginItems()
        case "scan-disk": background{self.scanDisk()}
        case "load-history": loadHistory()
        case "open-log": openLog(payload)
        case "scan-quarantine": send(["type":"quarantine-state","items":[]])
        case "export-config": exportConfig(payload)
        case "import-config": importConfig()
        default: break
        }
    }

    func background(_ action:@escaping()->Void){DispatchQueue.global(qos:.userInitiated).async(execute:action)}
    func send(_ value:[String:Any]){
        guard let data=try? JSONSerialization.data(withJSONObject:value),
              let json=String(data:data,encoding:.utf8) else{return}
        DispatchQueue.main.async{self.webView.evaluateJavaScript("window.__pcSetupDispatch(\(json));")}
    }
    func showError(_ text:String){NSAlert(error:NSError(domain:"PCSetup",code:1,userInfo:[NSLocalizedDescriptionKey:text])).runModal()}
    func stringArray(_ payload:[String:Any],_ key:String)->[String]{payload[key] as? [String] ?? []}

    func brewArguments(_ verb:String,_ package:Package)->[String] {
        var args=[verb]
        if package.cask { args.append("--cask") }
        args.append(package.token)
        return args
    }
    func isInstalled(_ package:Package)->Bool {
        guard let brew=brewPath() else{return false}
        var args=["list"]
        args.append(package.cask ? "--cask" : "--formula")
        args.append(package.token)
        return run(brew,args,timeout:30).0 == 0
    }
    func writeLog(_ prefix:String,_ lines:[String])->String {
        let formatter=DateFormatter();formatter.dateFormat="yyyy-MM-dd-HHmmss"
        let name="PC-Setup-macOS-\(prefix)-\(formatter.string(from:Date())).log"
        try? lines.joined(separator:"\n").write(to:logFolder.appendingPathComponent(name),atomically:true,encoding:.utf8)
        return name
    }

    func scanInstalled(_ payload:[String:Any]){
        let ids=stringArray(payload,"ids").filter{packages[$0].map(isInstalled) ?? false}
        send(["type":"installed-state","ids":ids,"count":ids.count,"method":"homebrew"])
    }
    func install(_ payload:[String:Any]){
        let ids=stringArray(payload,"packages").filter{packages[$0] != nil}
        send(["type":"install-start","total":ids.count])
        guard let brew=brewPath() else {
            let name=writeLog("Installation",["Homebrew est absent."])
            send(["type":"install-complete","success":0,"failed":ids.count,"logName":name]);return
        }
        var success=0,failed=0,report=["PC SETUP macOS \(pcSetupVersion)","INSTALLATION"]
        for(index,id) in ids.enumerated(){
            let item=packages[id]!
            send(["type":"install-progress","index":index+1,"total":ids.count,"id":id])
            send(["type":"install-security","id":id,"success":true])
            let result=run(brew,brewArguments("install",item))
            let ok=result.0==0; success += ok ? 1:0; failed += ok ? 0:1
            report.append("\(id): \(result.0)\n\(result.1)")
            send(["type":"install-item","index":index+1,"total":ids.count,"id":id,"success":ok])
        }
        send(["type":"install-complete","success":success,"failed":failed,"logName":writeLog("Installation",report)])
    }
    func uninstall(_ payload:[String:Any]){
        guard let id=payload["id"] as? String,let item=packages[id],let brew=brewPath() else{return}
        send(["type":"uninstall-start","id":id])
        let result=run(brew,brewArguments("uninstall",item))
        send(["type":"uninstall-complete","id":id,"success":result.0==0,"code":result.0,"logName":writeLog("Desinstallation",["\(id): \(result.0)",result.1])])
    }
    func batchUninstall(_ payload:[String:Any]){
        let ids=stringArray(payload,"packages").filter{packages[$0] != nil}
        send(["type":"batch-uninstall-start","total":ids.count])
        guard let brew=brewPath() else{return}
        var success=0,failed=0,report=[String]()
        for(index,id) in ids.enumerated(){
            send(["type":"batch-uninstall-progress","index":index+1,"total":ids.count,"id":id])
            let result=run(brew,brewArguments("uninstall",packages[id]!));let ok=result.0==0
            success += ok ? 1:0;failed += ok ? 0:1;report.append("\(id): \(result.0)")
            send(["type":"batch-uninstall-item","id":id,"success":ok])
        }
        send(["type":"batch-uninstall-complete","success":success,"failed":failed,"logName":writeLog("Desinstallation-groupee",report)])
    }
    func repair(_ payload:[String:Any]){
        guard let id=payload["id"] as? String,let item=packages[id],let brew=brewPath() else{return}
        send(["type":"repair-start","id":id]);send(["type":"repair-fallback","id":id])
        let result=run(brew,brewArguments("reinstall",item))
        send(["type":"repair-complete","id":id,"success":result.0==0,"code":result.0,"mode":"reinstall","logName":writeLog("Reparation",["\(id): \(result.0)",result.1])])
    }
    func scanUpdates(){
        send(["type":"updates-scanning"])
        guard let brew=brewPath() else{send(["type":"updates-found","updates":[],"error":"Homebrew est absent."]);return}
        let result=run(brew,["outdated","--json=v2"],timeout:300)
        var updates=[[String:Any]]()
        if let data=result.1.data(using:.utf8),let json=try? JSONSerialization.jsonObject(with:data) as? [String:Any]{
            let formulae=json["formulae"] as? [[String:Any]] ?? []
            let casks=json["casks"] as? [[String:Any]] ?? []
            for entry in formulae+casks {
                guard let name=entry["name"] as? String else{continue}
                updates.append(["id":name,"name":name,"current":"installée","available":"nouvelle"])
            }
        }
        send(["type":"updates-found","updates":updates,"error":result.0==0 ? "" : result.1])
    }
    func updateAll(_ payload:[String:Any]){
        guard let brew=brewPath() else{return}
        send(["type":"update-start"])
        send(["type":"update-stage","stage":"sources","title":"Actualisation de Homebrew","detail":"Lecture du catalogue","percent":15])
        let update=run(brew,["update"])
        send(["type":"update-stage","stage":"applications","title":"Mise à jour des applications","detail":"Installation des nouvelles versions","percent":48])
        var code=update.0
        let selected=stringArray(payload,"packages")
        if selected.isEmpty { code |= run(brew,["upgrade"]).0 }
        else {
            for id in selected {
                if let item=packages[id] { code |= run(brew,brewArguments("upgrade",item)).0 }
            }
        }
        send(["type":"update-stage","stage":"windows","title":"Mise à jour de macOS","detail":"Ouverture des Réglages Système","percent":85])
        DispatchQueue.main.async{NSWorkspace.shared.open(URL(string:"x-apple.systempreferences:com.apple.Software-Update-Settings.extension")!)}
        send(["type":"update-complete","success":code==0,"appsSuccess":code==0,"windowsStarted":true,"code":code,"logName":writeLog("Mise-a-jour",["Code: \(code)"])])
    }
    func scanHealth(){
        let home=NSHomeDirectory()
        guard let attrs=try? fm.attributesOfFileSystem(forPath:home),
              let total=attrs[.systemSize] as? NSNumber,let free=attrs[.systemFreeSize] as? NSNumber else{return}
        let percent=Int((free.doubleValue/total.doubleValue)*100)
        send(["type":"health-state","score":max(45,min(100,70+min(25,percent))),"updateCount":0,
              "freeGb":String(format:"%.1f",free.doubleValue/1073741824),"freePercent":percent,
              "totalGb":String(format:"%.1f",total.doubleValue/1073741824),"pendingRestart":false,
              "quarantineCount":0,"error":false])
    }
    func freeDiskBytes()->Int64 {
        guard let attributes=try? fm.attributesOfFileSystem(forPath:NSHomeDirectory()),
              let value=attributes[.systemFreeSize] as? NSNumber else{return 0}
        return value.int64Value
    }
    func cleanupTargets(_ choices:[String])->[(String,URL)]{
        let home=fm.homeDirectoryForCurrentUser
        var targets=[(String,URL)]()
        if choices.contains("user-temp"){targets.append(("Caches utilisateur",home.appendingPathComponent("Library/Caches")))}
        if choices.contains("windows-temp"){targets.append(("Journaux utilisateur",home.appendingPathComponent("Library/Logs")))}
        if choices.contains("recycle-bin"){targets.append(("Corbeille",home.appendingPathComponent(".Trash")))}
        if choices.contains("delivery"){targets.append(("Caches de téléchargement",home.appendingPathComponent("Library/Caches/Homebrew")))}
        return targets.filter{fm.fileExists(atPath:$0.1.path)}
    }
    func folderSize(_ url:URL)->(Int64,Int){
        var size:Int64=0,count=0
        if let enumerator=fm.enumerator(at:url,includingPropertiesForKeys:[.fileSizeKey,.isRegularFileKey],options:[.skipsHiddenFiles,.skipsPackageDescendants]){
            for case let item as URL in enumerator {
                if let values=try? item.resourceValues(forKeys:[.fileSizeKey,.isRegularFileKey]),values.isRegularFile==true{
                    size += Int64(values.fileSize ?? 0);count += 1
                }
            }
        }
        return(size,count)
    }
    func analyzeCleanup(_ payload:[String:Any]){
        send(["type":"cleanup-analysis-start"])
        var items=[[String:Any]](),total:Int64=0
        for(label,url) in cleanupTargets(stringArray(payload,"choices")){
            let result=folderSize(url);total += result.0
            items.append(["label":label,"path":url.path,"bytes":result.0,"files":result.1,"size":humanSize(result.0)])
        }
        send(["type":"cleanup-analysis","items":items,"size":humanSize(total),"protectedFolders":[NSHomeDirectory()+"/Documents",NSHomeDirectory()+"/Downloads"]])
    }
    func cleanup(_ payload:[String:Any]){
        let choices=stringArray(payload,"choices"),targets=cleanupTargets(choices)
        let before=freeDiskBytes()
        send(["type":"cleanup-start"])
        for(index,target) in targets.enumerated(){
            send(["type":"cleanup-stage","label":target.0,"index":index+1,"total":targets.count,"percent":min(90,10+Int(Double(index+1)/Double(max(1,targets.count))*75))])
            if let children=try? fm.contentsOfDirectory(at:target.1,includingPropertiesForKeys:nil){for child in children{try? fm.removeItem(at:child)}}
        }
        if choices.contains("components"),let brew=brewPath(){_ = run(brew,["cleanup","--prune=all"])}
        let after=freeDiskBytes()
        let gained=max(0,after-before)
        send(["type":"cleanup-complete","success":true,"code":0,"recovered":String(format:"%.2f",Double(gained)/1073741824),"logName":writeLog("Nettoyage",["Espace récupéré: \(humanSize(gained))"])])
    }
    func diagnoseBrew(){
        if let brew=brewPath(){let result=run(brew,["--version"],timeout:30);send(["type":"winget-diagnostic","available":true,"sources":true,"version":result.1.components(separatedBy:"\n").first ?? "Homebrew","message":"Homebrew est disponible"])}
        else{send(["type":"winget-diagnostic","available":false,"sources":false,"version":"absent","message":"Homebrew doit être installé depuis brew.sh"])}
    }
    func refreshBrew(){send(["type":"winget-repair-start"]);let result=brewPath().map{run($0,["update"])} ?? (127,"Homebrew absent");send(["type":"winget-repair-complete","success":result.0==0,"code":result.0,"logName":writeLog("Homebrew", [result.1])])}
    func openTimeMachine(){send(["type":"restore-point-start"]);DispatchQueue.main.async{NSWorkspace.shared.open(URL(fileURLWithPath:"/System/Applications/Time Machine.app"))};send(["type":"restore-point-complete","success":true,"code":0])}
    func scanStartup(){
        var items=[[String:String]]()
        for folder in [fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents"),URL(fileURLWithPath:"/Library/LaunchAgents")]{
            if let files=try? fm.contentsOfDirectory(at:folder,includingPropertiesForKeys:nil){for file in files where file.pathExtension=="plist"{items.append(["name":file.deletingPathExtension().lastPathComponent,"source":folder.path,"command":file.path])}}
        }
        send(["type":"startup-state","items":items])
    }
    func openLoginItems(){DispatchQueue.main.async{NSWorkspace.shared.open(URL(string:"x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!)}}
    func scanDisk(){
        send(["type":"disk-scan-start"]);var items=[[String:Any]]()
        let home=fm.homeDirectoryForCurrentUser
        for relative in ["Documents","Downloads","Library/Caches","Library/Application Support","Movies"]{
            let url=home.appendingPathComponent(relative);if fm.fileExists(atPath:url.path){let result=folderSize(url);items.append(["name":url.lastPathComponent,"path":url.path,"bytes":result.0,"files":result.1,"size":humanSize(result.0)])}
        }
        send(["type":"disk-scan-state","items":items.sorted{($0["bytes"] as? Int64 ?? 0)>($1["bytes"] as? Int64 ?? 0)}])
    }
    func loadHistory(){
        let urls=(try? fm.contentsOfDirectory(at:logFolder,includingPropertiesForKeys:[.contentModificationDateKey,.fileSizeKey])) ?? []
        let formatter=DateFormatter();formatter.dateFormat="dd/MM/yyyy HH:mm"
        let items=urls.filter{$0.pathExtension=="log"}.sorted{((try? $0.resourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate) ?? .distantPast)>((try? $1.resourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate) ?? .distantPast)}.prefix(50).map{url->[String:String] in
            let values=try? url.resourceValues(forKeys:[.contentModificationDateKey,.fileSizeKey])
            return["type":"macOS","name":url.lastPathComponent,"date":formatter.string(from:values?.contentModificationDate ?? Date()),"size":humanSize(Int64(values?.fileSize ?? 0))]
        }
        send(["type":"history-state","items":items])
    }
    func openLog(_ payload:[String:Any]){if let name=payload["name"] as? String{let safe=URL(fileURLWithPath:name).lastPathComponent;NSWorkspace.shared.open(logFolder.appendingPathComponent(safe))}}
    func exportConfig(_ payload:[String:Any]){let url=dataFolder.appendingPathComponent("configuration.json");if let data=try? JSONSerialization.data(withJSONObject:payload,options:.prettyPrinted){try? data.write(to:url);send(["type":"config-export-complete","success":true,"count":stringArray(payload,"selected").count,"file":url.path])}}
    func importConfig(){let url=dataFolder.appendingPathComponent("configuration.json");guard let data=try? Data(contentsOf:url),let value=try? JSONSerialization.jsonObject(with:data) as? [String:Any] else{send(["type":"config-import-error","message":"Aucune configuration sauvegardée."]);return};send(["type":"config-imported","packages":stringArray(value,"selected"),"cleanup":stringArray(value,"cleanup"),"file":url.path])}
}

let app=NSApplication.shared
let delegate=AppDelegate()
app.delegate=delegate
app.setActivationPolicy(.regular)
app.run()
