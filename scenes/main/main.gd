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
# Overrides
#

func _ready():
    ($SafeArea/BottomArea/Version/Game as Label).text =\
        "Version: v%s" % ProjectSettings.get_setting("application/config/version")
    ($SafeArea/BottomArea/Version/Engine as Label).text =\
        "Engine: Godot %s" % Engine.get_version_info().string
    ($SafeArea/MainArea/Content/Menu/Play as Control).grab_focus()

    # The main menu never cares about the pause state
    pause_mode = Node.PAUSE_MODE_PROCESS


#########################################
#
# Event handlers
#

func _on_Play_pressed() -> void:
    Game.change_scene( "spinning-cube" )


func _on_Settings_pressed() -> void:
    Game.change_scene( "settings" )

func _on_Exit_pressed() -> void:
    Game.exit()
