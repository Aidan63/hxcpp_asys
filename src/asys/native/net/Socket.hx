package asys.native.net;

import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.exceptions.ArgumentException;
import sys.thread.Thread;
import asys.native.net.Ip;
import asys.native.net.SocketOptions;
import haxe.NoData;
import haxe.Callback;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.exceptions.NotImplementedException;
import haxe.coro.schedulers.Scheduler;

using hxcoro.util.Convenience;

// class IpcSocketSpecialisation extends Socket {
// 	final native : cpp.asys.IpcSocket;

// 	public function new(native : cpp.asys.IpcSocket) {
// 		super(native.reader, native.writer);

// 		this.native = native;
// 	}

// 	override function get_localAddress():SocketAddress {
// 		return SocketAddress.Ipc(native.socketName);
// 	}

// 	override function get_remoteAddress():Null<SocketAddress> {
// 		return SocketAddress.Ipc(native.peerName);
// 	}

// 	override function close(callback:Callback<NoData, Exception>) {
// 		native.close(
// 			() -> callback.success(null),
// 			msg -> callback.fail(new IoException(msg)));
// 	}
// }

class TcpSocketSpecialisation extends Socket {
	final native : cpp.asys.TcpSocket;

	public function new(native : cpp.asys.TcpSocket) {
		super(native.reader, native.writer);

		this.native = native;
	}

	override function get_localAddress():SocketAddress {
		return SocketAddress.Net(native.localAddress.host, native.localAddress.port);
	}

	override function get_remoteAddress():Null<SocketAddress> {
		return SocketAddress.Net(native.remoteAddress.host, native.remoteAddress.port);
	}

	override function getOption<T>(option:SocketOptionKind<T>, callback:Callback<T, Exception>) {
		// if (callback == null) {
		// 	throw new ArgumentException("callback");
		// }

		// switch option {
		// 	case KeepAlive:
		// 		native.getKeepAlive(
		// 			callback.success,
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case SendBuffer:
		// 		native.getSendBufferSize(
		// 			callback.success,
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case ReceiveBuffer:
		// 		native.getRecvBufferSize(
		// 			callback.success,
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case _:
		// 		callback.fail(new NotImplementedException());
		// }
	}

	override function setOption<T>(option:SocketOptionKind<T>, value:T, callback:Callback<NoData, Exception>) {
		// if (callback == null) {
		// 	throw new ArgumentException("callback");
		// }

		// switch option {
		// 	case KeepAlive:
		// 		native.setKeepAlive(
		// 			value,
		// 			() -> callback.success(null),
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case SendBuffer:
		// 		native.setSendBufferSize(
		// 			value,
		// 			() -> callback.success(null),
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case ReceiveBuffer:
		// 		native.setRecvBufferSize(
		// 			value,
		// 			() -> callback.success(null),
		// 			msg -> callback.fail(new IoException(msg)));
		// 	case _:
		// 		callback.fail(new NotImplementedException());
		// }
	}

	@:coroutine override function close() {
		hxcoro.Coro.suspend(cont -> {
			native.close(
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new IoException(msg)));
		});
	}
}

class Socket implements IDuplex {
	final reader : Readable;

	final writer : Writable;

	function new(reader, writer) {
		this.reader = reader;
		this.writer = writer;
	}

	/**
		Local address of this socket.
	**/
	public var localAddress(get,never):SocketAddress;
	function get_localAddress():SocketAddress {
		throw new NotImplementedException();
	}

	/**
		Remote address of this socket if it is bound.
	**/
	public var remoteAddress(get,never):Null<SocketAddress>;
	function get_remoteAddress():Null<SocketAddress> {
		throw new NotImplementedException();
	}

	/**
		Establish a connection to `address`.
	**/
	@:coroutine static public function connect(address:SocketAddress, ?options:SocketOptions):Socket {
		if (address == null) {
			throw new ArgumentException("address", "address was null");
		}

		switch address {
			case Net(host, port):
				switch IpTools.parseIp(host) {
					case Ipv4(_):
						return hxcoro.Coro.suspend(cont -> {
							cpp.asys.TcpSocket.connect_ipv4(
								cpp.asys.Context.get(),
								host,
								port,
								options,
								socket -> cont.succeedAsync(new TcpSocketSpecialisation(socket)),
								msg -> cont.failAsync(new IoException(msg)));
						});
					case Ipv6(_):
						return hxcoro.Coro.suspend(cont -> {
							cpp.asys.TcpSocket.connect_ipv6(
								cpp.asys.Context.get(),
								host,
								port,
								options,
								socket -> cont.succeedAsync(new TcpSocketSpecialisation(socket)),
								msg -> cont.failAsync(new IoException(msg)));
						});
				}
			case Ipc(path):
				throw new haxe.exceptions.NotImplementedException();
				// return hxcoro.Coro.suspend(cont -> {
				// 	cpp.asys.IpcSocket.connect(
				// 		cpp.asys.Context.get(),
				// 		path,
				// 		socket -> cont.succeedAsync(new IpcSocketSpecialisation(socket)),
				// 		msg -> cont.failAsync(new IoException(msg)));
				// });
		}
	}

	/**
		Read up to `length` bytes and write them into `buffer` starting from `offset`
		position in `buffer`, then invoke `callback` with the amount of bytes read.
	**/
	@:coroutine public function read(buffer:Bytes, offset:Int, length:Int):Int {
		if (buffer == null) {
			throw new ArgumentException("buffer", "buffer was null");
		}

		if (offset < 0) {
			throw new ArgumentException("offset", "offset was less than zero");
		}

		if (offset > buffer.length) {
			throw new ArgumentException("offset", "offset was greater than the buffer length");
		}

		if (length < 0) {
			throw new ArgumentException("length", "length was less than zero");
		}

		if (offset + length > buffer.length) {
			throw new Exception("invalid buffer range");
		}

		throw new NotImplementedException();

		// reader.read(
		// 	buffer.getData(),
		// 	offset,
		// 	length,
		// 	len -> callback.success(len),
		// 	msg -> callback.fail(new IoException(msg)));
	}

	/**
		Write up to `length` bytes from `buffer` (starting from buffer `offset`),
		then invoke `callback` with the amount of bytes written.
	**/
	@:coroutine public function write(buffer:Bytes, offset:Int, length:Int):Int {
		if (buffer == null) {
			throw new ArgumentException("buffer", "buffer was null");
		}

		if (offset < 0) {
			throw new ArgumentException("offset", "offset was less than zero");
		}

		if (offset > buffer.length) {
			throw new ArgumentException("offset", "offset was greater than the buffer length");
		}

		if (length < 0) {
			throw new ArgumentException("length", "length was less than zero");
		}

		if (offset + length > buffer.length) {
			throw new Exception("invalid buffer range");
		}

		return
			hxcoro.Coro.suspend(cont -> {
				writer.write(
					buffer.getData(),
					offset,
					length,
					cont.succeedAsync,
					msg -> cont.context.get(Scheduler).schedule(0,() -> cont.resume(0, new IoException(msg))));
			});
	}

	/**
		Force all buffered data to be committed.
	**/
	@:coroutine public function flush() {
		hxcoro.Coro.suspend(cont -> {
			writer.flush(
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new IoException(msg)));
		});
	}

	/**
		Get the value of a specified socket option.
	**/
	public function getOption<T>(option:SocketOptionKind<T>, callback:Callback<T>) {
		callback.fail(new NotImplementedException());
	}

	/**
		Set socket option.
	**/
	public function setOption<T>(option:SocketOptionKind<T>, value:T, callback:Callback<NoData>) {
		callback.fail(new NotImplementedException());
	}

	/**
		Close the connection.
	**/
	@:coroutine public function close() {
		//
	}
}