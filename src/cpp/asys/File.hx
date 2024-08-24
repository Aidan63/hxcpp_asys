package cpp.asys;

import haxe.io.BytesData;
import cpp.asys.AsysError;

@:native('::hx::asys::filesystem::File')
extern class File {
	final path : String;

    function write(pos : haxe.Int64, data : BytesData, offset : Int, length : Int, cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;
    function read(pos : haxe.Int64, buffer : BytesData, offset : Int, length : Int, cbSuccess : Int->Void, cbFailure : AsysError->Void) : Void;
    function info(cbSuccess : NativeInfo->Void, cbFailure : AsysError->Void) : Void;
	function resize(size : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
	function setPermissions(permissions : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
	function setOwner(user : Int, group : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
	function setTimes(accessTime : Int, modificationTime : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
	function flush(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::File_obj::open')
    static function open(ctx : Context, path : String, flags : Int, onSuccess : File->Void, onFailure : AsysError->Void) : Void;

	@:native('::hx::asys::filesystem::File_obj::temp')
    static function temp(ctx : Context, onSuccess : File->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::File_obj::info')
    static function info(ctx : Context, path : String, onSuccess : NativeInfo->Void, onFailure : AsysError->Void) : Void;
}