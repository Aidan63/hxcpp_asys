package asys.native.filesystem;

import haxe.exceptions.ArgumentException;
import sys.thread.Thread;
import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;
import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;

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
    static public function openFile<T>(path:FilePath, flag:FileOpenFlag<T>, callback:Callback<T>) {
        cpp.asys.File.open(
            @:privateAccess Thread.current().events.context,
            path,
            cast flag,
            file -> callback.success(cast @:privateAccess new File(file)),
            msg -> callback.fail(new FsException(msg, path)));
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
	static public function tempFile(callback:Callback<File>):Void {
		cpp.asys.File.temp(
			@:privateAccess Thread.current().events.context,
			file -> callback.success(cast @:privateAccess new File(file)),
			msg -> callback.fail(new FsException(msg, '')));
	}

	/**
		Read the contents of a file specified by `path`.
	**/
	static public function readBytes(path:FilePath, callback:Callback<Bytes>):Void {
		openFile(path, Read, (error, file) -> {
			switch error {
				case null:
					file.info((error, stat) -> {
						switch error {
							case null:
								final buffer = Bytes.alloc(stat.size);

								file.read(0, buffer, 0, buffer.length, (error, read) -> {
									file.close((_, _) -> {
										// TODO : What should we do if closing fails?
										// create a composite exception?
										
										switch error {
											case null:
												final output = if (read < buffer.length) {
													buffer.sub(0, read);
												} else {
													buffer;
												}

												callback.success(output);
											case exn:
												callback.fail(exn);
										}
									});
								});
							case exn:
								callback.fail(exn);
						}
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Read the contents of a file specified by `path` as a `String`.
		TODO:
		Should this return an error if the file does not contain a valid unicode string?
	**/
	static public function readString(path:FilePath, callback:Callback<String>):Void {
		readBytes(path, (error, bytes) -> {
			switch error {
				case null:
					callback.success(bytes.toString());
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Write `data` into a file specified by `path`
		`flag` controls the behavior.
		By default the file truncated if it exists and created if it does not exist.
		@see asys.native.filesystem.FileOpenFlag for more details.
	**/
	static public function writeBytes(path:FilePath, data:Bytes, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
		openFile(path, flag, (error, file) -> {
			switch error {
				case null:
					file.write(0, data, 0, data.length, (error, _) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(null);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Write `text` into a file specified by `path`
		`flag` controls the behavior.
		By default the file is truncated if it exists and is created if it does not exist.
		@see asys.native.filesystem.FileOpenFlag for more details.
	**/
	static public function writeString(path:FilePath, text:String, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
		writeBytes(path, Bytes.ofString(text), flag, callback);
	}

	/**
		Open directory for listing.
		`maxBatchSize` sets maximum amount of entries returned by a call to `directory.next`.
		In general bigger `maxBatchSize` allows to iterate faster, but requires more
		memory per call to `directory.next`.
		@see asys.native.filesystem.Directory.next
	**/
	static public function openDirectory(path:FilePath, maxBatchSize:Int = 64, callback:Callback<Directory>):Void {
		cpp.asys.Directory.open(
            @:privateAccess Thread.current().events.context,
            path,
            dir -> callback.success(@:privateAccess new Directory(dir, maxBatchSize)),
            msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		List directory contents.
		Does not add `.` and `..` to the result.
		Entries are provided as paths relative to the directory.
	**/
	static public function listDirectory(path:FilePath, callback:Callback<Array<String>>):Void {
		function read(dir:Directory, accumulated:Array<String>, callback:Callback<Array<String>>) {
			dir.next((error, entries) -> {
				switch error {
					case null:
						if (entries.length == 0) {
							callback.success(accumulated);
						} else {
							read(dir, accumulated.concat(entries), callback);
						}
					case exn:
						callback.fail(exn);
				}
			});
		}

		openDirectory(path, (error, dir) -> {
			switch error {
				case null:
					read(dir, [], (error, entries) -> {
						dir.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									callback.success(entries);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Create a directory.
		Default `permissions` equals to octal `0777`, which means read+write+execution
		permissions for everyone.
		If `recursive` is `true`: create missing directories tree all the way down to `path`.
		If `recursive` is `false`: fail if any parent directory of `path` does not exist.
		[cs] `permissions` parameter is ignored when targeting C#
	**/
	static public function createDirectory(path:FilePath, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<NoData>):Void {
		cpp.asys.Directory.create(
            @:privateAccess Thread.current().events.context,
			path,
			if (permissions == null) FilePermissions.octal(0, 7, 7, 7) else permissions,
			recursive,
			() -> callback.success(null),
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Create a directory with auto-generated unique name.
		`prefix` (if provided) is used as the beginning of a generated name.
		The created directory path is passed to the `callback`.
		Default `permissions` equals to octal `0777`, which means read+write+execution
		permissions for everyone.
		If `recursive` is `true`: create missing directories tree all the way down to the generated path.
		If `recursive` is `false`: fail if any parent directory of the generated path does not exist.
		[cs] `permissions` parameter is ignored when targeting C#
	**/
	static public function uniqueDirectory(parentDirectory:FilePath, ?prefix:String, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<String>):Void {
		final rndIntValue = Std.random(2147483647);
		final finalPrefix = if (prefix == null) Std.string(rndIntValue) else '$prefix$rndIntValue';
		final finalPath   = FilePath.createPath(parentDirectory, finalPrefix);

		createDirectory(finalPath, permissions, recursive, (error, _) -> {
			if (error != null) {
				callback.fail(error);
			}
			else {
				callback.success(finalPath);
			}
		});
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
	static public function move(oldPath:FilePath, newPath:FilePath, overwrite:Bool = true, callback:Callback<NoData>):Void {
		if (oldPath == null) {
			callback.fail(new ArgumentException("oldPath", "oldPath was null"));

			return;
		}

		if (newPath == null) {
			callback.fail(new ArgumentException("newPath", "newPath was null"));
			
			return;
		}

		isDirectory(oldPath, (error, isDir) -> {
			if (error != null)
			{
				callback.fail(error);
			}
			else
			{
				if (isDir)
				{
					cpp.asys.Directory.rename(
						@:privateAccess Thread.current().events.context,
						oldPath,
						newPath,
						() -> callback.success(null),
						msg -> callback.fail(new FsException(msg, oldPath))); // TODO : Custom exception for both paths?
				}
				else
				{
					cpp.asys.Directory.copyFile(
						@:privateAccess Thread.current().events.context,
						oldPath,
						newPath,
						overwrite,
						() -> {
							deleteFile(oldPath, (error, _) -> {
								if (error != null) {
									callback.fail(error);
								} else {
									callback.success(_);
								}
							});
						},
						msg -> callback.fail(new FsException(msg, oldPath)));
				}
			}
		});
	}

	/**
		Remove a file or symbolic link.
	**/
	static public function deleteFile(path:FilePath, callback:Callback<NoData>):Void {
		if (path == null) {
			callback.fail(new ArgumentException("path", "null path"));
		} else {
			cpp.asys.Directory.deleteFile(
				@:privateAccess Thread.current().events.context,
				path,
				() -> callback.success(null),
				msg -> callback.fail(new FsException(msg, path)));
		}
	}

	/**
		Remove an empty directory.
	**/
	static public function deleteDirectory(path:FilePath, callback:Callback<NoData>):Void {
		if (path == null) {
			callback.fail(new ArgumentException("path", "null path"));
		} else {
			cpp.asys.Directory.deleteDirectory(
				@:privateAccess Thread.current().events.context,
				path,
				() -> callback.success(null),
				msg -> callback.fail(new FsException(msg, path)));
		}
	}

	/**
		Get file or directory information at the given path.
		If `path` is a symbolic link then the link is followed.
		@see `asys.native.filesystem.FileSystem.linkInfo` to get information of the
		link itself.
	**/
	static public function info(path:FilePath, callback:Callback<FileInfo>):Void {
		openFile(path, Read, (error, file) -> {
			switch error {
				case null:
					file.info((error, info) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(info);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
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
	static public function check(path:FilePath, mode:FileAccessMode, callback:Callback<Bool>):Void {
		cpp.asys.Directory.check(
			@:privateAccess Thread.current().events.context,
			path,
			cast mode,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Check if the path is a directory.
		If `path` is a symbolic links then it will be resolved and checked.
		Returns `false` if `path` does not exist.
	**/
	static public function isDirectory(path:FilePath, callback:Callback<Bool>):Void {
		cpp.asys.Directory.isDirectory(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Check if the path is a regular file.
		If `path` is a symbolic links then it will be resolved and checked.
		Returns `false` if `path` does not exist.
	**/
	static public function isFile(path:FilePath, callback:Callback<Bool>):Void {
		cpp.asys.Directory.isFile(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Set path permissions.
		If `path` is a symbolic link it is dereferenced.
	**/
	static public function setPermissions(path:FilePath, permissions:FilePermissions, callback:Callback<NoData>):Void {
		openFile(path, Read, (error, file) -> {
			switch error {
				case null:
					file.setPermissions(permissions, (error, info) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(info);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Set path owner and group.
		If `path` is a symbolic link it is dereferenced.
	**/
	static public function setOwner(path:FilePath, user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
		openFile(path, Read, (error, file) -> {
			switch error {
				case null:
					file.setOwner(user, group, (error, info) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(info);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Set symbolic link owner and group.
	**/
	static public function setLinkOwner(path:FilePath, user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
		cpp.asys.Directory.setLinkOwner(
			@:privateAccess Thread.current().events.context,
			path,
			user,
			group,
			() -> callback.success(null),
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Create a link to `target` at `path`.
		If `type` is `SymLink` the `target` is expected to be an absolute path or
		a path relative to `path`, however the existance of `target` is not checked
		and the link is created even if `target` does not exist.
		If `type` is `HardLink` the `target` is expected to be an existing path either
		absolute or relative to the current working directory.
	**/
	static public function link(target:FilePath, path:String, type:FileLink = SymLink, callback:Callback<NoData>):Void {
		cpp.asys.Directory.link(
			@:privateAccess Thread.current().events.context,
			target,
			path,
			cast type,
			() -> callback.success(null),
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Check if the path is a symbolic link.
		Returns `false` if `path` does not exist.
	**/
	static public function isLink(path:FilePath, callback:Callback<Bool>):Void {
		cpp.asys.Directory.isLink(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Get the value of a symbolic link.
	**/
	static public function readLink(path:FilePath, callback:Callback<String>):Void {
		cpp.asys.Directory.readLink(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Get information at the given path without following symbolic links.
	**/
	static public function linkInfo(path:FilePath, callback:Callback<FileInfo>):Void {
		cpp.asys.Directory.linkInfo(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}

	/**
		Copy a file from `source` path to `destination` path.
	**/
	static public function copyFile(source:FilePath, destination:FilePath, overwrite:Bool = true, callback:Callback<NoData>):Void {
		cpp.asys.Directory.copyFile(
			@:privateAccess Thread.current().events.context,
			source,
			destination,
			overwrite,
			() -> callback.success(null),
			msg -> callback.fail(new FsException(msg, source)));
	}

	/**
		Shrink or expand a file specified by `path` to `newSize` bytes.
		If the file does not exist, it is created.
		If the file is larger than `newSize`, the extra data is lost.
		If the file is shorter, zero bytes are used to fill the added length.
	**/
	static public function resize(path:FilePath, newSize:Int, callback:Callback<NoData>):Void {
		openFile(path, Write, (error, file) -> {
			switch error {
				case null:
					file.resize(newSize, (error, _) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(null);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Change access and modification times of an existing file.
		TODO: Decide on type for `accessTime` and `modificationTime` - see TODO in `asys.native.filesystem.FileInfo.FileStat`
	**/
	static public function setTimes(path:FilePath, accessTime:Int, modificationTime:Int, callback:Callback<NoData>):Void {
		openFile(path, Write, (error, file) -> {
			switch error {
				case null:
					file.setTimes(accessTime, modificationTime, (error, _) -> {
						file.close((_, _) -> {
							// TODO : What should we do if closing fails?
							// create a composite exception?

							switch error {
								case null:
									// Should we error if not all of the data was written?
									callback.success(null);
								case exn:
									callback.fail(exn);
							}
						});
					});
				case exn:
					callback.fail(exn);
			}
		});
	}

	/**
		Get a canonical absolute path. The path must exist.
		Resolves intermediate `.`, `..`, excessive slashes.
		Resolves symbolic links on all targets except C#.
	**/
	static public function realPath(path:FilePath, callback:Callback<String>):Void {
		cpp.asys.Directory.realPath(
			@:privateAccess Thread.current().events.context,
			path,
			callback.success,
			msg -> callback.fail(new FsException(msg, path)));
	}
}