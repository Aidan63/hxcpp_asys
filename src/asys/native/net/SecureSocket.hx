package asys.native.net;

import haxe.exceptions.NotImplementedException;
import cpp.asys.SecureSession;
import haxe.NoData;
import haxe.io.Bytes;
import haxe.Exception;
import haxe.Callback;

typedef SecureSocketOptions = SocketOptions & {}

class SecureSocket implements IDuplex {
    final socket:Socket;
    final session:SecureSession;

    function new(_socket:Socket, _session:SecureSession) {
        socket  = _socket;
        session = _session;
    }

	static public function connect(address:SocketAddress, options:SecureSocketOptions, callback:Callback<SecureSocket>) {
		Socket.connect(address, options, (socket, error) -> {
            switch error {
                case null:
                    switch address {
                        case Net(host, _):
                            SecureSession.authenticateAsClient(
                                @:privateAccess socket.native,
                                host,
                                session -> callback.success(new SecureSocket(socket, session)),
                                error -> callback.fail(new Exception(error)));
                        case Ipc(_):
                            callback.fail(new NotImplementedException());
                    }
                case exn:
                    callback.fail(exn);
            }
        });
	}

	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int, Exception>) {
        final temp = Bytes.alloc(1024);

        socket.read(
            temp,
            0,
            temp.length,
            (count, error) -> {
                switch error {
                    case null:
                        session.decode(
                            temp.getData(),
                            0,
                            count,
                            bytes -> {
                                final size = Std.int(Math.min(length, bytes.length));
                                final src  = Bytes.ofData(bytes);

                                buffer.blit(offset, src, 0, size);

                                callback.success(size);
                            },
                            error -> callback.fail(new Exception(error)));
                    case exn:
                        callback.fail(exn);
                }
            });
    }

    public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int, Exception>) {
        session.encode(
            buffer.getData(),
            offset,
            length,
            encoded -> socket.write(Bytes.ofData(encoded), 0, encoded.length, callback),
            error -> callback.fail(new Exception(error)));
    }

    public function close(callback:Callback<NoData, Exception>) {
        session.close(
            bytes -> socket.write(Bytes.ofData(bytes), 0, bytes.length, (_, error) -> {
                switch error {
                    case null:
                        socket.close(callback);
                    case exn:
                        callback.fail(exn);
                }
            }),
            error -> callback.fail(new Exception(error)));
    }

    public function flush(callback:Callback<NoData, Exception>)
    {
        callback.success(null);
    }
}