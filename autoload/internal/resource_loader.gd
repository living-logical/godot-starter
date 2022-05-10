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

signal resource_failed( name, err )
signal resource_loaded( name, res )
signal resource_started( name, count )
signal resource_stage_completed( name, index, count )


#########################################
#
# Constants
#


#########################################
#
# Private variables
#

onready var _thread := Thread.new()
onready var _lock := Mutex.new()
onready var _gate := Semaphore.new()

var _loadQueue = []
var _shouldExit = false


#########################################
#
# Overrides
#

func _ready():
    var err = _thread.start( self, "_on_thread_execute" )
    if err != OK:
        print_debug( "Failed to launch async resource loader thread (%d)" % err )

func _exit_tree():
    _lock.lock()
    _shouldExit = true
    _lock.unlock()
    _gate.post()
    print_debug( "Posted exit to resource thread" )
    _thread.wait_to_finish()
    print_debug( "Thread stopped" )


#########################################
#
# Public methods
#

func is_alive() -> bool:
    return _thread.is_alive()

func load_start( resource: String ) -> void:
    assert( _thread.is_alive() )
    _lock.lock()
    _loadQueue.append( resource )
    _lock.unlock()
    print_debug( "Resource '%s' queued" % resource )
    _gate.post()


#########################################
#
# Private methods
#

func _do_next_load() -> void:
    _lock.lock()
    var resource = _loadQueue.pop_front()
    _lock.unlock()

    print_debug( "[Thread] Loading '%s'" % resource )
    var loader = ResourceLoader.load_interactive( resource )
    var count: int = loader.get_stage_count()
    print_debug( "[Thread] Resource contains %d stages" % count )

    call_deferred( "_on_resource_started", resource, count )
    while true:
        var err = loader.poll()
        match err:
            OK:
                print_debug( "[Thread] Stage complete (%d)" % loader.get_stage() )
                call_deferred( "_on_stage_completed", resource, loader.get_stage(), count )
            ERR_FILE_EOF:
                print_debug( "[Thread] Resource complete" )
                call_deferred( "_on_resource_completed", resource, loader.get_resource(), count )
                break # exit loop
            _:
                print_debug( "[Thread] Resource failed (%d)" % err )
                call_deferred( "_on_resource_failed", resource, err )
                break # exit loop


#########################################
#
# Event handlers
#

func _on_stage_completed( name: String, index: int, stages: int ) -> void:
    emit_signal( "resource_stage_completed", name, index, stages )

func _on_resource_completed( name: String, resource: Resource, stages: int ) -> void:
    emit_signal( "resource_stage_completed", name, stages, stages )
    emit_signal( "resource_loaded", name, resource)

func _on_resource_failed( name: String, err: int ) -> void:
    emit_signal( "resource_failed", name, err )

func _on_resource_started( name: String, stages: int ) -> void:
    emit_signal( "resource_started", name, stages )

func _on_thread_execute() -> void:
    while true:
        # Block until something needs to happen
        _gate.wait()

        # Check for exit or new resource request
        _lock.lock()
        var shouldExit = _shouldExit
        _lock.unlock()

        # if an exit was triggered, we are done
        if shouldExit:
            break

        _do_next_load()
