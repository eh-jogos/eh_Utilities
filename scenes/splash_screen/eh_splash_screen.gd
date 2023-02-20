extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_file("*.tscn") var next_scene := ""

#--- private variables - order: export > normal var > onready -------------------------------------

var _loader := eh_ThreadedBackgroundLoader.new()
var _current_splash: eh_SplashAnimation = null

@onready var _sequence: Control = $Sequence

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not next_scene.is_empty():
		_loader.start_loading(next_scene)
	
	await _process_splash_animations()
	
	if _loader.is_loading():
		await _loader.loading_finished
	
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	get_tree().change_scene_to_packed(packed_scene)


func _unhandled_input(event: InputEvent) -> void:
	if _current_splash == null:
		return
	
	if not event is InputEventMouseMotion:
		_current_splash.skip_splash_animation()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _process_splash_animations() -> void:
	var splash_animations := _sequence.get_children()
	
	for node in splash_animations:
		node.hide()
		if node is eh_eh_SplashAnimationLoading:
			node.loader = _loader
	
	for node in splash_animations:
		var splash_anim := node as eh_SplashAnimation
		_current_splash = splash_anim
		
		splash_anim.show()
		splash_anim.play_splash_animation()
		
		await splash_anim.splash_animation_finished
		splash_anim.hide()

### -----------------------------------------------------------------------------------------------
