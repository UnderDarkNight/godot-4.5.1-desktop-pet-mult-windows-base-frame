# PNGToQOIConverter.gd
class_name PNGToQOIConverter
extends Node

# 配置参数
var root_directory: String = "res://assets/" # 要搜索的根目录
var process_subdirectories: bool = true # 是否处理子目录
var delete_original: bool = true # 转换后是否删除原始PNG
var debug_mode: bool = false # 调试模式(true时不会实际删除文件)

# 统计信息
var processed_files: int = 0
var converted_files: int = 0
var failed_files: int = 0
var skipped_files: int = 0

# 自定义QOI保存函数(可选)
var custom_qoi_saver = null # 不再指定Callable类型，允许为null

func _init():
	pass

# 主执行函数 - 添加addr_str参数，用于指定处理路径
func run(addr_str: String = "") -> bool:
	# 保存原始的root_directory
	var original_root_directory = root_directory
  	#----------------------------------------------------------
	# 如果传入了路径，使用传入的路径，否则使用默认路径
	if addr_str != "":
		root_directory = addr_str
	
	# 修复：使用DirAccess实例检查目录是否存在
	var dir_check = DirAccess.open(root_directory)
	if not dir_check:
		push_error("错误: 根目录不存在 - " + root_directory)
		# 恢复原始的root_directory
		root_directory = original_root_directory
		return false
		
	print("开始转换PNG到QOI") 
	print("根目录: " + root_directory) 
	print("处理子目录: " + ("是" if process_subdirectories else "否")) 
	print("删除原始文件: " + ("是" if delete_original else "否")) 
	print("调试模式: " + ("开启" if debug_mode else "关闭")) 
	print("----------------------------------------")
	
	# 重置统计 
	processed_files = 0 
	converted_files = 0 
	failed_files = 0 
	skipped_files = 0
	
	_process_directory(root_directory)
	
	# 打印总结 
	print("\n========================================") 
	print("转换完成!") 
	print("处理文件总数: " + str(processed_files)) 
	print("成功转换: " + str(converted_files)) 
	print("转换失败: " + str(failed_files)) 
	print("已跳过: " + str(skipped_files)) 
	print("========================================")
	
	# 恢复原始的root_directory
	root_directory = original_root_directory
	
	return true

# 递归处理目录
func _process_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("无法打开目录: " + dir_path)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var file_path = dir_path.path_join(file_name)
		
		# 跳过.和..目录
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		if dir.dir_exists(file_path):
			if process_subdirectories:
				_process_directory(file_path) # 递归处理子目录
		elif file_name.ends_with(".png"):
			_convert_png_to_qoi(file_path)
			
		file_name = dir.get_next()
	
	dir.list_dir_end()

# 转换单个PNG文件
func _convert_png_to_qoi(png_path: String) -> bool:
	processed_files += 1
	print("[" + str(processed_files) + "] 处理: " + png_path.get_file())
	
	# 生成QOI路径
	var base_path = png_path.get_basename()
	var qoi_path = base_path + ".qoi"
	
	# 调试模式下跳过实际转换
	if debug_mode:
		print(" [DEBUG] 将转换: " + png_path + " -> " + qoi_path)
		if delete_original:
			print(" [DEBUG] 将删除原始PNG")
		return true
	
	# 检查是否已经存在QOI文件
	if ResourceLoader.exists(qoi_path):
		print(" 跳过，QOI文件已存在: " + qoi_path.get_file())
		skipped_files += 1
		return false
	
	# 加载PNG图像
	var image = Image.new()
	var error = image.load(png_path)
	
	if error != OK:
		push_error(" 无法加载PNG图像: " + png_path)
		failed_files += 1
		return false
		
	var success = false
	
	# 尝试使用自定义保存器
	if custom_qoi_saver:
		var result = custom_qoi_saver.call(image, qoi_path)
		if result == OK:
			success = true
			print(" 通过自定义保存器成功保存QOI: " + qoi_path.get_file())
		else:
			push_error(" 自定义保存器保存失败，错误码: " + str(result))
	
	# 内置方法1: 直接通过Image.save_qoi(大多数QOI插件支持)
	elif image.has_method("save_qoi"):
		if image.save_qoi(qoi_path) == OK:
			success = true
			print(" 成功保存QOI: " + qoi_path.get_file())
		else:
			push_error(" 保存QOI失败: " + qoi_path.get_file())
	
	# 内置方法2: 通过QOI单例
	elif Engine.has_singleton("QOI"):
		var qoi = Engine.get_singleton("QOI")
		if qoi and qoi.has_method("save_image"):
			if qoi.save_image(image, qoi_path) == OK:
				success = true
				print(" 通过QOI单例成功保存: " + qoi_path.get_file())
			else:
				push_error(" 通过QOI单例保存失败: " + qoi_path.get_file())
		else:
			push_error(" QOI单例缺少save_image方法")
	
	# 内置方法3: 通过ResourceSaver
	else:
		var texture = ImageTexture.create_from_image(image)
		if ResourceSaver.save(texture, qoi_path) == OK:
			success = true
			print(" 通过ResourceSaver成功保存QOI: " + qoi_path.get_file())
		else:
			push_error(" 无法通过ResourceSaver保存QOI，检查QOI插件是否正确安装")
	
	# 转换成功且需要删除原始文件
	if success:
		converted_files += 1
		if delete_original:
			var dir = DirAccess.open(png_path.get_base_dir())
			if dir and dir.file_exists(png_path):
				var remove_error = dir.remove(png_path)
				if remove_error == OK:
					print(" 已删除原始PNG")
				else:
					push_error(" 无法删除原始PNG: " + png_path)
					print(" 错误码: " + str(remove_error))
		return true
	else:
		failed_files += 1
		return false
