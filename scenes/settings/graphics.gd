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

const MSAA_VALUES: Dictionary = {
    "Disabled": 0,
    "2x": 1,
    "4x": 2,
    "8x": 3,
    "16x": 4,
}


#########################################
#
# Overrides
#

func _ready() -> void:
    _init_toggles()
    _init_resolutions()
    _init_anisotropic()
    _init_msaa()
    _init_presets()
    _refresh_ui()


#########################################
#
# Private methods
#

func _init_toggles() -> void:
    ($Fullscreen/Enabled as CheckButton).pressed = OS.window_fullscreen
    ($FXAA/Enabled as CheckButton).pressed = get_viewport().fxaa
    ($VSync/Enabled as CheckButton).pressed = OS.vsync_enabled

func _init_presets() -> void:
    var presets := $Quality/Setting as OptionButton
    var quality: Dictionary = Game.get_quality_presets()
    for q in quality:
        presets.add_item( q )
    presets.add_item( "Custom" )

func _init_anisotropic() -> void:
    var levels := $Anisotropic/Level as OptionButton
    levels.add_item( "2", 2 )
    levels.add_item( "4", 4 )
    levels.add_item( "8", 8 )
    levels.add_item( "18", 16 )

func _init_msaa() -> void:
    var m := $MSAA/Setting as OptionButton
    var cur: int = get_viewport().msaa
    var idx: int = 0

    for key in MSAA_VALUES:
        m.add_item( key, MSAA_VALUES.get( key ) )
        if MSAA_VALUES.get( key ) == cur:
            m.selected = idx
        idx += 1

func _init_resolutions() -> void:
    var res := $Resolution/Setting as OptionButton
    for dims in Game.get_supported_resolutions():
        assert( dims is Vector2 )
        res.add_item(
            "{x} x {y} @ {rate}Hz".format( { "x": dims.x, "y": dims.y, "rate": 60 } )
        )

func _refresh_ui() -> void:
    _match_anisotropic()
    _match_msaa()
    _match_quality()
    pass

func _match_anisotropic() -> void:
    var cur: int = ProjectSettings.get( "rendering/quality/filters/anisotropic_filter_level" )
    var levels := ($Anisotropic/Level as OptionButton)
    for idx in levels.get_item_count():
        if levels.get_item_id( idx ) == cur:
            levels.selected = idx
            break

func _match_msaa() -> void:
    var cur: int = get_viewport().msaa
    var idx := 0
    for key in MSAA_VALUES:
        if MSAA_VALUES.get( key ) == cur:
            ($MSAA/Setting as OptionButton).selected = idx
            break
        idx += 1

func _match_quality() -> void:
    var msaa: int = get_viewport().msaa
    var fxaa: bool = get_viewport().fxaa
    var presets := Game.get_quality_presets()
    var idx := -1
    for key in presets:
        idx += 1
        var v = presets.get( key )
        if v.get( "msaa" ) != msaa:
            continue
        if v.get( "fxaa" ) != fxaa:
            continue
        ($Quality/Setting as OptionButton).selected = idx
        return
    ($Quality/Setting as OptionButton).selected = idx + 1  # Custom


#########################################
#
# Event handlers
#

func _on_preset_changed( index: int ) -> void:
    var presets := Game.get_quality_presets()

    # if custom was set, leave values alone
    if index == presets.size():
        return

    var key = presets.keys()[ index ]
    var preset = presets.get( key )
    print( "MSAA: {x} -> {y}".format( {
        "x": get_viewport().msaa,
        "y": preset.msaa,
    } ) )
    get_viewport().msaa = preset.msaa
    get_viewport().fxaa = preset.fxaa

    _refresh_ui()

func _on_resolution_changed( index: int ) -> void:
    assert( Game._package.has( "resolutions" ) )

    var resolutions: Array = Game.get_supported_resolutions()
    assert( resolutions.size() > index )

    var dims: Vector2 = resolutions[ index ]
    OS.window_size = dims

func _on_fullscreen_toggled( pressed: bool ) -> void:
    OS.window_fullscreen = pressed

func _on_vsync_toggled( pressed: bool ) -> void:
    OS.vsync_enabled = pressed

func _on_msaa_changed( index: int ) -> void:
    get_viewport().msaa = ($MSAA/Setting as OptionButton).get_item_id( index )
    _match_quality()

func _on_fxaa_toggled( pressed: bool ) -> void:
    get_viewport().fxaa = pressed
    _match_quality()

func _on_anisotropic_changed( _index: int ) -> void:
    # var val = ($Anisotropic/Level as OptionButton).get_item_id( index )
    # ProjectSettings.set( "rendering/quality/filters/anisotropic_filter_level", val )
    # ProjectSettings.save()
    # _match_quality()
    pass
