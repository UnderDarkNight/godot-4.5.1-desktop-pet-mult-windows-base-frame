extends Node

enum WindowTypes {PET,INFO,SETTINGS,REST_AREA}
var EmptyWindowScene = preload("res://sences/EmptyWindowSence.tscn")

const HIDE_EXE_PATH = "res://python/dist//hide_taskbar_for_windows_system.exe"  # Python EXE 放在Godot项目根目录

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func create_new_window():
	print("开始创建新窗口 | 触发窗口ID：", get_instance_id())
	var window_scene = EmptyWindowScene
	var new_window = window_scene.instantiate()

	# new_window.position = get_window().position + Vector2i(-200, 0)  # 向左超出主窗口
	# 必设：Window的大小（否则默认0x0看不见）
	new_window.size = Vector2(200, 150)
	# 强制显示窗口
	new_window.visible = true
	# 给子窗口命名，方便识别
	new_window.name = "NewMainWindow_" + str(get_instance_id())
	new_window.transparent = true  # 设置窗口透明

	# 加到根节点（Window节点必须挂到root下）
	get_tree().root.add_child(new_window)

	new_window.title = "Digimon Child Window"

	print("✅ 子窗口已创建（超出主窗口）：", new_window.name)
	print("✅ 主窗口坐标：", get_window().position)
	print("✅ 子窗口坐标：", new_window.position)



func delay_create_window() ->void:
	var delay_timer = Timer.new()
	delay_timer.wait_time = 1.5
	delay_timer.one_shot = true
	delay_timer.timeout.connect(create_new_window)
	add_child(delay_timer)
	delay_timer.start()
	print("初始窗口 Ready End | 启动Timer | 窗口ID：", get_instance_id())


func push_event(event: String,obj = null) -> void:
	print("Global Push Event:", event ," : ", obj)

func hide_window_taskbar_after_ready_by_window_handle(window_handler) -> void:
	# 4.5.1 手册：平台判定
	if OS.get_name() != "Windows":
		print("❌ 仅 Windows 平台支持（4.5.1 手册）")
		return
	# 4.5.1 手册：获取原生句柄
	var hwnd = window_handler
	if hwnd == 0:
		print("❌ 4.5.1 手册：句柄仍无效（异常）")
		return
	print("✅ 4.5.1 有效 HWND：", hwnd)

	# 调用 Python EXE（4.5.1 异步调用）
	var exe_abs_path = ProjectSettings.globalize_path(HIDE_EXE_PATH)
	var args = [str(hwnd)]
	var err = OS.create_process(exe_abs_path, args)
	if err == OK:
		print("✅ Python EXE 调用成功（4.5.1 兼容）")
	else:
		print("❌ EXE 路径：", exe_abs_path)
