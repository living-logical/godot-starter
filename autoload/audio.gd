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

signal fx_complete( tag )
signal volume_changed( channel, volume )


#########################################
#
# Constants
#

const DEFAULT_FX_VOLUME: float = 0.75
const DEFAULT_MAIN_VOLUME: float = 0.9
const DEFAULT_MUSIC_VOLUME: float = 0.5

const FX_CHANNEL := "FX"
const MAIN_CHANNEL := "Master"
const MUSIC_CHANNEL := "Music"

const DEFAULT_FX_CACHE: int = 5


#########################################
#
# Private variables
#

onready var _musicPlayer := AudioStreamPlayer.new()

var _fxCache: Array = []


#########################################
#
# Overrides
#

func _ready() -> void:
    set_fx_volume( DEFAULT_FX_VOLUME );
    set_main_volume( DEFAULT_MAIN_VOLUME );
    set_music_volume( DEFAULT_MUSIC_VOLUME );
    _init_music()


#########################################
#
# Public methods
#

func play_fx( stream: AudioStream, tag: String = "" ) -> void:
    var player = _get_fx_player()
    player.stream = stream
    if not tag.empty():
        player.connect( "finished", self, "_fx_emit_complete", [ tag ], CONNECT_ONESHOT)
    player.play()

func play_music( stream: AudioStream ) -> void:
    _musicPlayer.stream = stream
    _musicPlayer.play()

func stop_music() -> void:
    _musicPlayer.stop()
    _musicPlayer.stream = null

func get_fx_volume() -> float:
    return _get_volume( FX_CHANNEL )

func get_main_volume() -> float:
    return _get_volume( MAIN_CHANNEL )

func get_music_volume() -> float:
    return _get_volume( MUSIC_CHANNEL )

func set_fx_volume( volume: float ) -> void:
    _set_volume( FX_CHANNEL, volume )

func set_main_volume( volume: float ) -> void:
    _set_volume( MAIN_CHANNEL, volume )

func set_music_volume( volume: float ) -> void:
    _set_volume( MUSIC_CHANNEL, volume )

#########################################
#
# Private methods
#

func _get_fx_player() -> AudioStreamPlayer:
    return _fxCache.pop_back() if not _fxCache.empty() else _make_fx_player()

func _init_fx() -> void:
    for i in DEFAULT_FX_CACHE:
        _fxCache.append( _make_fx_player() )

func _init_music() -> void:
    _musicPlayer.name = "MusicPlayer"
    _musicPlayer.bus = MUSIC_CHANNEL
    add_child( _musicPlayer )

func _make_fx_player() -> AudioStreamPlayer:
    var fx = AudioStreamPlayer.new()
    fx.bus = FX_CHANNEL
    add_child( fx )
    fx.connect( "finished", self, "_cleanup_fx_player", [ fx ] )
    return fx

func _get_volume( channel: String ) -> float:
    var db = AudioServer.get_bus_volume_db(
        AudioServer.get_bus_index( channel )
    )
    var energy = db2linear( db )
    #print( "DB (%f) <->" % db, " Energy (%f)" % energy )
    return energy

func _set_volume( channel: String, volume: float ) -> void:
    var energy := clamp( volume, 0, 100 )
    var db := linear2db( energy )
    #print( "Energy (%f) <->" % energy, " DB (%f)" % db )
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index( channel ),
        db
    )
    emit_signal( "volume_changed", channel, volume )


#########################################
#
# Event handlers
#

func _cleanup_fx_player( player: AudioStreamPlayer ) -> void:
    if _fxCache.size() < DEFAULT_FX_CACHE:
        _fxCache.append( player )
    else:
        player.queue_free()

func _fx_emit_complete( tag: String ) -> void:
    emit_signal( "fx_complete", tag )
