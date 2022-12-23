package asys.native.filesystem;

import cpp.asys.File.NativeInfo;
import asys.native.system.SystemUser;
import asys.native.system.SystemGroup;

abstract FileInfo(NativeInfo) from NativeInfo to NativeInfo {
    /** Time of last access (Unix timestamp) */
	public var accessTime(get,never):Int;
	inline function get_accessTime():Int
		return this.atime;

	/** Time of last modification (Unix timestamp) */
	public var modificationTime(get,never):Int;
	inline function get_modificationTime():Int
		return this.mtime;

	/** Time of last inode change (Unix timestamp) */
	public var creationTime(get,never):Int;
	inline function get_creationTime():Int
		return this.ctime;

	/** Device number */
	public var deviceNumber(get,never):Int;
	inline function get_deviceNumber():Int
		return this.dev;

	/** Owning group **/
	public var group(get,never):SystemGroup;
	inline function get_group():SystemGroup
		return this.gid;

	/** Owning user **/
	public var user(get,never):SystemUser;
	inline function get_user():SystemUser
		return this.uid;

	/** Inode number */
	public var inodeNumber(get,never):Int;
	inline function get_inodeNumber():Int
		return this.ino;

	/** File type and permissions */
	public var mode(get,never):FileMode;
	inline function get_mode():FileMode
		return this.mode;

	/** Number of links */
	public var links(get,never):Int;
	inline function get_links():Int
		return this.nlink;

	/** Device type, if inode device */
	public var deviceType(get,never):Int;
	inline function get_deviceType():Int
		return this.rdev;

	/** Size in bytes */
	public var size(get,never):Int;
	inline function get_size():Int
		return this.size;

	/** Block size of filesystem for IO operations */
	public var blockSize(get,never):Int;
	inline function get_blockSize():Int
		return this.blksize;

	/** Number of 512-bytes blocks allocated */
	public var blocks(get,never):Int;
	inline function get_blocks():Int
		return this.blocks;
}