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
						final data = Bytes.alloc(64);

						socket.read(data, 0, 13, (error, c) -> {
							if (error != null) {
								trace(error.message);
							} else {
								trace(data.sub(0, c).toString());
							}
							
							socket.read(data, 0, 13, (error, c) -> {
								if (error != null) {
									trace(error.message);
								} else {
									trace(data.sub(0, c).toString());
								}

								socket.close((error, _) -> {
									if (error != null) {
										trace(error.message);
									}
								});
							});
						});
					}
				});
			}
		});
	}
}
