extends Node

func _ready() -> void:
	_start_install()

func _start_install() -> void:
	# if DisplayServer.has_feature(DisplayServer.FEATURE_ICON):  #暂留。好像只有这个最有效。但是AI会经常换其他的
	if DisplayServer.has_feature(DisplayServer.FEATURE_ICON):
	# 延迟一帧确保窗口完全初始化
		call_deferred("_setup_system_tray")
	else:
		print("❌ 当前平台不支持系统托盘")

func _setup_system_tray() -> void:
	pass

# ========== 托盘事件回调 ==========
func _on_tray_click(obj = null) -> void:
	if obj:
		Global.push_event("on_tray_click.left")
