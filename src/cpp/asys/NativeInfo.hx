package cpp.asys;

typedef NativeInfo = {
	/** Time of last access (Unix timestamp) */
	final atime:Int;
	/** Time of last modification (Unix timestamp) */
	final mtime:Int;
	/** Time of last inode change (Unix timestamp) */
	final ctime:Int;
	/** Device number */
	final dev:Int;
	/** Owning user */
	final uid:Int;
	/** Owning group */
	final gid:Int;
	/** Inode number */
	final ino:Int;
	/** Inode protection mode */
	final mode:Int;
	/** Number of links */
	final nlink:Int;
	/** Device type, if inode device */
	final rdev:Int;
	/** Size in bytes */
	final size:Int;
	/** Block size of filesystem for IO operations */
	final blksize:Int;
	/** Number of 512-bytes blocks allocated */
	final blocks:Int;
};