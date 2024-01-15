package asys.native.filesystem;

import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;
import haxe.Int64;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;

private class WriteRequest {
	/**
	 * Current offset into the bytes buffer.
	 * This may differ from the bytes offset if multiple smaller chunks are needed to complete the overall request.
	 */
	public var currentOffset:Int;

	/**
	 * The starting offset into the bytes for the overall request.
	 */
	public final bytesOffset:Int;

	/**
	 * The total length for the overall request.
	 */
	public final bytesLength:Int;

	/**
	 * The starting position into the file for the overall request.
	 */
	public final filePos:Int64;

	/**
	 * Bytes to copy into the file.
	 */
	public final bytes:Bytes;

	/**
	 * Callback to invoke once the overall request has completed.
	 */
	public final callback:Callback<Int>;

	public function new(_bytesOffset:Int, _bytesLength:Int, _filePos:Int64, _bytes:Bytes, _callback:Callback<Int>) {
		currentOffset = _bytesOffset;
		bytesOffset   = _bytesOffset;
		bytesLength   = _bytesLength;
		filePos       = _filePos;
		bytes         = _bytes;
		callback      = _callback;
	}
}

private enum QueuedOperation {
	Write(request:WriteRequest);
	Flush(callback:Callback<NoData>);
}

class File {
	final native : cpp.asys.File;

	public final path : FilePath;

	function new(native:cpp.asys.File) {
		this.native = native;
		this.path   = native.path;
	}

	/**
		Write up to `length` bytes from `buffer` starting at the buffer `offset`
		to the file starting at the file `position`, then invoke `callback` with
		the amount of bytes written.
		If `position` is greater than the file size then the file will be grown
		to the required size with the zero bytes before writing.
		If `position` is negative or `offset` is outside of `buffer` bounds or
		if `length` is negative, an error is passed to the `callback`.
	**/
    public function write(position:Int64, buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>):Void {
		if (position < 0) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid position"), path));

			return;
		}

		if (buffer == null) {
			callback.fail(new FsException(IoErrorType.CustomError("Null buffer"), path));

			return;
		}

		if (offset < 0 || offset > buffer.length) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid offset"), path));

			return;
		}

		final actualLength = (cast Math.min(length, buffer.length - offset) : Int);

		if (actualLength < 0) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid length"), path));

			return;
		}

		if (actualLength == 0) {
			callback.success(0);

			return;
		}

		native.write(
			position,
			buffer.getData(),
			offset,
			actualLength,
			callback.success,
			err -> callback.fail(new FsException(err, path)));
	}

	/**
		Read up to `length` bytes from the file `position` and write them into
		`buffer` starting at `offset` position in `buffer`, then invoke `callback`
		with the amount of bytes read.
		If `position` is greater or equal to the file size at the moment of reading
		then `0` is passed to the `callback` and `buffer` is unaffected.
		If `position` is negative or `offset` is outside of `buffer` bounds, an
		error is passed to the `callback`.
	**/
    public function read(position:Int64, buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>):Void {
		if (position < 0) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid position"), path));

			return;
		}

		if (buffer == null) {
			callback.fail(new FsException(IoErrorType.CustomError("Null buffer"), path));

			return;
		}

		if (offset < 0 || offset > buffer.length) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid offset"), path));

			return;
		}

		if (length < 0) {
			callback.fail(new FsException(IoErrorType.CustomError("Invalid length"), path));

			return;
		}

		final actualLength = (cast Math.min(length, buffer.length - offset) : Int);

		native.read(
			position,
			buffer.getData(),
			offset,
			actualLength,
			callback.success,
			err -> callback.fail(new FsException(err, path)));
	}

	public function info(callback:Callback<FileInfo>):Void {
		native.info(
			callback.success,
			err -> callback.fail(new FsException(err, path)));
	}

	public function resize(size : Int, callback:Callback<NoData>):Void {
		native.resize(
			size,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}

	public function setPermissions(permissions:FilePermissions, callback:Callback<NoData>):Void {
		native.setPermissions(
			permissions,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}

	public function setOwner(user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
		native.setOwner(
			user,
			group,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}

	public function setTimes(accessTime:Int, modificationTime:Int, callback:Callback<NoData>):Void {
		native.setTimes(
			accessTime,
			modificationTime,
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}

	public function flush(callback:Callback<NoData>):Void {
		native.flush(
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}

    public function close(callback:Callback<NoData>):Void {
		native.close(
			() -> callback.success(null),
			err -> callback.fail(new FsException(err, path)));
	}
}