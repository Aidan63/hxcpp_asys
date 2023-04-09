package asys.native.net;

import haxe.NoData;
import asys.native.net.Ip.IpTools;
import sys.thread.Thread;

typedef ServerOptions = {
	/**
		Maximum size of incoming connections queue.
		Default: 0
		TODO: decide on a meaningful default value.
	**/
	var ?backlog:Int;
}

class Server {
    final native : cpp.asys.Server;

    function new(native) {
        this.native = native;
    }

    public function accept(callback:Callback<Socket>) {
        native.accept(
            (socket, sock, peer) -> callback.success(@:privateAccess new Socket(socket, sock, peer)),
            msg -> callback.fail(new IoException(msg)));
    }

    public function close(callback:Callback<NoData>) {
        native.close(
            () -> callback.success(null),
            msg -> callback.fail(new IoException(msg)));
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
                                server -> callback.success(new Server(server)),
                                msg -> callback.fail(new IoException(msg)));
						case Ipv6(_):
							cpp.asys.Server.open_ipv6(
                                @:privateAccess Thread.current().events.context,
                                host,
                                port,
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
                    server -> callback.success(new Server(server)),
                    msg -> callback.fail(new IoException(msg)));
        }
    }
}