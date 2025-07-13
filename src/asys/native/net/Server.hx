package asys.native.net;

import haxe.exceptions.ArgumentException;
import haxe.exceptions.NotImplementedException;
import asys.native.net.SocketOptions;
import haxe.NoData;
import haxe.Callback;
import asys.native.net.Ip.IpTools;
import sys.thread.Thread;

using hxcoro.util.Convenience;

typedef ServerOptions = SocketOptions & {
	/**
		Maximum size of incoming connections queue.
		TODO: decide on a meaningful default value.
	**/
	var ?backlog:Int;
}

class Server {
    final native : cpp.asys.TcpServer;
    final address : SocketAddress;

    public var localAddress(get,never):SocketAddress;
    function get_localAddress():SocketAddress return address;

    function new(native) {
        this.native  = native;
        this.address = SocketAddress.Net(native.localAddress.host, native.localAddress.port);
    }

    @:coroutine public function accept():Socket {
		return hxcoro.Coro.suspend(cont -> {
			native.accept(
				socket -> cont.succeedAsync(@:privateAccess new asys.native.net.Socket.TcpSocketSpecialisation(socket)),
				msg -> cont.failAsync(new IoException(msg)));
		});
    }

    // public function close(callback:Callback<NoData>) {
	// 	if (callback == null) {
	// 		throw new ArgumentException("callback", "callback was null");
	// 	}

    //     native.close(
    //         () -> callback.success(null),
    //         msg -> callback.fail(new IoException(msg)));
    // }

	// /**
	// 	Get the value of a specified socket option.
	// **/
	// public function getOption<T>(option:SocketOptionKind<T>, callback:Callback<T>) {
	// 	if (callback == null) {
	// 		throw new ArgumentException("callback", "callback was null");
	// 	}

	// 	switch option {
	// 		case KeepAlive:
	// 			native.getKeepAlive(
	// 				callback.success,
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case SendBuffer:
	// 			native.getSendBufferSize(
	// 				callback.success,
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case ReceiveBuffer:
	// 			native.getRecvBufferSize(
	// 				callback.success,
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case _:
	// 			callback.fail(new NotImplementedException());
	// 	}
	// }

	// /**
	// 	Set socket option.
	// **/
	// public function setOption<T>(option:SocketOptionKind<T>, value:T, callback:Callback<NoData>) {
	// 	if (callback == null) {
	// 		throw new ArgumentException("callback", "callback was null");
	// 	}

	// 	switch option {
	// 		case KeepAlive:
	// 			native.setKeepAlive(
	// 				value,
	// 				() -> callback.success(null),
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case SendBuffer:
	// 			native.setSendBufferSize(
	// 				value,
	// 				() -> callback.success(null),
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case ReceiveBuffer:
	// 			native.setRecvBufferSize(
	// 				value,
	// 				() -> callback.success(null),
	// 				msg -> callback.fail(new IoException(msg)));
	// 		case _:
	// 			callback.fail(new NotImplementedException());
	// 	}
	// }

    @:coroutine static public function open(address:SocketAddress, options:Null<ServerOptions>):Server {
		if (address == null) {
			throw new ArgumentException("address", "address was null");
		}

        switch address {
            case Net(host, port):
				if (host == null) {
					throw new ArgumentException("host", "Net SocketAddress host was null");
				}

				if (options != null && options.backlog <= 0) {
					throw new ArgumentException("backlog", "Backlog must be greater than zero");
				}

                switch IpTools.parseIp(host) {
					case Ipv4(_):
						return hxcoro.Coro.suspend(cont -> {
							cpp.asys.TcpServer.open_ipv4(
								cpp.asys.Context.get(),
								host,
								port,
								options,
								server -> cont.succeedAsync(new Server(server)),
								msg -> cont.failAsync(new IoException(msg)));
						});
					case Ipv6(_):
						throw new NotImplementedException();
						// cpp.asys.TcpServer.open_ipv6(
						//     cpp.asys.Context.get(),
						//     host,
						//     port,
						//     options,
						//     server -> callback.success(new Server(server)),
						//     msg -> callback.fail(new IoException(msg)));
				}
            case Ipc(path):
				if (path == null) {
					throw new ArgumentException("path", "Ipc SocketAddress path was null");
				}

				throw new NotImplementedException();
                // cpp.asys.Server.open_ipc(
                //     @:privateAccess Thread.current().context(),
                //     path,
                //     options,
                //     server -> callback.success(new Server(server)),
                //     msg -> callback.fail(new IoException(msg)));
        }
    }
}