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

signal selected( index )


#########################################
#
# Private variables
#

var _group: ButtonGroup = ButtonGroup.new()


#########################################
#
# Overrides
#

func _ready() -> void:
    _init_selectors()


#########################################
#
# Private methods
#

func _init_selectors() -> void:
    _group.connect( "pressed", self, "_on_selector_changed" )

    for idx in get_child_count():
        var btn: Button = get_child( idx ) as Button
        btn.group = _group


#########################################
#
# Event handlers
#

func _on_selector_changed( btn: BaseButton ) -> void:
    emit_signal( "selected", btn.get_index() )
