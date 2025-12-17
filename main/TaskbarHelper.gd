extends Node
class_name TaskbarUtils

static func _is_debugging():
	if Engine.is_editor_hint():
		return true
	if OS.has_feature("editor"):
		return true
	if OS.has_feature("debug"):
		return true
	return false

# 静态方法隐藏窗口任务栏图标
static func hide_window(window):
	# print("is editor: ",_is_debugging())
	if window == null or _is_debugging():
		return false
	
	# 直接检查是否有HideTaskBarInWindowsSystem类，省略平台检测
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		var result = controller.hide(window)
		controller.free()  # 释放内存
		return result
	
	return false

# 静态方法显示窗口任务栏图标
static func show_window(window):
	if window == null or _is_debugging():
		return false
	
	# 直接检查是否有HideTaskBarInWindowsSystem类，省略平台检测
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		var result = controller.show(window)
		controller.free()  # 释放内存
		return result
	
	return false

# 静态方法检查窗口是否在任务栏可见
static func is_window_visible(window):
	if window == null:
		return false
	
	# 直接检查是否有HideTaskBarInWindowsSystem类，省略平台检测
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		var result = controller.is_visible(window)
		controller.free()  # 释放内存
		return result
	
	return false

static func hide_main_window():
	if _is_debugging():
		return
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		controller.hide_main_window()
		print("Main window hidden from taskbar. API in TaskbarUtils called.")

static func show_main_window():
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		controller.show_main_window()
		print("Main window shown in taskbar. API in TaskbarUtils called.")

static func is_main_window_visible():
	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
		var controller = HideTaskBarInWindowsSystem.new()
		var result = controller.is_main_window_visible()
		return result
	return false
## 以下代码在插件API里存在，但是没法用。最终导致了 hide_main_window 正常工作。所以不能去掉插件里的。只能去掉这里的。
# static func hide_window_by_object(obj = null):
# 	if obj == null:
# 		return false
# 	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
# 		var controller = HideTaskBarInWindowsSystem.new()
# 		var result = controller.hide_window_by_object(obj)
# 		return result
# 	return false

# static func show_window_by_object(obj = null):
# 	if obj == null:
# 		return false
# 	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
# 		var controller = HideTaskBarInWindowsSystem.new()
# 		var result = controller.show_window_by_object(obj)
# 		return result
# 	return false

# static func is_window_visible_by_object(obj = null):
# 	if obj == null:
# 		return false
# 	if ClassDB.class_exists("HideTaskBarInWindowsSystem"):
# 		var controller = HideTaskBarInWindowsSystem.new()
# 		var result = controller.is_window_visible_by_object(obj)
# 		return result
# 	return false
