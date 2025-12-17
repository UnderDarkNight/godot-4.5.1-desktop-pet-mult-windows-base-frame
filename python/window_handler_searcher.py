# get_all_hwnd.py（需安装 pywin32：pip install pywin32）
import win32gui
import win32con

# 存储所有窗口信息
all_windows = []

def get_window_info(hwnd, extra):
    """递归枚举所有窗口（包括子窗口）"""
    # 基础信息
    window_info = {
        "hwnd": hwnd,  # 十进制句柄（和Godot一致）
        "title": win32gui.GetWindowText(hwnd),  # 窗口标题
        "class_name": win32gui.GetClassName(hwnd),  # 窗口类名
        "is_visible": win32gui.IsWindowVisible(hwnd),  # 是否可见
        "parent_hwnd": win32gui.GetParent(hwnd),  # 父窗口句柄
        "is_top_level": win32gui.GetParent(hwnd) == 0  # 是否顶层窗口
    }
    all_windows.append(window_info)

    # 递归枚举子窗口（关键！原脚本缺这个）
    win32gui.EnumChildWindows(hwnd, get_window_info, None)

# 1. 先枚举所有顶层窗口，再递归枚举子窗口
win32gui.EnumWindows(get_window_info, None)

# 2. 打印所有窗口（筛选关键信息，高亮Godot窗口）
print("===== 所有窗口（句柄+标题+类名+可见性）=====")
print(f"{'句柄(十进制)':<15} {'标题':<30} {'类名':<20} {'可见':<6} {'顶层':<6}")
print("-" * 90)

for win in all_windows:
    # 高亮Godot相关窗口（类名含SDL_app，或标题含NewMainWindow）
    is_godot = "SDL_app" in win["class_name"] or "NewMainWindow" in win["title"]
    prefix = "🔴 GODOT窗口 → " if is_godot else "   "
    
    # 处理空标题（避免排版乱）
    title = win["title"] if win["title"] else "(无标题)"
    
    # 打印（对齐排版）
    print(f"{prefix}{win['hwnd']:<15} {title:<30} {win['class_name']:<20} {win['is_visible']:<6} {win['is_top_level']:<6}")

# 3. 单独提取Godot相关窗口（方便查看）
godot_windows = [w for w in all_windows if "SDL_app" in w["class_name"] or "Digimon" in w["title"]]
print("\n===== 筛选出的Godot相关窗口 =====")
if godot_windows:
    for w in godot_windows:
        print(f"句柄：{w['hwnd']} | 标题：{w['title']} | 可见：{w['is_visible']} | 父窗口：{w['parent_hwnd']}")
else:
    print("未找到Godot相关窗口！")