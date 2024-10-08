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

class IpcSocketSpecialisation extends Socket {
	final native : cpp.asys.IpcSocket;

	public function new(native : cpp.asys.IpcSocket) {
		super(native.reader, native.writer);

		this.native = native;
	}

	override function get_localAddress():SocketAddress {
		return SocketAddress.Ipc(native.socketName);
	}

	override function get_remoteAddress():Null<SocketAddress> {
		return SocketAddress.Ipc(native.peerName);
	}

	override function close(callback:Callback<NoData, Exception>) {
		native.close(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}
}

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
		if (callback == null) {
			throw new ArgumentException("callback");
		}

		switch option {
			case KeepAlive:
				native.getKeepAlive(
					callback.success,
					msg -> callback.fail(new IoException(msg)));
			case SendBuffer:
				native.getSendBufferSize(
					callback.success,
					msg -> callback.fail(new IoException(msg)));
			case ReceiveBuffer:
				native.getRecvBufferSize(
					callback.success,
					msg -> callback.fail(new IoException(msg)));
			case _:
				callback.fail(new NotImplementedException());
		}
	}

	override function setOption<T>(option:SocketOptionKind<T>, value:T, callback:Callback<NoData, Exception>) {
		if (callback == null) {
			throw new ArgumentException("callback");
		}

		switch option {
			case KeepAlive:
				native.setKeepAlive(
					value,
					() -> callback.success(null),
					msg -> callback.fail(new IoException(msg)));
			case SendBuffer:
				native.setSendBufferSize(
					value,
					() -> callback.success(null),
					msg -> callback.fail(new IoException(msg)));
			case ReceiveBuffer:
				native.setRecvBufferSize(
					value,
					() -> callback.success(null),
					msg -> callback.fail(new IoException(msg)));
			case _:
				callback.fail(new NotImplementedException());
		}
	}

	override function close(callback:Callback<NoData, Exception>) {
		native.close(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
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
	static public function connect(address:SocketAddress, ?options:SocketOptions, callback:Callback<Socket>) {
		if (callback == null) {
			throw new ArgumentException("callback", "callback was null");
		}

		if (address == null) {
			callback.fail(new ArgumentException("address", "address was null"));

			return;
		}

		switch address {
			case Net(host, port):
				try {
					switch IpTools.parseIp(host) {
						case Ipv4(_):
							cpp.asys.TcpSocket.connect_ipv4(
								@:privateAccess Thread.current().context(),
								host,
								port,
								options,
								socket -> callback.success(new TcpSocketSpecialisation(socket)),
								msg -> callback.fail(new IoException(msg)));
						case Ipv6(_):
							cpp.asys.TcpSocket.connect_ipv6(
								@:privateAccess Thread.current().context(),
								host,
								port,
								options,
								socket -> callback.success(new TcpSocketSpecialisation(socket)),
								msg -> callback.fail(new IoException(msg)));
					}
				}
				catch (exn) {
					callback.fail(exn);
				}
			case Ipc(path):
				cpp.asys.IpcSocket.connect(
					@:privateAccess Thread.current().context(),
					path,
					socket -> callback.success(new IpcSocketSpecialisation(socket)),
					msg -> callback.fail(new IoException(msg)));
		}
	}

	/**
		Read up to `length` bytes and write them into `buffer` starting from `offset`
		position in `buffer`, then invoke `callback` with the amount of bytes read.
	**/
	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
		if (callback == null) {
			throw new ArgumentException("callback", "callback was null");
		}

		if (buffer == null) {
			callback.fail(new ArgumentException("buffer", "buffer was null"));

			return;
		}

		if (offset < 0) {
			callback.fail(new ArgumentException("offset", "offset was less than zero"));

			return;
		}

		if (offset > buffer.length) {
			callback.fail(new ArgumentException("offset", "offset was greater than the buffer length"));

			return;
		}

		if (length < 0) {
			callback.fail(new ArgumentException("length", "length was less than zero"));

			return;
		}

		if (offset + length > buffer.length) {
			callback.fail(new Exception("invalid buffer range"));

			return;
		}

		reader.read(
			buffer.getData(),
			offset,
			length,
			len -> callback.success(len),
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Write up to `length` bytes from `buffer` (starting from buffer `offset`),
		then invoke `callback` with the amount of bytes written.
	**/
	public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
		if (callback == null) {
			throw new ArgumentException("callback", "callback was null");
		}

		if (buffer == null) {
			callback.fail(new ArgumentException("buffer", "buffer was null"));

			return;
		}

		if (offset < 0) {
			callback.fail(new ArgumentException("offset", "offset was less than zero"));

			return;
		}

		if (offset > buffer.length) {
			callback.fail(new ArgumentException("offset", "offset was greater than the buffer length"));

			return;
		}

		if (length < 0) {
			callback.fail(new ArgumentException("length", "length was less than zero"));

			return;
		}

		if (offset + length > buffer.length) {
			callback.fail(new Exception("invalid buffer range"));

			return;
		}

		writer.write(
			buffer.getData(),
			offset,
			length,
			count -> callback.success(count),
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Force all buffered data to be committed.
	**/
	public function flush(callback:Callback<NoData>):Void {
		writer.flush(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
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
	public function close(callback:Callback<NoData>) {
		callback.fail(new NotImplementedException());
	}
}