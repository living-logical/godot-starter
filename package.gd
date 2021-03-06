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

extends Reference


func data() -> Dictionary:
    return {
        "name": "Godot Starter",
        "version": "0.1.0",

        "pause": "res://scenes/pause/pause.tscn",
        "transition": "res://scenes/loading/loading.tscn",
        "scenes": {
            "main": "res://scenes/main/main.tscn",
            "settings": "res://scenes/settings/settings.tscn",
            "spinning-cube": "res://scenes/spinning-cube/spinning-cube.tscn",
        },

        "resolutions": [
            Vector2( 3840, 2160 ),
            Vector2( 2560, 1440 ),
            Vector2( 1920, 1080 ),
            Vector2( 1280, 720 ),
        ],

        "quality": {
            "Low": {
                "anistropic": 2,
                "msaa": 0,
                "fxaa": false,
            },
            "Medium": {
                "anistropic": 4,
                "msaa": 2,
                "fxaa": false,
            },
            "High": {
                "anistropic": 8,
                "msaa": 3,
                "fxaa": true,
            },
            "Ultra": {
                "anistropic": 16,
                "msaa": 4,
                "fxaa": true,
            },
        },
    }
