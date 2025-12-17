# hide_taskbar.py（仅处理指定句柄，适配Godot单线程）
import sys
import win32api
import win32con
import win32gui

def hide_taskbar_by_hwnd(hwnd):
    """仅操作指定句柄的窗口，完成即退出"""
    try:
        # 1. 转换句柄类型（Godot传递的是整数，需转Windows HWND）
        hwnd_int = int(hwnd)
        hwnd_handle = win32gui.HWND(hwnd_int)
        
        # 2. 核心校验：句柄是否有效（适配Godot窗口未创建完成的情况）
        if not win32gui.IsWindow(hwnd_handle):
            print(f"❌ 无效句柄：{hwnd}（窗口可能未创建完成）", file=sys.stderr)
            return 1
        
        # 3. 仅操作该句柄的窗口（不碰其他窗口）
        ex_style = win32gui.GetWindowLongPtr(hwnd_handle, win32con.GWL_EXSTYLE)
        new_ex_style = (ex_style & ~win32con.WS_EX_APPWINDOW) | win32con.WS_EX_TOOLWINDOW
        win32gui.SetWindowLongPtr(hwnd_handle, win32con.GWL_EXSTYLE, new_ex_style)
        # 刷新窗口（确保生效）
        win32gui.SetWindowPos(
            hwnd_handle, 0, 0, 0, 0, 0,
            win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_NOZORDER | win32con.SWP_FRAMECHANGED
        )
        
        print(f"✅ 成功：句柄 {hwnd} 窗口任务栏已隐藏")
        return 0
    except Exception as e:
        print(f"❌ 操作失败：{str(e)}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    # 仅接收1个参数：Godot传递的窗口句柄（无参数直接退出）
    if len(sys.argv) != 2:
        print("❌ 用法：hide_taskbar.exe <窗口句柄>", file=sys.stderr)
        sys.exit(1)
    # 执行核心逻辑，完成即退出（无常驻）
    sys.exit(hide_taskbar_by_hwnd(sys.argv[1]))