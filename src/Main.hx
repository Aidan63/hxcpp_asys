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
		FileSystem.openDirectory('C:\\Users\\AidanLee\\Desktop\\hxcpp_asys\\bin', 8, (error, dir) -> {
			switch error {
				case null:
					read(dir);
				case exn:
					trace(exn.message);
			}
		});

		// FileSystem.openFile('test2.txt', Read, (error, result) -> {
		// 	if (error != null) {
		// 		trace(error.message);
		// 	} else {
		// 		// result.resize(5, (error, info) -> {
		// 		// 	if (error != null) {
		// 		// 		trace(error.message);
		// 		// 	} else {
		// 		// 		trace(info);
		// 		// 	}

		// 		// 	result.flush((error, result) -> {
		// 		// 		if (error != null) {
		// 		// 			trace(error.message);
		// 		// 		}
		// 		// 	});
		// 		// });

		// 		// final buffer = Bytes.alloc(20);

		// 		// result.read(0, buffer, 0, buffer.length, (error, count) -> {
		// 		// 	if (error != null) {
		// 		// 		trace(error.message);
		// 		// 	}
		// 		// 	else {
		// 		// 		trace('"${ buffer.toString() }"');
		// 		// 		trace('"${ buffer.sub(0, count).toString() }"');
		// 		// 	}

		// 		// 	result.close((error, result) -> {
		// 		// 		if (error != null) {
		// 		// 			trace(error.message);
		// 		// 		}
		// 		// 	});
		// 		// });
		// 	}
		// });
	}
}
