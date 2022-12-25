package asys.native.filesystem;

import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;
import haxe.Int64;
import haxe.NoData;
import haxe.io.Bytes;

class File {
	final native : cpp.asys.File;

    public function write(position:Int64, buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>):Void {
		native.write(
            position,
            buffer.getData(),
            offset,
            length,
            callback.success,
            err -> callback.fail(new FsException(err, native.path)));
	}

    public function read(position:Int64, buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>):Void {
		native.read(
			position,
			buffer.getData(),
			offset,
			length,
			callback.success,
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function info(callback:Callback<FileInfo>):Void {
		native.info(
			callback.success,
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function resize(size : Int, callback:Callback<NoData>):Void {
		native.resize(
			size,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function setPermissions(permissions:FilePermissions, callback:Callback<NoData>):Void {
		native.setPermissions(
			permissions,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function setOwner(user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
		native.setOwner(
			user,
			group,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function setTimes(accessTime:Int, modificationTime:Int, callback:Callback<NoData>):Void {
		native.setTimes(
			accessTime,
			modificationTime,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

	public function flush(callback:Callback<NoData>):Void {
		native.flush(
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

    public function close(callback:Callback<NoData>):Void {
		native.close(
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, native.path)));
	}

	function new(native:cpp.asys.File) {
		this.native = native;
	}
}