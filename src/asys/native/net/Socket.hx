package asys.native.net;

import cpp.asys.SocketAddressTools.makeSocketAddress;
import haxe.Exception;
import asys.native.net.Ip.IpTools;
import sys.thread.Thread;
import asys.native.net.SocketOptions.SocketOptionKind;
import haxe.NoData;
import haxe.io.Bytes;
import haxe.exceptions.NotImplementedException;

class Socket implements IDuplex {
	final native : cpp.asys.Socket;
	final iSocketAddress : Null<SocketAddress>;
	final iRemoteAddress : Null<SocketAddress>;

	function new(native) {
		this.native = native;
		this.iSocketAddress = makeSocketAddress(native.name);
		this.iRemoteAddress = makeSocketAddress(native.peer);
	}

	/**
		Local address of this socket.
	**/
	public var localAddress(get,never):SocketAddress;
	function get_localAddress():SocketAddress {
		return if (iSocketAddress != null) {
			iSocketAddress;
		} else {
			throw new Exception("Unable to get local address");
		}
	}

	/**
		Remote address of this socket if it is bound.
	**/
	public var remoteAddress(get,never):Null<SocketAddress>;
	function get_remoteAddress():Null<SocketAddress> {
		return if (iRemoteAddress != null) {
			iRemoteAddress;
		} else {
			throw new Exception("Unable to get remote address");
		}
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
							cpp.asys.Socket.connect_ipv4(
								@:privateAccess Thread.current().events.context,
								host,
								port,
								options,
								socket -> callback.success(new Socket(socket)),
								msg -> callback.fail(new IoException(msg)));
						case Ipv6(_):
							cpp.asys.Socket.connect_ipv6(
								@:privateAccess Thread.current().events.context,
								host,
								port,
								options,
								socket -> callback.success(new Socket(socket)),
								msg -> callback.fail(new IoException(msg)));
					}
				}
				catch (exn) {
					callback.fail(exn);
				}
			case Ipc(path):
				cpp.asys.Socket.connect_ipc(
					@:privateAccess Thread.current().events.context,
					path,
					options,
					socket -> callback.success(new Socket(socket)),
					msg -> callback.fail(new IoException(msg)));
		}
	}

	/**
		Read up to `length` bytes and write them into `buffer` starting from `offset`
		position in `buffer`, then invoke `callback` with the amount of bytes read.
	**/
	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
		native.read(
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
		native.write(
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
		native.flush(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Get the value of a specified socket option.
	**/
	public function getOption<T>(option:SocketOptionKind<T>, callback:Callback<T>) {
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

	/**
		Set socket option.
	**/
	public function setOption<T>(option:SocketOptionKind<T>, value:T, callback:Callback<NoData>) {
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

	/**
		Close the connection.
	**/
	public function close(callback:Callback<NoData>) {
		native.close(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}
}