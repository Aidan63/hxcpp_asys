import haxe.io.BytesData;
import haxe.NoData;
import asys.native.IDuplex;
import haxe.exceptions.NotImplementedException;
import sys.ssl.Certificate;
import cpp.Pointer;
import cpp.schannel.SChannelContext;
import haxe.Callback;
import haxe.Exception;
import haxe.io.Bytes;
import asys.native.net.Socket;

private class Handshake {
    final socket:Socket;
    final tls:Pointer<SChannelContext>;
    final buffer:Bytes;
    final callback:Callback<Pointer<SChannelContext>>;
    var offset:Int;

    function new(_socket, _tls, _callback) {
        socket   = _socket;
        tls      = _tls;
        buffer   = Bytes.alloc(16384);
        callback = _callback;
        offset   = 0;
    }

    public static function handshake(socket:Socket, tls:Pointer<SChannelContext>, callback:Callback<Pointer<SChannelContext>>) {
        tls.ptr.startHandshake(
            bytes -> {
                new Handshake(socket, tls, callback).writeHandshakeData(bytes);
            },
            error -> {
                callback.fail(new Exception(error));
            });
    }

    function writeHandshakeData(data:BytesData) {
        socket.write(Bytes.ofData(data), 0, data.length, (count, error) -> {
            switch error {
                case null:
                    socket.read(buffer, offset, buffer.length - offset, readHandshakeData);
                case exn:
                    callback.fail(exn);
            }
        });
    }

    function readHandshakeData(count:Int, error:Exception) {
        switch error {
            case null:
                tls.ptr.handshake(
                    buffer.sub(0, offset + count).getData(),
                    (result, data) -> {
                        switch result {
                            case Success:
                                callback.success(tls);
                            case NeedMoreData:
                                offset += count;

                                socket.read(buffer, offset, buffer.length - offset, readHandshakeData);
                            case TokenGenerated:
                                switch data {
                                    case null:
                                        callback.fail(new Exception("Token data was null"));
                                    case bytes:
                                        offset = 0;

                                        writeHandshakeData(bytes);
                                }
                        }
                    },
                    error -> callback.fail(new Exception(error)));
            case exn:
                callback.fail(exn);
        }
    }
}

typedef SecureSessionSettings = {
    var certificate:Certificate;
    var verifyCertificate:Bool;
    var hostname:String;
}

class SecureSession implements IDuplex {
    final tls:Pointer<SChannelContext>;
    final socket:Socket;

    var localCertificate (get, never) : Certificate;

    var remoteCertificate (get, never) : Certificate;

    function new(_tls, _socket) {
        tls    = _tls;
        socket = _socket;
    }

    function get_localCertificate() {
        throw new NotImplementedException();
    }

    function get_remoteCertificate() {
        throw new NotImplementedException();
    }

    /**
		Write up to `length` bytes from `buffer` (starting from buffer `offset`),
		then invoke `callback` with the amount of bytes written.
	**/
	public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
        tls.ptr.encode(
            buffer.getData(),
            offset,
            length,
            encoded -> socket.write(Bytes.ofData(encoded), 0, encoded.length, callback),
            error -> callback.fail(new Exception(error)));
    }

    /**
		Read up to `length` bytes and write them into `buffer` starting from `offset`
		position in `buffer`, then invoke `callback` with the amount of bytes read.
	**/
	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
        //
    }

    /**
		Force all buffered data to be committed.
	**/
	public function flush(callback:Callback<NoData>) {
        //
    }

	/**
		Close this stream.
	**/
	public function close(callback:Callback<NoData>) {
        //
    }

    public static function authenticateAsClient(socket:Socket, settings : SecureSessionSettings = null, callback:Callback<SecureSession>) {
        final host = switch socket.localAddress {
            case Net(host, _):
                host;
            case Ipc(path):
                path;
        }

        Handshake.handshake(
            socket,
            SChannelContext.create(host),
            (ptr, error) -> {
                switch error {
                    case null:
                        callback.success(new SecureSession(ptr, socket));
                    case exn:
                        callback.fail(exn);
                }
            });
    }
}