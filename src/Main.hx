import haxe.io.Bytes;
import asys.native.filesystem.FileSystem;

class Main {
	static function main() {
		FileSystem.openFile('test2.txt', Read, (error, result) -> {
			if (error != null) {
				trace(error.message);
			} else {
				// result.resize(5, (error, info) -> {
				// 	if (error != null) {
				// 		trace(error.message);
				// 	} else {
				// 		trace(info);
				// 	}

				// 	result.flush((error, result) -> {
				// 		if (error != null) {
				// 			trace(error.message);
				// 		}
				// 	});
				// });

				// final buffer = Bytes.alloc(20);

				// result.read(0, buffer, 0, buffer.length, (error, count) -> {
				// 	if (error != null) {
				// 		trace(error.message);
				// 	}
				// 	else {
				// 		trace('"${ buffer.toString() }"');
				// 		trace('"${ buffer.sub(0, count).toString() }"');
				// 	}

				// 	result.close((error, result) -> {
				// 		if (error != null) {
				// 			trace(error.message);
				// 		}
				// 	});
				// });
			}
		});
	}
}
