package asys.native.filesystem;

import sys.thread.Thread;
import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;
import haxe.Int64;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import haxe.coro.schedulers.Scheduler;

using hxcoro.util.Convenience;

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
    @:coroutine public function write(position:Int, buffer:Bytes, offset:Int, length:Int):Int {
		if (position < 0) {
			throw new FsException(IoErrorType.CustomError("Invalid position"), path);
		}

		if (buffer == null) {
			throw new FsException(IoErrorType.CustomError("Null buffer"), path);
		}

		if (offset < 0 || offset > buffer.length) {
			throw new FsException(IoErrorType.CustomError("Invalid offset"), path);
		}

		final actualLength = (cast Math.min(length, buffer.length - offset) : Int);

		if (actualLength < 0) {
			throw new FsException(IoErrorType.CustomError("Invalid length"), path);
		}

		if (actualLength == 0) {
			return 0;
		}

		return
			hxcoro.Coro.suspend(cont -> {
				native.write(
					position,
					buffer.getData(),
					offset,
					actualLength,
					count -> cont.succeedAsync(count),
					err -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(0, new FsException(err, path))));
			});
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
    @:coroutine public function read(position:Int, buffer:Bytes, offset:Int, length:Int):Int {
		if (position < 0) {
			throw new FsException(IoErrorType.CustomError("Invalid position"), path);
		}

		if (buffer == null) {
			throw new FsException(IoErrorType.CustomError("Null buffer"), path);
		}

		if (offset < 0 || offset > buffer.length) {
			throw new FsException(IoErrorType.CustomError("Invalid offset"), path);
		}

		if (length < 0) {
			throw new FsException(IoErrorType.CustomError("Invalid length"), path);
		}

		final actualLength = (cast Math.min(length, buffer.length - offset) : Int);

		return
			hxcoro.Coro.suspend(cont -> {
				native.read(
					position,
					buffer.getData(),
					offset,
					actualLength,
					count -> cont.succeedAsync(count),
					err -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(0, new FsException(err, path))));
			});
	}

	@:coroutine public function info() : FileInfo {
		return hxcoro.Coro.suspend(cont -> {
			native.info(
				info -> cont.succeedAsync(info),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	@:coroutine public function resize(size : Int) {
		hxcoro.Coro.suspend(cont -> {
			native.resize(
				size,
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	@:coroutine public function setPermissions(permissions:FilePermissions) {
		hxcoro.Coro.suspend(cont -> {
			native.setPermissions(
				permissions,
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	@:coroutine public function setOwner(user:SystemUser, group:SystemGroup) {
		hxcoro.Coro.suspend(cont -> {
			native.setOwner(
				user,
				group,
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	@:coroutine public function setTimes(accessTime:Int, modificationTime:Int) {
		hxcoro.Coro.suspend(cont -> {
			native.setTimes(
				accessTime,
				modificationTime,
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	@:coroutine public function flush() {
		hxcoro.Coro.suspend(cont -> {
			native.flush(
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

    @:coroutine public function close() {
		hxcoro.Coro.suspend(cont -> {
			native.close(
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}
}