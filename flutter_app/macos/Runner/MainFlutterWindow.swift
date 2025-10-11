import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    
    // 设置手机尺寸的窗口 (iPhone 14 Pro 尺寸: 393x852)
    let phoneWidth: CGFloat = 393
    let phoneHeight: CGFloat = 852
    let windowWidth = phoneWidth
    let windowHeight = phoneHeight + 22 // 加上标题栏高度
    
    // 计算居中位置
    let screenFrame = NSScreen.main?.frame ?? NSRect.zero
    let x = (screenFrame.width - windowWidth) / 2
    let y = (screenFrame.height - windowHeight) / 2
    
    let phoneFrame = NSRect(x: x, y: y, width: windowWidth, height: windowHeight)
    self.setFrame(phoneFrame, display: true)
    
    // 设置窗口属性
    self.title = "5700WebUi"
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.isRestorable = false
    self.styleMask = [.titled, .closable, .miniaturizable, .resizable]
    
    // 设置最小和最大尺寸
    self.minSize = NSSize(width: phoneWidth, height: windowHeight)
    self.maxSize = NSSize(width: phoneWidth * 2, height: windowHeight * 2)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
