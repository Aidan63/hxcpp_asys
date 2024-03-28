package net;

import sys.thread.Thread;
import sys.io.Process;
import haxe.io.Bytes;
import asys.native.net.Server;
import asys.native.net.Socket;
import utest.Assert;
import utest.Async;
import utest.Test;

class ServerTests extends Test
{
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    function test_open(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.close((_, error) -> {
                    Assert.isNull(error);

                    async.done();
                });
            }
        });
    }

    function test_default_keep_alive(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(KeepAlive, (enabled, error) -> {
                    Assert.isNull(error);
                    Assert.isTrue(enabled);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    function test_default_send_buffer_size(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(SendBuffer, (size, error) -> {
                    Assert.isNull(error);
                    Assert.isTrue(size > 0);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    function test_default_receive_buffer_size(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(ReceiveBuffer, (size, error) -> {
                    Assert.isNull(error);
                    Assert.isTrue(size > 0);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    function test_custom_keep_alive(async:Async) {
        final expected = false;

        Server.open(Net(address, port), { keepAlive: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(KeepAlive, (enabled, error) -> {
                    Assert.isNull(error);
                    Assert.equals(expected, enabled);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    function test_custom_send_buffer_size(async:Async) {
        final expected = 7000;

        Server.open(Net(address, port), { sendBuffer: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(SendBuffer, (size, error) -> {
                    Assert.isNull(error);
                    Assert.equals(expected, size);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    function test_custom_receive_buffer_size(async:Async) {
        final expected = 7000;

        Server.open(Net(address, port), { receiveBuffer: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.getOption(ReceiveBuffer, (size, error) -> {
                    Assert.isNull(error);
                    Assert.equals(expected, size);

                    server.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            }
        });
    }

    @:timeout(2000)
    function test_connection_disconnection(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final proc = new Process("haxe -p scripts/client --run TcpConnect");

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.close((_, error) -> {
                            if (Assert.isNull(error)) {
                                proc.exitCode();
                            }

                            server.close((_, error) -> {
                                Assert.isNull(error);

                                proc.close();
                                async.done();
                            });
                        });
                    } else {
                        server.close((_, error) -> {
                            Assert.notNull(error);

                            proc.kill();
                            proc.close();

                            async.done();
                        });
                    }
                });
            } else {
                async.done();
            }
        });
    }

    // function test_server_write_socket_read(async:Async) {
    //     final text  = "Hello, World!";
    //     final bytes = Bytes.ofString(text);

    //     Server.open(Net(address, port), { backlog : 1 }, (server, error) -> {
    //         Assert.isNull(error);

    //         if (Assert.notNull(server)) {
    //             server.accept((socket, error) -> {
    //                 Assert.isNull(error);
                    
    //                 if (Assert.notNull(socket)) {
    //                     socket.write(bytes, 0, bytes.length, (count, error) -> {
    //                         Assert.notNull(error);
    //                         Assert.equals(bytes.length, count);

    //                         socket.close((_, error) -> {
    //                             server.close((_, error) -> {
    //                                 async.done();
    //                             });
    //                         });
    //                     });
    //                 } else {
    //                     server.close((_, error) -> {
    //                         async.done();
    //                     });
    //                 }
    //             });

    //             Socket.connect(Net(address, port), {}, (socket, error) -> {
    //                 socket.close((_, error) -> {
    //                     Assert.isNull(error);
    //                 });
    //             });
    //         } else {
    //             async.done();
    //         }
    //     });
    // }
}