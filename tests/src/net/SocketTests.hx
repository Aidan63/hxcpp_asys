package net;

import sys.thread.Lock;
import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.io.Bytes;
import utest.Assert;
import asys.native.net.Socket;
import sys.thread.Thread;
import utest.Async;
import utest.Test;

class SocketTests extends Test {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    function test_connection_disconnection(async:Async) {
        final lock   = new Lock();
        final server = new sys.net.Socket();

        Thread.createWithEventLoop(() -> {
            try {
                server.bind(new sys.net.Host(address), port);
                server.listen(1);
                server.accept().close();
                server.close();
            } catch (_) {}

            lock.release();
        });

        Socket.connect(Net(address, port), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.close((_, error) -> {
                    Assert.isNull(error);
                    
                    lock.wait();

                    async.done();
                });
            } else {
                server.close();

                async.done();
            }
        });
    }

    function test_socket_reading(async:Async) {
        final text   = "Hello, client";
        final lock   = new Lock();
        final server = new sys.net.Socket();

        Thread.create(() -> {
            try {
                server.bind(new sys.net.Host(address), port);
                server.listen(1);

                final socket = server.accept();
                socket.write(text);
                socket.close();

                server.close();
            } catch (_) {}

            lock.release();
        });

        Socket.connect(Net(address, port), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        if (Assert.equals(text.length, count)) {
                            Assert.equals(0, Bytes.ofString(text).compare(buffer.sub(0, count)));
                        }
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);

                        lock.release();
    
                        async.done();
                    });
                });
            } else {
                server.close();

                async.done();
            }
        });
    }

    function test_socket_write(async:Async) {
        final text   = "Hello, server";
        final lock   = new Lock();
        final server = new sys.net.Socket();

        Thread.create(() -> {
            try {
                server.bind(new sys.net.Host(address), port);
                server.listen(1);

                final socket = server.accept();
                final _      = socket.read();

                socket.close();
                server.close();
            } catch (_) {}

            lock.release();
        });

        Socket.connect(Net(address, port), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(text.length, count);
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);

                        lock.wait();
    
                        async.done();
                    });
                });
            } else {
                server.close();

                async.done();
            }
        });
    }

    function test_socket_read_disconnection(async:Async) {
        final server = new sys.net.Socket();
        final lock   = new Lock();

        Thread.create(() -> {
            try {
                server.bind(new sys.net.Host(address), port);
                server.listen(1);

                final socket = server.accept();

                socket.close();
                server.close();
            } catch (_) {}

            lock.release();
        });

        Socket.connect(Net(address, port), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, IoException)) {
                        Assert.equals(IoErrorType.CustomError("EOF"), (cast error : IoException).type);
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);

                        lock.wait();
    
                        async.done();
                    });
                });
            } else {
                server.close();

                async.done();
            }
        });
    }

    function test_socket_write_disconnection(async:Async) {
        final server = new sys.net.Socket();
        final lock   = new Lock();
        final closed = new Lock();

        Thread.create(() -> {
            try {
                server.bind(new sys.net.Host(address), port);
                server.listen(1);
                server.accept().close();

                closed.release();

                server.close();
            } catch (_) {}

            lock.release();
        });

        Socket.connect(Net(address, port), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final text   = "Hello, server";
                final buffer = Bytes.ofString(text);

                closed.wait();

                socket.write(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, IoException)) {
                        Assert.equals(IoErrorType.CustomError("EOF"), (cast error : IoException).type);
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);

                        lock.wait();
    
                        async.done();
                    });
                });
            } else {
                server.close();

                async.done();
            }
        });
    }

    function test_socket_connect_timeout(async:Async) {
        Socket.connect(Net(address, port), {}, (socket, error) -> {
            if (Assert.isOfType(error, IoException)) {
                Assert.equals(IoErrorType.ConnectionRefused, (cast error : IoException).type);
            }

            async.done();
        });
    }
}