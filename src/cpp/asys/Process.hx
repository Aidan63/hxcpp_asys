package cpp.asys;

import asys.native.system.AsysError;
import asys.native.system.ProcessOptions;

@:native('::hx::asys::system::Process')
extern class Process {
    @:native('::hx::asys::system::Process::open')
    static function open(ctx : Context, command : String, options : ProcessOptions, onSuccess : cpp.Pointer<ChildProcess>->Void, onFailure : AsysError->Void) : Void;

    function pid() : Int;
}