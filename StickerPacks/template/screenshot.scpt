-- ✅ AppleScript 自动化截图脚本（支持多个模拟器设备）
-- 依赖：cliclick

-- ✅ 支持的设备列表（名称, fastlane前缀, 月亮X,Y, 云X,Y, 截图宽,高）
set deviceList to {¬
    {"iPhone 15 Pro Max", "6.7", 190, 2160, 640, 2160, 1290, 2796, "EF68E3B0-D4E9-40FE-8BAF-192092955856"}, ¬
    {"iPad Pro (12.9-inch) (6th generation)", "iPad_12.9", 722, 1650, 980, 1650, 2064, 2752, "A655DA53-ACA4-4060-95D8-3770AEAB96E5"} ¬
}

repeat with d in deviceList
    set deviceName to item 1 of d
    set screenshotPrefix to item 2 of d
    set moonX_inShot to item 3 of d
    set moonY_inShot to item 4 of d
    set cloudX_inShot to item 5 of d
    set cloudY_inShot to item 6 of d
    set imgW to item 7 of d
    set imgH to item 8 of d
    set did to item 9 of d


    my runAndScreenshot(deviceName, screenshotPrefix, moonX_inShot, moonY_inShot, cloudX_inShot, cloudY_inShot, imgW, imgH, did)
end repeat

-- ✅ 主流程函数：运行、点击、截图
on runAndScreenshot(deviceName, screenshotPrefix, moonX_inShot, moonY_inShot, cloudX_inShot, cloudY_inShot, screenshotWidth, screenshotHeight, did)

    -- ✅ 打开 Xcode 项目
    do shell script "open template.xcodeproj"
    delay 3
    tell application "Xcode" to activate
    delay 2

    -- ✅ 启动运行 App 并选择模拟器
    tell application "System Events"
        tell process "Xcode"
            click menu item deviceName of menu 1 of menu item "Destination" of menu 1 of menu bar item "Product" of menu bar 1
            delay 1
            click menu item "Run" of menu 1 of menu bar item "Product" of menu bar 1
        end tell
    end tell

    delay 15 -- 等待启动完成

    -- ✅ 获取 Simulator 窗口尺寸
    tell application "System Events"
        tell process "Simulator"
            set {simX, simY} to position of window 1
            set {simWidth, simHeight} to size of window 1
        end tell
    end tell

    -- ✅ 缩放坐标
    set scaleX to simWidth / screenshotWidth
    set scaleY to simHeight / screenshotHeight

    set moonX to simX + (moonX_inShot * scaleX)
    set moonY to simY + (moonY_inShot * scaleY)
    set cloudX to simX + (cloudX_inShot * scaleX)
    set cloudY to simY + (cloudY_inShot * scaleY)

    set moonX to moonX as integer
    set moonY to moonY as integer
    set cloudX to cloudX as integer
    set cloudY to cloudY as integer

    -- ✅ 截图前创建目录
    do shell script "mkdir -p ./fastlane/screenshots/en-US"
    delay 1
    do shell script "xcrun simctl io " & did & " screenshot ./fastlane/screenshots/en-US/iPhone_" & screenshotPrefix & "_01.png"

    -- ✅ 点击月亮图标
    do shell script "cliclick c:" & moonX & "," & moonY
    delay 1
    do shell script "xcrun simctl io " & did & " screenshot ./fastlane/screenshots/en-US/iPhone_" & screenshotPrefix & "_02.png"

    -- ✅ 点击云图标
    delay 1
    do shell script "cliclick c:" & cloudX & "," & cloudY
    delay 1
    do shell script "xcrun simctl io " & did & " screenshot ./fastlane/screenshots/en-US/iPhone_" & screenshotPrefix & "_03.png"

    tell application "Xcode" to activate
    delay 2

    -- ✅ 启动运行 App 并选择模拟器
    tell application "System Events"
        tell process "Xcode"
            click menu item "Stop" of menu 1 of menu bar item "Product" of menu bar 1
        end tell
    end tell


end runAndScreenshot