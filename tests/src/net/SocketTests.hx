package net;

import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.io.Bytes;
import utest.Assert;
import asys.native.net.Socket;
import sys.thread.Thread;
import utest.Async;
import utest.Test;

class SocketTests extends Test {
    function test_connection_disconnection(async:Async) {
        Thread.createWithEventLoop(() -> {
            final server = new sys.net.Socket();
            server.bind(new sys.net.Host("127.0.0.1"), 7777);
            server.listen(1);

            final socket = server.accept();
            socket.close();
            server.close();
        });

        Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.close((_, error) -> {
                    Assert.isNull(error);

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_socket_reading(async:Async) {
        final text = "Hello, client";

        Thread.create(() -> {
            final server = new sys.net.Socket();
            server.bind(new sys.net.Host("127.0.0.1"), 7777);
            server.listen(1);

            final socket = server.accept();
            socket.write(text);
            socket.close();

            server.close();
        });

        Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
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
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_socket_write(async:Async) {
        final text = "Hello, server";

        Thread.create(() -> {
            final server = new sys.net.Socket();
            server.bind(new sys.net.Host("127.0.0.1"), 7777);
            server.listen(1);

            final socket = server.accept();
            final _      = socket.read();

            socket.close();
            server.close();
        });

        Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(text.length, count);
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    // function test_socket_read_disconnection(async:Async) {
    //     Thread.create(() -> {
    //         final server = new sys.net.Socket();
    //         server.bind(new sys.net.Host("127.0.0.1"), 7777);
    //         server.listen(1);

    //         final socket = server.accept();

    //         socket.close();
    //         server.close();
    //     });

    //     Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
    //         Assert.isNull(error);

    //         if (Assert.notNull(socket)) {
    //             final buffer = Bytes.alloc(1024);

    //             socket.read(buffer, 0, buffer.length, (count, error) -> {
    //                 if (Assert.isOfType(error, IoException)) {
    //                     Assert.equals(IoErrorType.CustomError("EOF"), (cast error : IoException).type);
    //                 }

    //                 socket.close((_, error) -> {
    //                     Assert.isNull(error);
    
    //                     async.done();
    //                 });
    //             });
    //         } else {
    //             async.done();
    //         }
    //     });
    // }

    // function test_socket_write_disconnection(async:Async) {
    //     Thread.create(() -> {
    //         final server = new sys.net.Socket();
    //         server.bind(new sys.net.Host("127.0.0.1"), 7777);
    //         server.listen(1);

    //         final socket = server.accept();

    //         socket.close();
    //         server.close();
    //     });

    //     Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
    //         Assert.isNull(error);

    //         if (Assert.notNull(socket)) {
    //             final text = "Hello, server";
    //             final buffer = Bytes.ofString(text);

    //             socket.write(buffer, 0, buffer.length, (count, error) -> {
    //                 if (Assert.isOfType(error, IoException)) {
    //                     Assert.equals(IoErrorType.CustomError("EOF"), (cast error : IoException).type);
    //                 }

    //                 socket.close((_, error) -> {
    //                     Assert.isNull(error);
    
    //                     async.done();
    //                 });
    //             });
    //         } else {
    //             async.done();
    //         }
    //     });
    // }

    function test_socket_connect_timeout(async:Async) {
        Socket.connect(Net("127.0.0.1", 7777), {}, (socket, error) -> {
            if (Assert.isOfType(error, IoException)) {
                Assert.equals(IoErrorType.ConnectionRefused, (cast error : IoException).type);
            }

            async.done();
        });
    }
}