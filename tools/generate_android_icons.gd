extends SceneTree
# Menghasilkan ikon launcher Android dari ikon project.
# Jalankan: godot --headless --script res://tools/generate_android_icons.gd

const SOURCE_ICON := "res://icon.svg"
const OUTPUT_SIZE := {
	"res://tools/android_icons/icon_192.png": 192,
	"res://tools/android_icons/adaptive_foreground_432.png": 432,
	"res://tools/android_icons/adaptive_background_432.png": 432,
	"res://tools/android_icons/splash_512.png": 512,
}

func _initialize() -> void:
	var source := load(SOURCE_ICON)
	if source == null:
		push_error("Tidak bisa memuat %s" % SOURCE_ICON)
		quit(1)
		return
	var texture: Texture2D = source
	var base_image := texture.get_image()
	if base_image == null:
		push_error("Ikon tidak memiliki data gambar")
		quit(1)
		return
	base_image.convert(Image.FORMAT_RGBA8)
	DirAccess.make_dir_recursive_absolute("res://tools/android_icons")
	for path in OUTPUT_SIZE:
		var target_size: int = OUTPUT_SIZE[path]
		var image := base_image.duplicate() as Image
		image.resize(target_size, target_size, Image.INTERPOLATE_NEAREST)
		if String(path).ends_with("adaptive_background_432.png"):
			image.fill(Color("#3a1f66"))
		var error := image.save_png(path)
		if error != OK:
			push_error("Gagal menyimpan %s (kode %d)" % [path, error])
		else:
			print("dibuat: %s (%dx%d)" % [path, target_size, target_size])
	print("ICONS_DONE")
	quit(0)
