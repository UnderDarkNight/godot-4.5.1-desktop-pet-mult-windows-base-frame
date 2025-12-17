# 本程序运行在 Godot 4.5.1 版本
extends Window  # 场景根节点必须为Window


func _init() -> void:
	print("MainWindow Init End | 窗口ID：", get_instance_id())

func _ready() -> void:
	# ========== 1. 主窗口后台化配置 ==========
	visible = false
	size = Vector2(1, 1)
	borderless = true
	unfocusable = true
	position = Vector2i(-300, -200)
	mode = Window.MODE_MINIMIZED
	extend_to_title = false
	exclusive = true  # 隐藏任务栏的关键属性

	self.title = "Digimon"

	#创建系统托盘图标
	var tray_installer = load("res://main/SystemTrayInstaller.gd").new()
	
	# 创建两个示例窗口
	Global.delay_create_window()
	Global.delay_create_window()

	# 打印主窗口的句柄
	print("MainWindow Handle:", DisplayServer.WINDOW_HANDLE)


	TaskbarUtils.hide_main_window() # 工作正常
