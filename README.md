# PowerPanel

Windows 电源控制面板，支持定时关机、重启、锁屏、睡眠、休眠。

## 功能

- 关机 / 重启 / 锁屏 / 睡眠 / 休眠
- 自定义延迟时间（秒），带实时倒计时显示
- 取消已计划的关机/重启
- 深色主题 UI
- 独立 exe，无需安装依赖

## 使用

双击 `PowerPanel.exe` 运行。

1. 选择操作（关机/重启/锁屏/睡眠/休眠）
2. 设置延迟时间（0 = 立即执行）
3. 点击「执行」

## 界面

- 下拉菜单选择操作
- 数值框设置延迟秒数
- 红色执行按钮
- 「取消计划」按钮取消 shutdown 计划
- 「中止倒计时」按钮中止当前倒计时
- 底部状态栏显示执行状态

## 编译

源码为 `PowerPanel.cs`，使用 .NET Framework 4.x 编译：

```cmd
C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:winexe /out:PowerPanel.exe /reference:System.Windows.Forms.dll,System.Drawing.dll PowerPanel.cs
```
