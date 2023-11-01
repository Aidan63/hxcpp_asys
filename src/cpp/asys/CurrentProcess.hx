package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::CurrentProcess')
extern class CurrentProcess {
    @:native('::hx::asys::system::CurrentProcess_obj::pid')
    static function pid() : Int;
}