import asys.native.net.Server;
import asys.native.filesystem.File;
import asys.native.net.Ip;
import asys.native.net.Dns;
import asys.native.filesystem.Directory;
import haxe.io.Bytes;
import asys.native.filesystem.FileSystem;

class Main {
	static function main() {
		Server.open(SocketAddress.Net('127.0.0.1', 7777), null, (error, server) -> {
			if (error != null) {
				trace(error.message);
			} else {
				server.accept((error, socket) -> {
					if (error != null) {
						trace(error.message);
					} else {
						final data = Bytes.ofString('Hello, World!');
						final len  = data.length;

						socket.write(data, 0, len, (error, _) -> {
							if (error != null) {
								trace(error.message);
							}
							
							socket.close((error, _) -> {
								if (error != null) {
									trace(error.message);
								}
							});
						});
					}
				});

				server.accept((error, socket) -> {
					if (error != null) {
						trace(error.message);
					} else {
						final data = Bytes.ofString('Goodbye, World!');
						final len  = data.length;

						socket.write(data, 0, len, (error, _) -> {
							if (error != null) {
								trace(error.message);
							}
							
							socket.close((error, _) -> {
								if (error != null) {
									trace(error.message);
								}
							});
						});
					}
				});
			}
		});
	}
}
