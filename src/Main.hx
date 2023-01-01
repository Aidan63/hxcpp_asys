import asys.native.filesystem.Directory;
import haxe.io.Bytes;
import asys.native.filesystem.FileSystem;

class Main {
	static function read(dir:Directory) {
		dir.next((error, entries) -> {
			switch error {
				case null:
					switch entries {
						case []:
							dir.close((error, _) -> {
								switch error {
									case null:
										trace('closed');
									case exn:
										throw exn;
								}
							});
						case e:
							trace(e);

							read(dir);
					}
				case exn:
					throw exn;
			}
		});
	}

	static function main() {
		// FileSystem.listDirectory('C:\\Users\\AidanLee\\Desktop\\hxcpp_asys', (error, entries) -> {
		// 	if (error != null) {
		// 		trace(error.message);
		// 	} else {
		// 		trace(entries);
		// 	}
		// });
		FileSystem.createDirectory('some\\dir', null, true, (error, _) -> {
			if (error != null) {
				trace(error.message);
			} else {
				trace('created');
			}
		});
		FileSystem.createDirectory('other', null, false, (error, _) -> {
			if (error != null) {
				trace(error.message);
			} else {
				trace('created');

				FileSystem.createDirectory('other\\some\\dir', null, false, (error, _) -> {
					if (error != null) {
						trace(error.message);
					} else {
						trace('created');
					}
				});
			}
		});
	}
}
