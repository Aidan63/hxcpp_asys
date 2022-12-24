package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::filesystem::Directory')
extern class Directory {
    function next(batch : Int, cbSuccess : Array<String>->Void, cbFailure : AsysError->Void) : Void;
    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::open')
    static function open(ctx : Context, path : String, onSuccess : Directory->Void, onFailure : AsysError->Void) : Void;
}