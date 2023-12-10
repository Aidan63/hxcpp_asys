package cpp.asys;

import asys.native.filesystem.FilePath;
using StringTools;

class FilePathExtras
{
    public static function hasRootName(p:String):Bool {
		if (p == null || p.length == 0) {
			return false;
		}

		var i = 0;
		while (i < p.length) {
			if (p.isSpace(i)) {
				continue;
			}

			return isDriveLetter(p.fastCodeAt(i)) && i + 1 < p.length && ":".code == p.fastCodeAt(i + 1);
		}

		return false;
	}

	public static function hasRootDirectory(p:String):Bool {
		if (p == null || p.length == 0) {
			return false;
		}

		var i = 0;
		while (i < p.length) {
			if (p.isSpace(i)) {
				continue;
			}

			if (isSeparator(p.fastCodeAt(i))) {
				return true;
			}

			return
				isDriveLetter(p.fastCodeAt(i)) &&
				i + 2 < p.length &&
				":".code == p.fastCodeAt(i + 1) &&
				isSeparator(p.fastCodeAt(i + 2));
		}

		return false;
	}

	public static function getRootName(p:String):String {
		if (p == null || p.length == 0) {
			return "";
		}

		var i = 0;
		while (i < p.length) {
			if (p.isSpace(i)) {
				continue;
			}

			if (isDriveLetter(p.fastCodeAt(i)) && i + 1 < p.length && ":".code == p.fastCodeAt(i + 1)) {
				return p.substr(i, 2);
			}
		}

		return "";
	}

	public static function getRootDirectory(p:String):String {
		if (p == null || p.length == 0) {
			return "";
		}

		var i = 0;
		while (i < p.length) {
			if (p.isSpace(i)) {
				continue;
			}

			if (isSeparator(p.fastCodeAt(i))) {
				var j = i;
				while (j < p.length) {
					if (isSeparator(p.fastCodeAt(j))) {
						break;
					}

					j++;
				}

				p.substring(i, j);
			}

			if (isDriveLetter(p.fastCodeAt(i)) &&
				i + 2 < p.length &&
				":".code == p.fastCodeAt(i + 1) &&
				isSeparator(p.fastCodeAt(i + 2))) {
				i += 2;

				var j = i;
				while (j < p.length) {
					if (!isSeparator(p.fastCodeAt(j))) {
						break;
					}

					j++;
				}

				p.substring(i, j);
			}

			return "";
		}

		return "";
	}

    public static function empty(path:String) {
		return path == null || path.trim() == "";
	}

	public static function isSeparator(c:Int):Bool {
		return c == "/".code || String.fromCharCode(c) == FilePath.SEPARATOR;
	}

	public static function trimSlashes(s:String):String {
		var i = s.length - 1;
		if (i <= 0) {
			return s;
		}

		var sep = isSeparator(s.fastCodeAt(i));
		if (sep) {
			do {
				--i;
				sep = isSeparator(s.fastCodeAt(i));
			} while(i > 0 && sep);

			return s.substr(0, i + 1);
		} else {
			return s;
		}
	}

	public static function isDriveLetter(c:Int):Bool {
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code);
	}

	public static function extractRootName(p:String):String {
		if (p == null || p.length < 2) {
			return "";
		}

		if (isDriveLetter(p.fastCodeAt(0)) && ":".code == p.fastCodeAt(1)) {
			return p.substr(0, 2);
		}

		return "";
	}

	public static function rootIndex(p:String):Int {
		var i = 0;
		while (i < p.length) {
			if (!p.isSpace(i)) {
				return if (isSeparator(p.fastCodeAt(i))) {
					i;
				} else {
					-1;
				}
			}

			i++;
		}

		return -1;
	}
}