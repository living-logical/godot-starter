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

const ResourceLoaderMT := preload( "internal/resource-loader.gd" )

# TODO: This should come from a config file
const SCENES: Dictionary = {
    "main": "res://scenes/main/main.tscn",
    "spinning-cube": "res://scenes/spinning-cube/spinning-cube.tscn",
}

# TODO: This comes from settings as well
const Loader := preload( "res://scenes/loading/loading.tscn" )


#########################################
#
# Private variables
#

onready var _loader := ResourceLoaderMT.new()

var _loadStart: int
var _stageStart: int

var _params: Dictionary


#########################################
#
# Public methods
#

func change_scene( name: String, params = {} ) -> void:
    if not SCENES.has( name ):
        print( "No scene" )
        return

    _start_loader( params )

    _params = params
    _loadStart = OS.get_ticks_usec()
    _stageStart = _loadStart
    _loader.load_start( SCENES.get( name ) )

func exit() -> void:
    get_tree().quit()


#########################################
#
# Overrides
#

func _ready():
    assert( _loader != null )
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

func _start_loader( params: Dictionary ):
    if params and params.get( "no_loader" ):
        return
    var loader = _get_loader( params )
    if params and params.has( "loader_config" ) and loader.has_method( "configure" ):
        loader.call( "configure", params.get( "loader_config" ) )
    get_tree().root.add_child( loader )

func _get_loader( params: Dictionary ) -> Node:
    if params and params.has( "loader" ):
        return params.get( "loader" )
    return Loader.instance()


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
    if _params and not _params.get( "overlay" ):
        # Release the previous scene
        get_tree().current_scene.queue_free()

    # Now display it based on the desired change
    if _params and _params.get( "overlay" ):
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
