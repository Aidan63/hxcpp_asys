package asys.native.net;

import haxe.NoData;
import haxe.exceptions.NotImplementedException;
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
                cpp.asys.Server.open_ipv4(
                    @:privateAccess Thread.current().events.context,
                    host,
                    port,
                    server -> callback.success(new Server(server)),
                    msg -> callback.fail(new IoException(msg)));
            case Ipc(path):
                callback.fail(new NotImplementedException());
        }
    }
}