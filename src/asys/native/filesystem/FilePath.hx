package asys.native.filesystem;

import haxe.exceptions.NotImplementedException;
import haxe.exceptions.ArgumentException;

using StringTools;
using cpp.asys.FilePathExtras;

private typedef NativeFilePath = String;

abstract FilePath(NativeFilePath) to String {
	public static var SEPARATOR(get,never):String;
	static function get_SEPARATOR():String {
		return if (Sys.systemName() == 'Windows') '\\' else '/';
	}

	overload extern static public inline function createPath(path:String, ...appendices:String):FilePath {
		return createPathImpl(path, ...appendices);
	}

	static function createPathImpl(path:String, ...appendices:String):FilePath {
		var path = ofString(path);

		for (p in appendices) {
			path = path.add(p);
		}

		return path;
	}

	overload extern static public inline function createPath(parts:Array<String>):FilePath {
		return ofArray(parts);
	}

	@:noUsing @:from public static inline function ofString(path:String):FilePath {
		return new FilePath(path);
	}

	@:from static function ofArray(parts:Array<String>):FilePath {
		if (parts.length == 0) {
			throw new ArgumentException('parts');
		}

		var path = ofString(parts[0]);

		for(i in 1...parts.length) {
			path = path.add(parts[i]);
		}

		return path;
	}

	inline function new(s:String) {
		this = s;
	}

	@:to public inline function toString():String {
		return this == null ? null : this.toString();
	}

	/**
		Check if this is an absolute path.
	**/
	public function isAbsolute():Bool {
		if (this == null) {
			return false;
		}

		return switch this.length {
			case 0: false;
			case _ if (this.fastCodeAt(0).isSeparator()): true;
			case 1: false;
			case length: this.fastCodeAt(1) == ':'.code && length >= 3 && this.fastCodeAt(2).isSeparator();
		}
	}

	/**
		Get the parent element of this path.
		E.g. for `dir/to/path` this method returns `dir/to`.
		Ignores trailing slashes.
		E.g. for `dir/to/path/` this method returns `dir/to`.
		Returns `null` if this path does not have a parent element.
		This method does not resolve special names like `.` and `..`.
		That is the parent of `some/..` is `some`.
	**/
	public function parent():FilePath {
		if (abstract.empty()) {
			return "";
		}

		if (!this.hasRelativePath()) {
			return abstract;
		}

		final s = this.trimSlashes();

		var i = s.length;
		while (!s.fastCodeAt(i).isSeparator()) {
			--i;
			if (i < 0) {
				return "";
			}
		}

		return new FilePath(s.substr(0, i + 1).trimSlashes());
	}

	/**
		Get the last element (farthest from the root) of this path.
		E.g. for `dir/to/path` this method returns `path`.
		Ignores trailing slashes.
		E.g. for `dir/to/path/` this method returns `path`.
	**/
	public function name():FilePath {
		return this.trimSlashes().getFilename();
	}

	public function absolute():FilePath {
		throw new NotImplementedException();
	}

	/**
		Returns this path with all the redundant elements removed.

		Resolves `.` and `..` and removes excessive slashes and trailing slashes.

		Does not resolve symbolic links.

		This method may return an empty path if all elements of this path are redundant.

		It does not matter if the path does not exist.
	**/
	public function normalize():FilePath {

		// Follow the normalisation algorithm defined here
		// https://en.cppreference.com/w/cpp/filesystem/path

		// If the path is empty, stop (normal form of an empty path is an empty path). 

		if (this == null) {
			return new FilePath("");
		}

		var working = this.trim();
		if (working.length == 0) {
			return new FilePath("");
		}

		// Replace each directory-separator (which may consist of multiple slashes) with a single SEPARATOR.

		var i = 0;
		while (i < working.length) {
			if (working.fastCodeAt(i).isSeparator()) {
				var j = i + 1;
				while (j < working.length) {
					if (working.fastCodeAt(j).isSeparator()) {
						j++;
					} else {
						break;
					}
				}

				working = working.substring(0, i) + SEPARATOR + working.substr(j);

				i = j;
			} else {
				i++;
			}
		}

		// Remove each dot and immediately following separator.

		var i = 0;
		while (i < working.length) {
			if (".".code == working.fastCodeAt(i) && i + 1 < working.length && working.fastCodeAt(i + 1).isSeparator()) {
				// Special case for ./ being the very first thing in the path.
				if (i == 0) {
					if (i + 2 < working.length) {
						working = working.substr(2);
					} else {
						return FilePath.ofString(".");
					}
				} else {
					if (working.fastCodeAt(i - 1).isSeparator()) {
						if (i + 2 < working.length) {
							final begin = working.substring(0, i);
							final end   = working.substr(i + 2);
	
							working = begin + end;
							i       = begin.length;
						} else {
							working = working.substring(0, i);
						}
					} else {
						i++;
					}
				}
			} else {
				i++;
			}
		}
		
		// Remove each non-dot-dot filename immediately followed by a SEPARATOR and a dot-dot

		final rootName = working.getRootName();
		final rootDir  = working.getRootDirectory();

		final parts  = working.getRelativePath().split(SEPARATOR);
		final result = [];

		var i    = parts.length - 1;
		var skip = 0;

		while (i >= 0) {
			switch parts[i] {
				case '.' | '':
					//
				case '..':
					skip++;
				case _ if (skip > 0):
					skip--;
				case part:
					result.unshift(part);
			}

			i--;
		}

		for (_ in 0...skip) {
			result.unshift('..');
		}

		// If there is root-directory, remove all dot-dots and any directory-separators immediately following them. 

		if (rootDir != "") {
			while (result.length > 0 && result[0] == "..") {
				result.shift();
			}
		}

		// If the path is empty, add a dot (normal form of ./ is .)

		working = rootName + rootDir + result.join(SEPARATOR);

		return if (working.length > 0) {
			FilePath.ofString(working);
		} else {
			FilePath.ofString(".");
		}
	}

	/**
		Creates a new path by appending `path` to this one.
		This path is treated as a directory and a directory separator is inserted between this and `path` if needed.

		If `path` is an absolute path, then this method simply returns `path`.
		If either this or `path` is empty then this method simply return the other one.

		```haxe
		FilePath.ofString('dir').add('file'); // result: dir/file
		FilePath.ofString('dir/').add('file'); // result: dir/file
		FilePath.ofString('dir').add('/file'); // result: /file
		FilePath.ofString('').add('file'); // result: file
		FilePath.ofString('dir').add(''); // result: dir
		```
	**/
	public function add(path:FilePath):FilePath {
		// Append according to the algorithm defined here.
		// https://en.cppreference.com/w/cpp/filesystem/path/append

		if (this == null || this == "") {
			return path;
		}

		if (path == null || path.empty()) {
			return abstract;
		}

		if (path.isAbsolute() || (path.hasRootName() && path.getRootName() != this.getRootName())) {
			if (path.hasRootName()) {
				return path;
			} else {
				return this.getRootName() + path.getRootDirectory() + path.getRelativePath();
			}
		}

		var out = this;
		if (path.hasRootDirectory()) {
			out = this.getRootName();
		}
		else if (this.hasFilename() || (!this.hasRootDirectory() && isAbsolute())) {
			out = this + SEPARATOR;
		}

		return new FilePath(out + path.getRootDirectory() + path.getRelativePath());
	}
}