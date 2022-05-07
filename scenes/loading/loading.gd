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

extends Control

#########################################
#
# Constants
#

const FADE_DURATION = 0.5       # Seconds
const MINIMUM_DELAY = 1.0       # Seconds
const STEP_DURATION = 0.25      # Seconds


#########################################
#
# Private variables
#

onready var _bar: ProgressBar = $BG/Centered/Progress/Bar
onready var _fader: Tween = $Fader
onready var _spinner: AnimationPlayer = $Spinner
onready var _stepper: Tween = $Stepper

onready var _startTime: int = OS.get_ticks_msec()

var _stages: int = 1
var _hideProgress: bool = false


#########################################
#
# Public methods
#

func configure( config: Dictionary ) -> void:
    if config == null:
        return
    _hideProgress = config.get( "hide_progress" ) == true

#########################################
#
# Overrides
#

func _ready() -> void:
    _spinner.play( "spin" )
    _bar.visible = not _hideProgress

    Game.connect( "scene_loading", self, "_on_starting" )
    Game.connect( "scene_change_completed", self, "_on_completed" )
    Game.connect( "scene_stage_completed", self, "_on_progress" )

func _exit_tree():
    print( "Loading node gone!")


#########################################
#
# Event handlers
#

func _on_completed( _name: String ) -> void:
    var dt := float(OS.get_ticks_msec() - _startTime) / 1000.0
    var delay := MINIMUM_DELAY - dt if dt < 0.0 else 0.0

    _fader.interpolate_property(
        $BG,
        "modulate",
        Color( 1, 1, 1, 1 ),
        Color( 1, 1, 1, 0 ),
        FADE_DURATION,
        Tween.TRANS_QUAD,
        Tween.EASE_IN_OUT,
        delay
    )
    _fader.start()

    yield( _fader, "tween_completed" )
    queue_free()

func _on_progress( _name: String, index: int ) -> void:
    if _stepper.is_active():
        _stepper.stop_all()

    var percent := float(index) / float(_stages)
    _stepper.interpolate_property(
        _bar,                   # target
        "value",                # property
        _bar.value,             # initial value
        percent,                # final value
        STEP_DURATION,          # duration (seconds)
        Tween.TRANS_QUAD,       # transition style
        Tween.EASE_IN_OUT,      # easing style
        0                       # transition delay
    )
    _stepper.start()

func _on_starting( _name: String, stages: int ) -> void:
    _stages = stages
    _bar.value = 0
