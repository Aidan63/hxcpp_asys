package asys.native.filesystem;

import haxe.NoData;

/**
	Represents a directory.
**/
class Directory {
    final dir:cpp.asys.Directory;
    final batch:Int;

	/** The path of this directory as it was at the moment of opening the directory */
	public final path:String;

	function new(dir:cpp.asys.Directory, batch:Int) {
        this.dir = dir;
        this.batch = batch;

		path = 'stub';
	}

	/**
		Read next batch of directory entries.
		Passes an empty array to `callback` if no more entries left to read.
		Ignores `.` and `..` entries.
		The size of the array is always equal to or less than `maxBatchSize` value used
		for opening this directory.
		@see asys.native.filesystem.FileSystem.openDirectory
	**/
	public function next(callback:Callback<Array<String>>):Void {
		dir.next(
            batch,
            callback.success,
            err -> callback.fail(new FsException(err, path)));
	}

	/**
		Close the directory.
	**/
	public function close(callback:Callback<NoData>):Void {
		dir.close(
            () -> callback.success(null),
            err -> callback.fail(new FsException(err, path)));
	}
}