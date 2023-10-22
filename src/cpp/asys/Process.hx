package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::Process')
extern class Process {
    @:native('::hx::asys::system::Process_obj::open')
    static function open(ctx : Context, command : String, options : Any, onSuccess : ChildProcess->Void, onFailure : AsysError->Void) : Void;

    function pid() : Int;
}