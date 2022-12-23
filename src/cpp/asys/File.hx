package cpp.asys;

import haxe.io.BytesData;
import asys.native.system.AsysError;

typedef NativeInfo = {
	/** Time of last access (Unix timestamp) */
	final atime:Int;
	/** Time of last modification (Unix timestamp) */
	final mtime:Int;
	/** Time of last inode change (Unix timestamp) */
	final ctime:Int;
	/** Device number */
	final dev:Int;
	/** Owning user */
	final uid:Int;
	/** Owning group */
	final gid:Int;
	/** Inode number */
	final ino:Int;
	/** Inode protection mode */
	final mode:Int;
	/** Number of links */
	final nlink:Int;
	/** Device type, if inode device */
	final rdev:Int;
	/** Size in bytes */
	final size:Int;
	/** Block size of filesystem for IO operations */
	final blksize:Int;
	/** Number of 512-bytes blocks allocated */
	final blocks:Int;
};

@:native('::hx::asys::filesystem::File')
extern class File {
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
}