package cpp.asys;

import asys.native.filesystem.FilePath;
using StringTools;

class FilePathExtras
{
    public static function hasRootName(path:String):Bool {
		if (path == null || path.length == 0) {
			return false;
		}

		var i = 0;
		while (i < path.length) {
			if (path.isSpace(i)) {
                i++;

				continue;
			}

			return isDriveLetter(path.fastCodeAt(i)) && i + 1 < path.length && ":".code == path.fastCodeAt(i + 1);
		}

		return false;
	}

	public static function hasRootDirectory(path:String):Bool {
		if (path == null || path.length == 0) {
			return false;
		}

		var i = 0;
		while (i < path.length) {
			if (path.isSpace(i)) {
                i++;

				continue;
			}

			if (isSeparator(path.fastCodeAt(i))) {
				return true;
			}

			return
				isDriveLetter(path.fastCodeAt(i)) &&
				i + 2 < path.length &&
				":".code == path.fastCodeAt(i + 1) &&
				isSeparator(path.fastCodeAt(i + 2));
		}

		return false;
	}

	public static function getRootName(path:String):String {
		if (path == null || path.length == 0) {
			return "";
		}

		var i = 0;
		while (i < path.length) {
			if (path.isSpace(i)) {
                i++;

				continue;
			}

			if (isDriveLetter(path.fastCodeAt(i)) && i + 1 < path.length && ":".code == path.fastCodeAt(i + 1)) {
				return path.substr(i, 2);
			}

            i++;
		}

		return "";
	}

	public static function getRootDirectory(path:String):String {
		if (path == null || path.length == 0) {
			return "";
		}

		var i = 0;
		while (i < path.length) {
			if (path.isSpace(i)) {
                i++;

				continue;
			}

			if (isSeparator(path.fastCodeAt(i))) {
				var j = i;
				while (j < path.length) {
					if (!isSeparator(path.fastCodeAt(j))) {
						break;
					}

					j++;
				}

				return path.substring(i, j);
			}

			if (isDriveLetter(path.fastCodeAt(i)) &&
				i + 2 < path.length &&
				":".code == path.fastCodeAt(i + 1) &&
				isSeparator(path.fastCodeAt(i + 2))) {
				i += 2;

				var j = i + 1;
				while (j < path.length) {
					if (!isSeparator(path.fastCodeAt(j))) {
						break;
					}

					j++;
				}

				return path.substring(i, j);
			}

			return "";
		}

		return "";
	}

    public static function getRootPath(path:String):String {
        return getRootName(path) + getRootDirectory(path);
    }

    public static function empty(path:String) {
		if (path == null) {
            return true;
        }

        var i = 0;
        while (i < path.length) {
            if (!path.isSpace(i)) {
                return false;
            }

            i++;
        }

        return true;
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