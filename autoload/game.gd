# MIT License
#
# Copyright (c) 2022 Robert Anderson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node


#########################################
#
# Signals
#

signal scene_loading( name, stages )
signal scene_stage_completed( name, index )
signal scene_change_completed( name )


#########################################
#
# Constants
#

const ResourceLoaderMT := preload( "internal/resource_loader.gd" )


#########################################
#
# Private variables
#

onready var _package := _load_package()
onready var _loader := ResourceLoaderMT.new()

var _Pause: PackedScene = null
var _Transition: PackedScene = null

var _loadingOverlay : bool = false
var _loadStart: int
var _stageStart: int


#########################################
#
# Public methods
#

func change_scene( name: String, params = {} ) -> void:
    # Validate that the scene requested exists
    var scenes = _package.get( "scenes" )
    assert( scenes is Dictionary, "package must container a 'scenes' dictionary" )
    assert( scenes.has( name ), "'%s' scene does not exist in package" % name )

    # Fix up any necessary arguments
    var p = params if params else {}
    var transitionParams = p.get( "transition" ) if p.has( "transition" ) else {}

    # Setup local state for incoming scene load
    _loadingOverlay = p.get( "overlay" ) == true

    # Start any loading
    _start_load_transition( transitionParams )

    # Begin loading the new scene
    _loadStart = OS.get_ticks_usec()
    _stageStart = _loadStart
    _loader.load_start( scenes.get( name ) )

func exit() -> void:
    get_tree().quit()

func pause( params: Dictionary = {} ) -> void:
    # Stop game progressing
    get_tree().paused = true

    # Display a pause screen (if possible)
    _start_pause( params )

func resume() -> void:
    get_tree().paused = false

func name() -> String:
    assert( _package != null )
    assert( _package.has( "name" ), "package must contain a 'name' property" )
    return _package.get( "name" )

func version() -> String:
    assert( _package != null )
    assert( _package.has( "version" ), "package must contain a 'version' property" )
    return _package.get( "version" )

func get_quality_presets() -> Dictionary:
    assert( _package != null )
    assert( _package.has( "quality" ), "package must contain a 'quality' dictionary" )
    return _package.get( "quality" )

func get_supported_resolutions() -> Array:
    assert( _package != null )
    assert( _package.has( "resolutions" ), "package must contain a 'resolutions' array" )
    return _package.get( "resolutions" )


#########################################
#
# Overrides
#

func _ready() -> void:
    assert( _loader != null, "resource loader must be valid" )
    _loader.name = "ResourceLoader"
    get_node( "/root/" ).call_deferred( "add_child", _loader )

    # Register for all loader signals
    _loader.connect( "resource_started", self, "_on_scene_started" )
    _loader.connect( "resource_loaded", self, "_on_scene_loaded" )
    _loader.connect( "resource_stage_completed", self, "_on_stage_completed" )


#########################################
#
# Private methods
#

func _load_package() -> Dictionary:
    var script = load( "res://package.gd" )
    assert( is_instance_valid( script ), "a 'package.gd' root resource is missing" )

    var package = script.new()
    assert( package.has_method( "data" ), "package script must contain a 'data' function" )

    var data = package.data()
    assert( data is Dictionary, "package 'data' must return a valid Dictionary object")

    # Extract a default transition scene, if available
    if data.has( "transition" ):
        _Transition = load( data.get( "transition" ) )

    # Extract a default pause scene, if available
    if data.has( "pause" ):
        _Pause = load( data.get( "pause" ) )

    return data

func _start_load_transition( params: Dictionary ) -> void:
    if params.get( "disabled" ):
        return

    # Load an appropriate transition scene
    var scene = _load_transition_scene( params )
    assert( scene != null )

    # Attempt to send any configuration data to scene (if allowed)
    if scene.has_method( "configure" ):
        var config = params.get( "config" ) if params.has( "config" ) else {}
        scene.configure( config )

    # Add scene to the root. The scene should have registered for the
    # 'scene_change_complete' signal and free itself
    get_tree().root.add_child( scene )

func _start_pause( params: Dictionary ) -> void:
    if params.get( "no_pause" ):
        return

    # Load an appropriate transition scene
    var scene = _load_pause_scene( params )
    assert( scene != null )

    # Attempt to send any configuration data to scene (if allowed)
    if scene.has_method( "configure" ):
        var config = params.get( "config" ) if params.has( "config" ) else {}
        scene.configure( config )

    # Add scene to the root. The scene should have registered for the
    # 'scene_change_complete' signal and free itself
    get_tree().root.add_child( scene )

func _load_pause_scene( params: Dictionary ) -> Node:
    var scene = params.get( "scene" )
    if not scene:
        assert( _Pause != null )
        return _Pause.instance()
    elif scene is String:
        var packed: PackedScene = load( scene )
        return packed.instance()
    elif scene is Node:
        return scene
    else:
        return null

func _load_transition_scene( params: Dictionary ) -> Node:
    var scene = params.get( "scene" )
    if not scene:
        assert( _Transition != null )
        return _Transition.instance()
    elif scene is String:
        var packed: PackedScene = load( scene )
        return packed.instance()
    elif scene is Node:
        return scene
    else:
        return null


#########################################
#
# Event handlers
#

func _on_scene_started( name: String, stages: int ) -> void:
    print( "Scene loading started ({name}, {stages})".format({
        'name': name,
        'stages': stages,
    }))
    emit_signal( "scene_loading", name, stages )

func _on_scene_loaded( name: String, resource: PackedScene ) -> void:
    var loadTime: int = OS.get_ticks_usec() - _loadStart
    print( "Scene '{name}' loading complete ({time} usecs).".format({
        'name': name,
        'time': loadTime,
    }))

    # If this is an overlay, we don't free the current
    # scene. It will just go behind the overlay
    if _loadingOverlay:
        get_tree().root.add_child( resource.instance() )
    else:
        get_tree().change_scene_to( resource )

    # Signal that we are done.
    emit_signal( "scene_change_completed", name )

func _on_stage_completed( name: String, index: int, stages: int ) -> void:
    var stageEnd: int = OS.get_ticks_usec()
    var dt: int = stageEnd - _stageStart
    print( "Scene '{name}' resource stage complete ({index} of {total}): {time} usecs".format({
        'name': name,
        'index': index,
        'total': stages,
        'time': dt,
    }))
    _stageStart = stageEnd
    emit_signal( "scene_stage_completed", name, index )
