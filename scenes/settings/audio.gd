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

extends VBoxContainer


#########################################
#
# Overrides
#

func _ready() -> void:
    $FX/Volume.set( "value", Audio.get_fx_volume() * 100.0 )
    $Master/Volume.set( "value", Audio.get_main_volume() * 100.0 )
    $Music/Volume.set( "value", Audio.get_music_volume() * 100.0 )

    $FX/Volume.connect( "value_changed", self, "_on_fx_changed" )
    $Master/Volume.connect( "value_changed", self, "_on_master_changed" )
    $Music/Volume.connect( "value_changed", self, "_on_music_changed" )


#########################################
#
# Event handlers
#

func _on_fx_changed( value: float ) -> void:
    Audio.set_fx_volume( value / 100.0 )

func _on_master_changed( value: float ) -> void:
    Audio.set_main_volume( value / 100.0 )

func _on_music_changed( value: float ) -> void:
    Audio.set_music_volume( value / 100.0 )
