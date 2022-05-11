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
# Signals
#


#########################################
#
# Constants
#


#########################################
#
# Private variables
#


#########################################
#
# Public methods
#


#########################################
#
# Overrides
#

func _input( event: InputEvent ) -> void:
    if event.is_action( "ui_cancel" ):
        queue_free()

func _ready() -> void:
    $SafeArea/Regions/Header/Selectors.connect( "selected", self, "_on_selector_changed" )


#########################################
#
# Private methods
#


#########################################
#
# Event handlers
#

func _on_selector_changed( index: int ) -> void:
    var content := $SafeArea/Regions/Sections as Node
    for idx in content.get_child_count():
        var child: CanvasItem = content.get_child( idx ) as CanvasItem
        if child:
            child.visible = idx == index
