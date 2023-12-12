package asys.native.net;

import haxe.exceptions.NotImplementedException;
import asys.native.net.SocketOptions;
import cpp.asys.SocketAddressTools.makeSocketAddress;
import haxe.NoData;
import haxe.Callback;
import asys.native.net.Ip.IpTools;
import sys.thread.Thread;

typedef ServerOptions = SocketOptions & {
	/**
		Maximum size of incoming connections queue.
		Default: 0
		TODO: decide on a meaningful default value.
	**/
	var ?backlog:Int;
}

class Server {
    final native : cpp.asys.Server;
    final address : SocketAddress;

    public var localAddress(get,never):SocketAddress;
    function get_localAddress():SocketAddress return address;

    function new(native) {
        this.native = native;
        this.address = makeSocketAddress(native.name);
    }

    public function accept(callback:Callback<Socket>) {
        native.accept(
            socket -> callback.success(@:privateAccess new Socket(socket)),
            msg -> callback.fail(new IoException(msg)));
    }

    public function close(callback:Callback<NoData>) {
        native.close(
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

    static public function open(address:SocketAddress, ?options:ServerOptions, callback:Callback<Server>) {
        switch address {
            case Net(host, port):
                try {
                    switch IpTools.parseIp(host) {
						case Ipv4(_):
                            cpp.asys.Server.open_ipv4(
                                @:privateAccess Thread.current().events.context,
                                host,
                                port,
                                options,
                                server -> callback.success(new Server(server)),
                                msg -> callback.fail(new IoException(msg)));
						case Ipv6(_):
							cpp.asys.Server.open_ipv6(
                                @:privateAccess Thread.current().events.context,
                                host,
                                port,
                                options,
                                server -> callback.success(new Server(server)),
                                msg -> callback.fail(new IoException(msg)));
                    }
                } catch (exn) {
                    callback.fail(exn);
                }
            case Ipc(path):
                cpp.asys.Server.open_ipc(
                    @:privateAccess Thread.current().events.context,
                    path,
                    options,
                    server -> callback.success(new Server(server)),
                    msg -> callback.fail(new IoException(msg)));
        }
    }
}