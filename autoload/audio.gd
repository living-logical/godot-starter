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

signal master_volume_changed( volume )


#########################################
#
# Constants
#

const DEFAULT_MASTER_VOLUME: float = -3.0


#########################################
#
# Private variables
#

onready var _musicPlayer := AudioStreamPlayer.new()


#########################################
#
# Overrides
#

func _ready() -> void:
    set_master_volume( DEFAULT_MASTER_VOLUME );
    _init_music()


#########################################
#
# Public methods
#

func play_music( stream: AudioStream ) -> void:
    _musicPlayer.stream = stream
    _musicPlayer.play()

func set_master_volume( volume: float ) -> void:
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index( "Master" ),
        volume
    )
    emit_signal( "master_volume_changed", volume )
#########################################
#
# Private methods
#

func _init_music() -> void:
    _musicPlayer.name = "BackgroundAudio"
    _musicPlayer.bus = "Music"
    add_child( _musicPlayer )


#########################################
#
# Event handlers
#

