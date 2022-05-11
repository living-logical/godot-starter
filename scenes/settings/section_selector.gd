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
extends Button


#########################################
#
# Constants
#

const LABEL_NORMAL_COLOR := Colors.CONTROL_UNFOCUSED_TEXT
const LABEL_SELECTED_COLOR := Colors.CONTROL_FOCUSED_TEXT


#########################################
#
# Private methods
#

func _refresh_selected( selected: bool ) -> void:
    add_color_override(
        "font_color",
        LABEL_SELECTED_COLOR if selected else LABEL_NORMAL_COLOR
    )
    ($Bar as ColorRect).modulate.a = 1.0 if selected else 0.0
    ($BG as ColorRect).modulate.a = 1.0 if selected else 0.0


#########################################
#
# Event handlers
#

func _on_toggled( pressed: bool ) -> void:
    _refresh_selected( pressed )

func _on_mouse_entered():
    ($BG as ColorRect).modulate.a = 1.0

func _on_mouse_exited():
    ($BG as ColorRect).modulate.a = 1.0 if pressed else 0.0
