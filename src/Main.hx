import asys.native.system.Process;
import haxe.NoData;
import asys.native.net.Callback;
import asys.native.net.Socket;
import asys.native.net.SocketOptions.SocketOptionKind;
import haxe.io.BytesData;
import haxe.Timer;
import sys.thread.Thread;
import cpp.Callable;
import haxe.Exception;
import asys.native.net.Server;
import asys.native.filesystem.File;
import asys.native.net.Ip;
import asys.native.net.Dns;
import asys.native.filesystem.Directory;
import haxe.io.Bytes;
import asys.native.filesystem.FileSystem;

// private class QueuedWrite {
// 	public final id : Int;
// 	public final buffer : Bytes;
// 	public final offset : Int;
// 	public final length : Int;
// 	public final callback : Callback<Int>;
// 	public var progress : Int;

// 	public function new(id:Int, buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
// 		this.id       = id;
// 		this.buffer   = buffer;
// 		this.offset   = offset;
// 		this.length   = length;
// 		this.callback = callback;
// 	}
// }

// private class Flush {
// 	public final id : Int;
// 	public final callback : Callback<NoData>;

// 	public function new(id:Int, callback:Callback<NoData>) {
// 		this.id = id;
// 		this.callback = callback;
// 	}
// }

// private class TestSocket {
// 	private static inline var CHUNK_SIZE = 8192;

// 	var native : Dynamic;

// 	var seed : Int;

// 	final writeQueue : Array<QueuedWrite>;

// 	final flushQueue : Array<Flush>;

// 	public function new() {
// 		writeQueue = [];
// 		flushQueue = [];
// 	}

// 	public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
// 		final startConsuming = writeQueue.length == 0;

// 		writeQueue.push(new QueuedWrite(seed++, buffer, offset, length, callback));

// 		if (startConsuming) {
// 			consume();
// 		}
// 	}

// 	public function flush(callback:Callback<NoData>) {
// 		if (writeQueue.length == 0) {
// 			callback.success(null);

// 			return;
// 		}

// 		final back = writeQueue[writeQueue.length - 1];
// 		final id   = back.id;

// 		flushQueue.push(new Flush(id, callback));
// 	}

// 	function consume() {
// 		if (writeQueue.length == 0) {
// 			return;
// 		}

// 		final front = writeQueue[0];
// 		final size  = Math.min(CHUNK_SIZE, front.length - front.progress);
// 		final ptr   = cpp.Pointer.arrayElem(front.buffer.getData(), front.offset + front.progress);

// 		native
// 			.write(
// 				ptr,
// 				size,
// 				len -> {
// 					front.progress += len;

// 					if (front.progress >= front.length) {
// 						writeQueue.remove(front);

// 						front.callback.success(front.progress);

// 						doFlush(front.id);
// 					}

// 					consume();
// 				},
// 				msg -> {
// 					writeQueue.remove(front);

// 					front.callback.fail(msg);

// 					doFlush(front.id);

// 					consume();
// 				});
// 	}

// 	function doFlush(id:Int) {
// 		while (flushQueue.length > 0 && flushQueue[0].id <= id) {
// 			flushQueue.shift().callback.success(null);
// 		}
// 	}
// }

class Main {
	static function main() {
		Process.open(
			'ffmpeg',
			{
				args  : [ '--help' ],
				stdio : [
					Ignore,
					PipeWrite,
					Ignore
				]
			},
			(error, proc) -> {
				switch error {
					case null:
						trace(proc.pid);

						final buffer = Bytes.alloc(100000);

						proc.stdout.read(buffer, 0, buffer.length, (error, length) -> {
							switch error {
								case null:
									trace(buffer.sub(0, length).toString());
								case exn:
									trace(exn.message);
							}
						});

						proc.exitCode((error, code) -> {
							switch error {
								case null:
									trace('exited with $code');

									proc.close((error, _) -> {
										switch error {
											case null:
												trace('closed');
											case exn:
												trace(exn.message);
										}
									});
								case exn:
									trace(exn.message);
							}
						});
					case exn:
						trace(exn.message);
				}
			});

		// FileSystem.readBytes('C:\\Users\\AidanLee\\Desktop\\hxcpp_asys\\test3.txt', (error, data) -> {
		// 	if (error != null) {
		// 		trace(error.message);
		// 	} else {
		// 		trace(data.length);

		// 		Socket.connect(SocketAddress.Net('127.0.0.1', 7777), null, (error, socket) -> {
		// 			if (error != null) {
		// 				trace(error.message);
		// 			} else {
		// 				socket.write(data, 0, data.length, (error, len) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace(len);
		// 					}
		// 				});

		// 				final msg = Bytes.ofString('Hello, world!');

		// 				socket.write(msg, 0, msg.length, (error, len) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace(len);
		// 					}
		// 				});

		// 				socket.flush((error, _) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace('flushed');
		// 					}
		// 				});

		// 				final msg2 = Bytes.ofString('goodbye, server!');

		// 				socket.write(msg2, 0, msg2.length, (error, len) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace(len);
		// 					}

		// 					socket.close((error, _) -> {
		// 						if (error != null) {
		// 							trace(error.message);
		// 						} else {
		// 							trace('bye bye');
		// 						}
		// 					});
		// 				});
		// 			}
		// 		});
		// 	}
		// });
		// Server.open(SocketAddress.Net('127.0.0.1', 7777), { backlog : 5 }, (error, server) -> {
		// 	if (error != null) {
		// 		trace(error.message);
		// 	} else {
		// 		server.accept((error, socket) -> {
		// 			if (error != null) {
		// 				trace(error.message);
		// 			} else {
		// 				socket.getOption(SocketOptionKind.ReceiveBuffer, (error, size) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace(size);
		// 					}
		// 				});
		// 				socket.setOption(SocketOptionKind.KeepAlive, true, (error, size) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					}
		// 				});

		// 				final data = Bytes.alloc(64);

		// 				socket.read(data, 0, data.length, (error, c) -> {
		// 					if (error != null) {
		// 						trace(error.message);
		// 					} else {
		// 						trace(data.sub(0, c).toString());
		// 					}
							
		// 					socket.close((error, _) -> {
		// 						if (error != null) {
		// 							trace(error.message);
		// 						}
		// 					});
		// 				});
		// 			}
		// 		});
		// 	}
		// });
	}
}
