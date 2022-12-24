package asys.native.filesystem;

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
            file -> callback.success(cast @:privateAccess new File(path, file)),
            msg -> callback.fail(new FsException(msg, path)));
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
}