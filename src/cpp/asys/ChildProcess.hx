package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::ChildProcess')
extern class ChildProcess extends Process {
    function exitCode(onSuccess : Int->Void, onFailure : AsysError->Void) : Void;

    function close(onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
}