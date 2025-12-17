extends Window

var this_window_tile: String = "null"
var background_color: Color = Color(0.2, 0.6, 1.0,0.5)



func _ready() -> void:	
	var screen_size = DisplayServer.screen_get_size()
	position = (screen_size - self.size) / 2  # 屏幕居中
	always_on_top = true  # 窗口置顶
	exclusive = false  # 窗口独占
	transparent = true  # 启用透明

	# print("Child Window Ready")
	_hide_taskbar()

	# 添加可见内容
	var bg = ColorRect.new()
	bg.color = background_color
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.name = "Background"
	add_child(bg)

	var label = Label.new()
	label.text = "DIGIMON WINDOW" + " " + this_window_tile
	label.position = Vector2(50, 50)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.name = "TitleLabel"
	add_child(label)
	
	# 正确的方式添加图像
	var image_node = Node2D.new()
	image_node.name = "ImageContainer"
	add_child(image_node)

	var sprite = Sprite2D.new()
	var tex = load("res://assets/input.qoi") as Texture2D
	if tex != null:
		sprite.texture = tex
		sprite.position = self.size/2
		sprite.name = "DigimonSprite"
		image_node.add_child(sprite)
	else:
		print("无法加载纹理: res://assets/input.qoi")

func _process(_delta: float) -> void:
	pass

func _hide_taskbar():
	TaskbarUtils.hide_window(self)
