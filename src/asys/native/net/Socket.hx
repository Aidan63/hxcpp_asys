package asys.native.net;

import sys.thread.Thread;
import asys.native.net.Ip;
import asys.native.net.SocketOptions;
import haxe.NoData;
import haxe.Callback;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.exceptions.NotImplementedException;

private class IpcSocketSpecialisation extends Socket {
	final native : cpp.asys.IpcSocket;

	public function new(native : cpp.asys.IpcSocket) {
		super(native);

		this.native = native;
	}

	override function get_localAddress():SocketAddress {
		return SocketAddress.Ipc(native.socketName);
	}

	override function get_remoteAddress():Null<SocketAddress> {
		return SocketAddress.Ipc(native.peerName);
	}
}

private class TcpSocketSpecialisation extends Socket {
	final native : cpp.asys.TcpSocket;

	public function new(native : cpp.asys.TcpSocket) {
		super(native);

		this.native = native;
	}

	override function get_localAddress():SocketAddress {
		return SocketAddress.Net(native.localAddress.host, native.localAddress.port);
	}

	override function get_remoteAddress():Null<SocketAddress> {
		return SocketAddress.Net(native.remoteAddress.host, native.remoteAddress.port);
	}

	override function getOption<T>(option:SocketOptionKind<T>, callback:Callback<T, Exception>) {
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
}

class Socket implements IDuplex {
	final duplex : cpp.asys.Duplex;

	function new(duplex) {
		this.duplex = duplex;
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
		switch address {
			case Net(host, port):
				try {
					switch IpTools.parseIp(host) {
						case Ipv4(_):
							cpp.asys.TcpSocket.connect_ipv4(
								@:privateAccess Thread.current().events.context,
								host,
								port,
								options,
								socket -> callback.success(new TcpSocketSpecialisation(socket)),
								msg -> callback.fail(new IoException(msg)));
						case Ipv6(_):
							cpp.asys.TcpSocket.connect_ipv6(
								@:privateAccess Thread.current().events.context,
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
					@:privateAccess Thread.current().events.context,
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
		duplex.read(
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
		duplex.write(
			buffer.getData(),
			offset,
			length,
			() -> callback.success(length),
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Force all buffered data to be committed.
	**/
	public function flush(callback:Callback<NoData>):Void {
		duplex.flush(
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
		duplex.close(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}
}