package asys.native.filesystem;

import haxe.io.Path;
import haxe.NoData;
import haxe.io.Bytes;
import sys.thread.Thread;

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
    static public function openFile<T>(path:String, flag:FileOpenFlag<T>, callback:Callback<T>) {
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
	static public function readBytes(path:String, callback:Callback<Bytes>):Void {
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
	static public function readString(path:String, callback:Callback<String>):Void {
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
	static public function writeBytes(path:String, data:Bytes, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
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
	static public function writeString(path:String, text:String, flag:FileOpenFlag<Dynamic> = Write, callback:Callback<NoData>):Void {
		writeBytes(path, Bytes.ofString(text), flag, callback);
	}

	/**
		Open directory for listing.
		`maxBatchSize` sets maximum amount of entries returned by a call to `directory.next`.
		In general bigger `maxBatchSize` allows to iterate faster, but requires more
		memory per call to `directory.next`.
		@see asys.native.filesystem.Directory.next
	**/
	static public function openDirectory(path:String, maxBatchSize:Int = 64, callback:Callback<Directory>):Void {
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
	static public function listDirectory(path:String, callback:Callback<Array<String>>):Void {
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
	static public function createDirectory(path:String, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<NoData>):Void {
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
	static public function uniqueDirectory(parentDirectory:String, ?prefix:String, ?permissions:FilePermissions, recursive:Bool = false, callback:Callback<String>):Void {
		final rndIntValue = Std.random(2147483647);
		final finalPrefix = if (prefix == null) Std.string(rndIntValue) else '$prefix$rndIntValue';
		final finalPath   = Path.join([ parentDirectory, finalPrefix ]);

		createDirectory(finalPath, permissions, recursive, (error, _) -> {
			if (error != null) {
				callback.fail(error);
			}
			else {
				callback.success(finalPath);
			}
		});
	}
}