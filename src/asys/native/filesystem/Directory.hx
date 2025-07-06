package asys.native.filesystem;

import haxe.Callback;
import haxe.NoData;

using hxcoro.util.Convenience;

/**
	Represents a directory.
**/
class Directory {
    final dir:cpp.asys.Directory;
    final batch:Int;

	/** The path of this directory as it was at the moment of opening the directory */
	public final path:FilePath;

	function new(dir:cpp.asys.Directory, batch:Int) {
        this.dir   = dir;
        this.batch = batch;

		path = dir.path;
	}

	/**
		Read next batch of directory entries.
		Passes an empty array to `callback` if no more entries left to read.
		Ignores `.` and `..` entries.
		The size of the array is always equal to or less than `maxBatchSize` value used
		for opening this directory.
		@see asys.native.filesystem.FileSystem.openDirectory
	**/
	@:coroutine public function next():Array<String> {
		return hxcoro.Coro.suspend(cont -> {
			dir.next(
				batch,
				cont.succeedAsync,
				err -> cont.failAsync(new FsException(err, path)));
		});
	}

	/**
		Close the directory.
	**/
	@:coroutine public function close() {
		hxcoro.Coro.suspend(cont -> {
			dir.close(
				() -> cont.succeedAsync(null),
				err -> cont.failAsync(new FsException(err, path)));
		});
	}
}