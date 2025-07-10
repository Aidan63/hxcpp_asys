package asys.native.filesystem;

import cpp.asys.AsysError;
import haxe.exceptions.ArgumentException;
import sys.thread.Thread;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;
import haxe.coro.schedulers.Scheduler;

using hxcoro.util.Convenience;

class FileSystem {
    /**
		Open file for reading and/or writing.
		Depending on `flag` value `callback` will be invoked with the appropriate
		object type to read and/or write the file:
		- `asys.native.filesystem.File` for reading and writing;
		- `asys.native.filesystem.FileRead` for reading only;
		- `asys.native.filesystem.FileWrite` for writing only;
		- `asys.native.filesystem.FileAppend` for writing to the end of file only;
		@see asys.native.filesystem.FileOpenFlag for more details.
	**/
    @:coroutine static public function openFile<T>(path:FilePath, flag:FileOpenFlag<T>):T {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.File.open(
				cpp.asys.Context.get(),
				path,
				cast flag,
				file -> cont.succeedAsync(cast @:privateAccess new File(file)),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
    }

	/**
		Create and open a unique temporary file for writing and reading.
		The file will be automatically deleted when it is closed.
		Depending on a target platform the file may be automatically deleted upon
		application shutdown, but in general deletion is not guaranteed if the `close`
		method is not called.
		Depending on a target platform the directory entry for the file may be deleted
		immediately after the file is created or even not created at all.
	**/
	@:coroutine static public function tempFile():File {
		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.File.temp(
				cpp.asys.Context.get(),
				file -> cont.succeedAsync(cast @:privateAccess new File(file)),
				msg -> cont.failAsync(new FsException(msg, '')));
		});
	}

	/**
		Read the contents of a file specified by `path`.
	**/
	@:coroutine static public function readBytes(path:FilePath):Bytes {
		final file = FileSystem.openFile(path, Read);

		try {
			final stat   = file.info();
			final buffer = Bytes.alloc(stat.size);
			final count  = file.read(0, buffer, 0, buffer.length);

			file.close();

			if (count < buffer.length) {
				return buffer.sub(0, count);
			} else {
				return buffer;
			}
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Read the contents of a file specified by `path` as a `String`.
		TODO:
		Should this return an error if the file does not contain a valid unicode string?
	**/
	@:coroutine static public function readString(path:FilePath):String {
		return readBytes(path).toString();
	}

	/**
		Write `data` into a file specified by `path`
		`flag` controls the behavior.
		By default the file truncated if it exists and created if it does not exist.
		@see asys.native.filesystem.FileOpenFlag for more details.
	**/
	@:coroutine static public function writeBytes(path:FilePath, data:Bytes, flag:FileOpenFlag<Dynamic>) {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		if (data == null) {
			throw new ArgumentException("data", "data was null");
		}

		final file = openFile(path, flag);
		try {
			file.write(0, data, 0, data.length);
			file.close();
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Write `text` into a file specified by `path`
		`flag` controls the behavior.
		By default the file is truncated if it exists and is created if it does not exist.
		@see asys.native.filesystem.FileOpenFlag for more details.
	**/
	@:coroutine static public function writeString(path:FilePath, text:String, flag:FileOpenFlag<Dynamic>) {
		writeBytes(path, Bytes.ofString(text), flag);
	}

	/**
		Open directory for listing.
		`maxBatchSize` sets maximum amount of entries returned by a call to `directory.next`.
		In general bigger `maxBatchSize` allows to iterate faster, but requires more
		memory per call to `directory.next`.
		@see asys.native.filesystem.Directory.next
	**/
	@:coroutine static public function openDirectory(path:FilePath, maxBatchSize:Int):Directory {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		if (maxBatchSize <= 0) {
			throw new ArgumentException("maxBatchSize", "batch size was less than or equal to 0");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.open(
				cpp.asys.Context.get(),
				path,
				dir -> cont.succeedAsync(@:privateAccess new Directory(dir, maxBatchSize)),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		List directory contents.
		Does not add `.` and `..` to the result.
		Entries are provided as paths relative to the directory.
	**/
	@:coroutine static public function listDirectory(path:FilePath):Array<String> {
		final dir = openDirectory(path, 64);
		final acc = [];

		try {
			do
			{
				switch dir.next() {
					case []:
						dir.close();
						
						return acc;
					case extra:
						for (f in extra) {
							acc.push(f);
						}
				}
			}
			while (true);
		} catch (exn) {
			dir?.close();
			throw exn;
		}
	}

	/**
		Create a directory.
		Default `permissions` equals to octal `0777`, which means read+write+execution
		permissions for everyone.
		If `recursive` is `true`: create missing directories tree all the way down to `path`.
		If `recursive` is `false`: fail if any parent directory of `path` does not exist.
	**/
	@:coroutine static public function createDirectory(path:FilePath, permissions:Null<FilePermissions>, recursive:Null<Bool>) {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		final ctx    = cpp.asys.Context.get();
		final mode   = permissions ?? FilePermissions.octal(0, 7, 7, 7);
		final manual = recursive ?? false;

		@:coroutine inline function create(path:FilePath) {
			return hxcoro.Coro.suspend(cont -> {
				cpp.asys.Directory.create(
					ctx,
					path,
					mode,
					() -> cont.succeedAsync(null),
					msg -> cont.failAsync(new FsException(msg, path)));
			});
		}

		if (manual) {
			var toSearch = path;

			final checked = [];

			while (true) {
				try {
					create(toSearch);

					switch checked {
						case []:
							return;
						case _:
							toSearch = toSearch.add(checked.shift());
					}
				} catch (exn:FsException) {
					// Each time directory creation fails insert that name into the array.
					// TODO : Only do this on the error associated with recursive creation.
					checked.insert(0, toSearch.name());

					toSearch = toSearch.parent();

					if ('' == toSearch) {
						throw exn;
					}
				}
			}
		} else {
			create(path);
		}
	}

	/**
		Create a directory with auto-generated unique name.
		`prefix` (if provided) is used as the beginning of a generated name.
		The created directory path is passed to the `callback`.
		Default `permissions` equals to octal `0777`, which means read+write+execution permissions for everyone.
		If `recursive` is `true`: create missing directories tree all the way down to the generated path.
		If `recursive` is `false`: fail if any parent directory of the generated path does not exist.
	**/
	@:coroutine static public function uniqueDirectory(parentDirectory:FilePath, prefix:Null<String>, permissions:Null<FilePermissions>, recursive:Null<Bool>):String {
		if (parentDirectory == null) {
			throw new ArgumentException("parentDirectory", "parent directory was null");
		}

		final rndIntValue = Std.random(2147483647);
		final finalPrefix = if (prefix == null) Std.string(rndIntValue) else '$prefix$rndIntValue';
		final finalPath   = FilePath.createPath(parentDirectory, finalPrefix);

		createDirectory(finalPath, permissions, recursive);

		return finalPath;
	}

	/**
		Move and/or rename the file or directory from `oldPath` to `newPath`.
		If `newPath` already exists and `overwrite` is `true` (which is the default)
		the destination is overwritten. However, operation fails if `newPath` is
		a non-empty directory.
		If `overwrite` is `false` the operation is not guaranteed to be atomic.
		That means if a third-party process creates `newPath` right in between the
		check for existance and the actual move operation then the data created
		by that third-party process may be overwritten.
	**/
	@:coroutine static public function move(oldPath:FilePath, newPath:FilePath, overwrite:Null<Bool>) {
		if (oldPath == null) {
			throw new ArgumentException("oldPath", "oldPath was null");
		}

		if (newPath == null) {
			throw new ArgumentException("newPath", "newPath was null");
		}

		if (isDirectory(oldPath)) {
			hxcoro.Coro.suspend(cont -> {
				cpp.asys.Directory.rename(
					cpp.asys.Context.get(),
					oldPath,
					newPath,
					() -> cont.succeedAsync(null),
					msg -> cont.failAsync(new FsException(msg, oldPath))); // TODO : Custom exception for both paths?
			});
		} else {
			copyFile(oldPath, newPath, overwrite ?? true);
			deleteFile(oldPath);
		}
	}

	/**
		Remove a file or symbolic link.
	**/
	@:coroutine static public function deleteFile(path:FilePath) {
		if (path == null) {
			throw new ArgumentException("path", "null path");
		}

		hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.deleteFile(
				cpp.asys.Context.get(),
				path,
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Remove an empty directory.
	**/
	@:coroutine static public function deleteDirectory(path:FilePath) {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.deleteDirectory(
				cpp.asys.Context.get(),
				path,
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Get file or directory information at the given path.
		If `path` is a symbolic link then the link is followed.
		@see `asys.native.filesystem.FileSystem.linkInfo` to get information of the
		link itself.
	**/
	@:coroutine static public function info(path:FilePath):FileInfo {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.File.info(
				cpp.asys.Context.get(),
				path,
				info -> cont.succeedAsync(info),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Check user's access for a path.
		For example to check if a file is readable and writable:
		```haxe
		import asys.native.filesystem.FileAccessMode;
		FileSystem.check(path, Readable | Writable, (error, result) -> trace(result));
		```
	**/
	@:coroutine static public function check(path:FilePath, mode:FileAccessMode):Bool {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.check(
				cpp.asys.Context.get(),
				path,
				cast mode,
				cont.succeedAsync,
				msg -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(false, new FsException(msg, path))));
		});
	}

	/**
		Check if the path is a directory.
		If `path` is a symbolic links then it will be resolved and checked.
		Returns `false` if `path` does not exist.
	**/
	@:coroutine static public function isDirectory(path:FilePath):Bool {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.isDirectory(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(false, new FsException(msg, path))));
		});
	}

	/**
		Check if the path is a regular file.
		If `path` is a symbolic links then it will be resolved and checked.
		Returns `false` if `path` does not exist.
	**/
	@:coroutine static public function isFile(path:FilePath):Bool {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.isFile(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(false, new FsException(msg, path))));
		});
	}

	/**
		Set path permissions.
		If `path` is a symbolic link it is dereferenced.
	**/
	@:coroutine static public function setPermissions(path:FilePath, permissions:FilePermissions) {
		final file = openFile(path, Read);
		try {
			file.setPermissions(permissions);
			file.close();
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Set path owner and group.
		If `path` is a symbolic link it is dereferenced.
	**/
	@:coroutine static public function setOwner(path:FilePath, user:SystemUser, group:SystemGroup) {
		final file = openFile(path, Read);
		try {
			file.setOwner(user, group);
			file.close();
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Set symbolic link owner and group.
	**/
	@:coroutine static public function setLinkOwner(path:FilePath, user:SystemUser, group:SystemGroup) {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.setLinkOwner(
				cpp.asys.Context.get(),
				path,
				user,
				group,
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Create a link to `target` at `path`.
		If `type` is `SymLink` the `target` is expected to be an absolute path or
		a path relative to `path`, however the existance of `target` is not checked
		and the link is created even if `target` does not exist.
		If `type` is `HardLink` the `target` is expected to be an existing path either
		absolute or relative to the current working directory.
	**/
	@:coroutine static public function link(target:FilePath, path:String, type:Null<FileLink>) {
		if (target == null) {
			throw new ArgumentException("target", "target was null");
		}

		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.link(
				cpp.asys.Context.get(),
				target,
				path,
				cast (type ?? SymLink),
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Check if the path is a symbolic link.
		Returns `false` if `path` does not exist.
	**/
	@:coroutine static public function isLink(path:FilePath):Bool {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.isLink(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.context.get(Scheduler).schedule(0, () -> cont.resume(false, new FsException(msg, path))));
		});
	}

	/**
		Get the value of a symbolic link.
	**/
	@:coroutine static public function readLink(path:FilePath):String {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.readLink(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Get information at the given path without following symbolic links.
	**/
	@:coroutine static public function linkInfo(path:FilePath):FileInfo {
		if (path == null) {
			throw new ArgumentException("path", "path was null");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.linkInfo(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}

	/**
		Copy a file from `source` path to `destination` path.
	**/
	@:coroutine static public function copyFile(source:FilePath, destination:FilePath, overwrite:Null<Bool>) {
		if (source == null) {
			throw new ArgumentException("source", "source was null");
		}

		if (destination == null) {
			throw new ArgumentException("destination", "destination was null");
		}

		hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.copyFile(
				cpp.asys.Context.get(),
				source,
				destination,
				overwrite ?? true,
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new FsException(msg, source)));
		});
	}

	/**
		Shrink or expand a file specified by `path` to `newSize` bytes.
		If the file does not exist, it is created.
		If the file is larger than `newSize`, the extra data is lost.
		If the file is shorter, zero bytes are used to fill the added length.
	**/
	@:coroutine static public function resize(path:FilePath, newSize:Int) {
		final file = openFile(path, Overwrite);
		try {
			file.resize(newSize);
			file.close();
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Change access and modification times of an existing file.
		TODO: Decide on type for `accessTime` and `modificationTime` - see TODO in `asys.native.filesystem.FileInfo.FileStat`
	**/
	@:coroutine static public function setTimes(path:FilePath, accessTime:Int, modificationTime:Int) {
		final file = openFile(path, Overwrite);
		try {
			file.setTimes(accessTime, modificationTime);
			file.close();
		} catch (exn) {
			file?.close();

			throw exn;
		}
	}

	/**
		Get a canonical absolute path. The path must exist.
		Resolves intermediate `.`, `..`, excessive slashes.
		Resolves symbolic links on all targets except C#.
	**/
	@:coroutine static public function realPath(path:FilePath):String {
		if (path == null) {
			throw new ArgumentException("path");
		}

		return hxcoro.Coro.suspend(cont -> {
			cpp.asys.Directory.realPath(
				cpp.asys.Context.get(),
				path,
				cont.succeedAsync,
				msg -> cont.failAsync(new FsException(msg, path)));
		});
	}
}