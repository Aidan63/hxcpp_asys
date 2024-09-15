package asys.native.filesystem;

import cpp.asys.AsysError;
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
		if (path == null) {
			callback.fail(new ArgumentException("path", "path was null"));

			return;
		}

		final events = Thread.current().events;

        cpp.asys.File.open(
            @:privateAccess Thread.current().context(),
            path,
            cast flag,
            file -> events.run(() -> callback.success(cast @:privateAccess new File(file))),
            msg -> events.run(() -> callback.fail(new FsException(msg, path))));
    }

	// /**
	// 	Create and open a unique temporary file for writing and reading.
	// 	The file will be automatically deleted when it is closed.
	// 	Depending on a target platform the file may be automatically deleted upon
	// 	application shutdown, but in general deletion is not guaranteed if the `close`
	// 	method is not called.
	// 	Depending on a target platform the directory entry for the file may be deleted
	// 	immediately after the file is created or even not created at all.
	// **/
	// static public function tempFile(callback:Callback<File>):Void {
	// 	cpp.asys.File.temp(
	// 		@:privateAccess Thread.current().context(),
	// 		file -> callback.success(cast @:privateAccess new File(file)),
	// 		msg -> callback.fail(new FsException(msg, '')));
	// }

	// /**
	// 	Read the contents of a file specified by `path`.
	// **/
	// static public function readBytes(path:FilePath, callback:Callback<Bytes>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	openFile(path, Read, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.info((stat, error) -> {
	// 					switch error {
	// 						case null:
	// 							final buffer = Bytes.alloc(stat.size);

	// 							file.read(0, buffer, 0, buffer.length, (read, error) -> {
	// 								file.close((_, _) -> {
	// 									// TODO : What should we do if closing fails?
	// 									// create a composite exception?
										
	// 									switch error {
	// 										case null:
	// 											final output = if (read < buffer.length) {
	// 												buffer.sub(0, read);
	// 											} else {
	// 												buffer;
	// 											}

	// 											callback.success(output);
	// 										case exn:
	// 											callback.fail(exn);
	// 									}
	// 								});
	// 							});
	// 						case exn:
	// 							callback.fail(exn);
	// 					}
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Read the contents of a file specified by `path` as a `String`.
	// 	TODO:
	// 	Should this return an error if the file does not contain a valid unicode string?
	// **/
	// static public function readString(path:FilePath, callback:Callback<String>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	readBytes(path, (bytes, error) -> {
	// 		switch error {
	// 			case null:
	// 				callback.success(bytes.toString());
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Write `data` into a file specified by `path`
	// 	`flag` controls the behavior.
	// 	By default the file truncated if it exists and created if it does not exist.
	// 	@see asys.native.filesystem.FileOpenFlag for more details.
	// **/
	// static public function writeBytes(path:FilePath, data:Bytes, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	if (data == null) {
	// 		callback.fail(new ArgumentException("data", "data was null"));

	// 		return;
	// 	}

	// 	openFile(path, flag, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.write(0, data, 0, data.length, (_, error) -> {
	// 					file.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								// Should we error if not all of the data was written?
	// 								callback.success(null);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Write `text` into a file specified by `path`
	// 	`flag` controls the behavior.
	// 	By default the file is truncated if it exists and is created if it does not exist.
	// 	@see asys.native.filesystem.FileOpenFlag for more details.
	// **/
	// static public function writeString(path:FilePath, text:String, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
	// 	if (text == null) {
	// 		callback.fail(new ArgumentException("text", "text was null"));

	// 		return;
	// 	}

	// 	writeBytes(path, Bytes.ofString(text), flag, callback);
	// }

	// /**
	// 	Open directory for listing.
	// 	`maxBatchSize` sets maximum amount of entries returned by a call to `directory.next`.
	// 	In general bigger `maxBatchSize` allows to iterate faster, but requires more
	// 	memory per call to `directory.next`.
	// 	@see asys.native.filesystem.Directory.next
	// **/
	// static public function openDirectory(path:FilePath, maxBatchSize:Int = 64, callback:Callback<Directory>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	if (maxBatchSize <= 0) {
	// 		callback.fail(new ArgumentException("maxBatchSize", "batch size was less than or equal to 0"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.open(
    //         @:privateAccess Thread.current().context(),
    //         path,
    //         dir -> callback.success(@:privateAccess new Directory(dir, maxBatchSize)),
    //         msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	List directory contents.
	// 	Does not add `.` and `..` to the result.
	// 	Entries are provided as paths relative to the directory.
	// **/
	// static public function listDirectory(path:FilePath, callback:Callback<Array<String>>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	function read(dir:Directory, accumulated:Array<String>, callback:Callback<Array<String>>) {
	// 		dir.next((entries, error) -> {
	// 			switch error {
	// 				case null:
	// 					if (entries.length == 0) {
	// 						callback.success(accumulated);
	// 					} else {
	// 						read(dir, accumulated.concat(entries), callback);
	// 					}
	// 				case exn:
	// 					callback.fail(exn);
	// 			}
	// 		});
	// 	}

	// 	openDirectory(path, (dir, error) -> {
	// 		switch error {
	// 			case null:
	// 				read(dir, [], (entries, error) -> {
	// 					dir.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								callback.success(entries);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Create a directory.
	// 	Default `permissions` equals to octal `0777`, which means read+write+execution
	// 	permissions for everyone.
	// 	If `recursive` is `true`: create missing directories tree all the way down to `path`.
	// 	If `recursive` is `false`: fail if any parent directory of `path` does not exist.
	// 	[cs] `permissions` parameter is ignored when targeting C#
	// **/
	// static public function createDirectory(path:FilePath, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	final ctx  = @:privateAccess Thread.current().context();
	// 	final mode = if (permissions == null) FilePermissions.octal(0, 7, 7, 7) else permissions;

	// 	if (recursive) {
	// 		var toSearch = path;

	// 		final checked = [];

	// 		function onSuccess() {
	// 			// On the first success start working our way 
	// 			switch checked {
	// 				case []:
	// 					callback.success(null);
	// 				case _:
	// 					toSearch = toSearch.add(checked.shift());

	// 					cpp.asys.Directory.create(
	// 						ctx,
	// 						toSearch,
	// 						mode,
	// 						onSuccess,
	// 						msg -> callback.fail(new FsException(msg, path)));
	// 			}
	// 		}

	// 		function onError(error:AsysError) {
	// 			// Each time directory creation fails insert that name into the array.
	// 			// TODO : Only do this on the error associated with recursive creation.
	// 			checked.insert(0, toSearch.name());

	// 			toSearch = toSearch.parent();

	// 			if ('' == toSearch) {
	// 				callback.fail(new FsException(error, path));
	// 			} else {
	// 				cpp.asys.Directory.create(ctx, toSearch, mode, onSuccess, onError);
	// 			}
	// 		}

	// 		cpp.asys.Directory.create(ctx, toSearch, mode, onSuccess, onError);

	// 	} else {
	// 		cpp.asys.Directory.create(
	// 			ctx,
	// 			path,
	// 			mode,
	// 			() -> callback.success(null),
	// 			msg -> callback.fail(new FsException(msg, path)));
	// 	}
	// }

	// /**
	// 	Create a directory with auto-generated unique name.
	// 	`prefix` (if provided) is used as the beginning of a generated name.
	// 	The created directory path is passed to the `callback`.
	// 	Default `permissions` equals to octal `0777`, which means read+write+execution
	// 	permissions for everyone.
	// 	If `recursive` is `true`: create missing directories tree all the way down to the generated path.
	// 	If `recursive` is `false`: fail if any parent directory of the generated path does not exist.
	// 	[cs] `permissions` parameter is ignored when targeting C#
	// **/
	// static public function uniqueDirectory(parentDirectory:FilePath, ?prefix:String, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<String>):Void {
	// 	if (parentDirectory == null) {
	// 		callback.fail(new ArgumentException("parentDirectory", "parent directory was null"));

	// 		return;
	// 	}

	// 	final rndIntValue = Std.random(2147483647);
	// 	final finalPrefix = if (prefix == null) Std.string(rndIntValue) else '$prefix$rndIntValue';
	// 	final finalPath   = FilePath.createPath(parentDirectory, finalPrefix);

	// 	createDirectory(finalPath, permissions, recursive, (_, error) -> {
	// 		if (error != null) {
	// 			callback.fail(error);
	// 		}
	// 		else {
	// 			callback.success(finalPath);
	// 		}
	// 	});
	// }

	// /**
	// 	Move and/or rename the file or directory from `oldPath` to `newPath`.
	// 	If `newPath` already exists and `overwrite` is `true` (which is the default)
	// 	the destination is overwritten. However, operation fails if `newPath` is
	// 	a non-empty directory.
	// 	If `overwrite` is `false` the operation is not guaranteed to be atomic.
	// 	That means if a third-party process creates `newPath` right in between the
	// 	check for existance and the actual move operation then the data created
	// 	by that third-party process may be overwritten.
	// **/
	// static public function move(oldPath:FilePath, newPath:FilePath, overwrite:Bool = true, callback:Callback<NoData>):Void {
	// 	if (oldPath == null) {
	// 		callback.fail(new ArgumentException("oldPath", "oldPath was null"));

	// 		return;
	// 	}

	// 	if (newPath == null) {
	// 		callback.fail(new ArgumentException("newPath", "newPath was null"));
			
	// 		return;
	// 	}

	// 	isDirectory(oldPath, (isDir, error) -> {
	// 		if (error != null)
	// 		{
	// 			callback.fail(error);
	// 		}
	// 		else
	// 		{
	// 			if (isDir)
	// 			{
	// 				cpp.asys.Directory.rename(
	// 					@:privateAccess Thread.current().context(),
	// 					oldPath,
	// 					newPath,
	// 					() -> callback.success(null),
	// 					msg -> callback.fail(new FsException(msg, oldPath))); // TODO : Custom exception for both paths?
	// 			}
	// 			else
	// 			{
	// 				cpp.asys.Directory.copyFile(
	// 					@:privateAccess Thread.current().context(),
	// 					oldPath,
	// 					newPath,
	// 					overwrite,
	// 					() -> {
	// 						deleteFile(oldPath, (_, error) -> {
	// 							if (error != null) {
	// 								callback.fail(error);
	// 							} else {
	// 								callback.success(_);
	// 							}
	// 						});
	// 					},
	// 					msg -> callback.fail(new FsException(msg, oldPath)));
	// 			}
	// 		}
	// 	});
	// }

	// /**
	// 	Remove a file or symbolic link.
	// **/
	// static public function deleteFile(path:FilePath, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "null path"));
	// 	} else {
	// 		cpp.asys.Directory.deleteFile(
	// 			@:privateAccess Thread.current().context(),
	// 			path,
	// 			() -> callback.success(null),
	// 			msg -> callback.fail(new FsException(msg, path)));
	// 	}
	// }

	// /**
	// 	Remove an empty directory.
	// **/
	// static public function deleteDirectory(path:FilePath, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));
	// 	} else {
	// 		cpp.asys.Directory.deleteDirectory(
	// 			@:privateAccess Thread.current().context(),
	// 			path,
	// 			() -> callback.success(null),
	// 			msg -> callback.fail(new FsException(msg, path)));
	// 	}
	// }

	// /**
	// 	Get file or directory information at the given path.
	// 	If `path` is a symbolic link then the link is followed.
	// 	@see `asys.native.filesystem.FileSystem.linkInfo` to get information of the
	// 	link itself.
	// **/
	// static public function info(path:FilePath, callback:Callback<FileInfo>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.File.info(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		info -> callback.success(info),
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Check user's access for a path.
	// 	For example to check if a file is readable and writable:
	// 	```haxe
	// 	import asys.native.filesystem.FileAccessMode;
	// 	FileSystem.check(path, Readable | Writable, (error, result) -> trace(result));
	// 	```
	// **/
	// static public function check(path:FilePath, mode:FileAccessMode, callback:Callback<Bool>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.check(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		cast mode,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Check if the path is a directory.
	// 	If `path` is a symbolic links then it will be resolved and checked.
	// 	Returns `false` if `path` does not exist.
	// **/
	// static public function isDirectory(path:FilePath, callback:Callback<Bool>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.isDirectory(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Check if the path is a regular file.
	// 	If `path` is a symbolic links then it will be resolved and checked.
	// 	Returns `false` if `path` does not exist.
	// **/
	// static public function isFile(path:FilePath, callback:Callback<Bool>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.isFile(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Set path permissions.
	// 	If `path` is a symbolic link it is dereferenced.
	// **/
	// static public function setPermissions(path:FilePath, permissions:FilePermissions, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	openFile(path, Read, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.setPermissions(permissions, (info, error) -> {
	// 					file.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								// Should we error if not all of the data was written?
	// 								callback.success(info);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Set path owner and group.
	// 	If `path` is a symbolic link it is dereferenced.
	// **/
	// static public function setOwner(path:FilePath, user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	openFile(path, Read, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.setOwner(user, group, (info, error) -> {
	// 					file.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								// Should we error if not all of the data was written?
	// 								callback.success(info);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Set symbolic link owner and group.
	// **/
	// static public function setLinkOwner(path:FilePath, user:SystemUser, group:SystemGroup, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.setLinkOwner(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		user,
	// 		group,
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Create a link to `target` at `path`.
	// 	If `type` is `SymLink` the `target` is expected to be an absolute path or
	// 	a path relative to `path`, however the existance of `target` is not checked
	// 	and the link is created even if `target` does not exist.
	// 	If `type` is `HardLink` the `target` is expected to be an existing path either
	// 	absolute or relative to the current working directory.
	// **/
	// static public function link(target:FilePath, path:String, type:FileLink = SymLink, callback:Callback<NoData>):Void {
	// 	if (target == null) {
	// 		callback.fail(new ArgumentException("target", "target was null"));

	// 		return;
	// 	}

	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.link(
	// 		@:privateAccess Thread.current().context(),
	// 		target,
	// 		path,
	// 		cast type,
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Check if the path is a symbolic link.
	// 	Returns `false` if `path` does not exist.
	// **/
	// static public function isLink(path:FilePath, callback:Callback<Bool>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.isLink(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Get the value of a symbolic link.
	// **/
	// static public function readLink(path:FilePath, callback:Callback<String>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.readLink(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Get information at the given path without following symbolic links.
	// **/
	// static public function linkInfo(path:FilePath, callback:Callback<FileInfo>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.linkInfo(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }

	// /**
	// 	Copy a file from `source` path to `destination` path.
	// **/
	// static public function copyFile(source:FilePath, destination:FilePath, overwrite:Bool = true, callback:Callback<NoData>):Void {
	// 	if (source == null) {
	// 		callback.fail(new ArgumentException("source", "source was null"));

	// 		return;
	// 	}

	// 	if (destination == null) {
	// 		callback.fail(new ArgumentException("destination", "destination was null"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.copyFile(
	// 		@:privateAccess Thread.current().context(),
	// 		source,
	// 		destination,
	// 		overwrite,
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new FsException(msg, source)));
	// }

	// /**
	// 	Shrink or expand a file specified by `path` to `newSize` bytes.
	// 	If the file does not exist, it is created.
	// 	If the file is larger than `newSize`, the extra data is lost.
	// 	If the file is shorter, zero bytes are used to fill the added length.
	// **/
	// static public function resize(path:FilePath, newSize:Int, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	if (newSize < 0) {
	// 		callback.fail(new ArgumentException("newSize", "newSize was less than zero"));

	// 		return;
	// 	}

	// 	openFile(path, Overwrite, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.resize(newSize, (_, error) -> {
	// 					file.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								// Should we error if not all of the data was written?
	// 								callback.success(null);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Change access and modification times of an existing file.
	// 	TODO: Decide on type for `accessTime` and `modificationTime` - see TODO in `asys.native.filesystem.FileInfo.FileStat`
	// **/
	// static public function setTimes(path:FilePath, accessTime:Int, modificationTime:Int, callback:Callback<NoData>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path", "path was null"));

	// 		return;
	// 	}

	// 	if (accessTime < 0) {
	// 		callback.fail(new ArgumentException("accessTime", "time was less than 0"));

	// 		return;
	// 	}

	// 	if (modificationTime < 0) {
	// 		callback.fail(new ArgumentException("modificationTime", "time was less than 0"));

	// 		return;
	// 	}

	// 	openFile(path, Write, (file, error) -> {
	// 		switch error {
	// 			case null:
	// 				file.setTimes(accessTime, modificationTime, (_, error) -> {
	// 					file.close((_, _) -> {
	// 						// TODO : What should we do if closing fails?
	// 						// create a composite exception?

	// 						switch error {
	// 							case null:
	// 								// Should we error if not all of the data was written?
	// 								callback.success(null);
	// 							case exn:
	// 								callback.fail(exn);
	// 						}
	// 					});
	// 				});
	// 			case exn:
	// 				callback.fail(exn);
	// 		}
	// 	});
	// }

	// /**
	// 	Get a canonical absolute path. The path must exist.
	// 	Resolves intermediate `.`, `..`, excessive slashes.
	// 	Resolves symbolic links on all targets except C#.
	// **/
	// static public function realPath(path:FilePath, callback:Callback<String>):Void {
	// 	if (path == null) {
	// 		callback.fail(new ArgumentException("path"));

	// 		return;
	// 	}

	// 	cpp.asys.Directory.realPath(
	// 		@:privateAccess Thread.current().context(),
	// 		path,
	// 		callback.success,
	// 		msg -> callback.fail(new FsException(msg, path)));
	// }
}