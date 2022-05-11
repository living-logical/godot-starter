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

tool
extends HBoxContainer


#########################################
#
# Signals
#

signal value_changed( value )


#########################################
#
# Public exports
#

export ( float ) var minimum: float = 0.0 setget _set_min
export ( float ) var maximum: float = 100.0 setget _set_max
export ( bool ) var rounded: bool = true setget _set_rounded
export ( float ) var value: float = 0.0 setget _set_value


#########################################
#
# Overrides
#

func _ready() -> void:
    _refresh()


#########################################
#
# Private methods
#

func _refresh() -> void:
    var text = String( value ) if not rounded else String( int( round( value ) ) )
    if $Label:
        ($Label as Label).text = text
    if $Value:
        ($Value as ProgressBar).value = value

func _set_min( v: float ) -> void:
    if v == minimum:
        return
    minimum = v if v <= maximum else maximum
    value = clamp( value, minimum, maximum )
    ($Value as ProgressBar).min_value = minimum
    _refresh()

func _set_max( v: float ) -> void:
    if v == maximum:
        return
    maximum = v if v >= minimum else minimum
    value = clamp( value, minimum, maximum )
    ($Value as ProgressBar).max_value = maximum
    _refresh()

func _set_rounded( v: bool ) -> void:
    if v == rounded:
        return
    rounded = v
    _refresh()

func _set_value( v: float ) -> void:
    if v == value:
        return
    value = clamp( v, minimum, maximum )
    _refresh()
    emit_signal( "value_changed", value )

func _handle_mouse_event( event: InputEventMouse ) -> void:
    if event.button_mask == BUTTON_LEFT:
        var bar := $Value as Control
        var v := float(event.position.x) / float(bar.rect_size.x)
        var scaled := ( v * maximum ) + minimum
        _set_value( scaled )


#########################################
#
# Event handlers
#

func _on_value_gui_input( event: InputEvent ) -> void:
    if event is InputEventMouse:
        _handle_mouse_event( event as InputEventMouse )
