package utils;

import haxe.Callback;
import asys.native.IoException;
import asys.native.net.Socket;
import asys.native.net.SocketOptions;
import asys.native.net.SocketAddress;

function tryConnect(attempt:Int, address:SocketAddress, ?options:SocketOptions, callback:Callback<Socket>) {
    if (attempt > 3) {
        callback.fail(new IoException(ConnectionRefused));

        return;
    }

    Socket.connect(address, options, (socket, error) -> {
        switch error {
            case null:
                callback.success(socket);
            case exn:
                if (exn is IoException && (cast exn:IoException).type == ConnectionRefused) {
                    tryConnect(attempt++, address, options, callback);
                } else {
                    callback.fail(error);
                }
        }
    });
}