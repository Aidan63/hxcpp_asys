package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::system::CurrentProcess')
extern class CurrentProcess extends Process {
    final stdio_in : Readable;
    final stdio_out : Writable;
    final stdio_err : Writable;

    function setSignalAction(signal:cpp.EnumBase, action:cpp.EnumBase):Void;
}