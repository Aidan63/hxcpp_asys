package net;

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

    function test_connection_disconnection(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.close((_, error) -> {
                            server.close((_, error) -> {
                                async.done();
                            });
                        });
                    } else {
                        server.close((_, error) -> {
                            async.done();
                        });
                    }
                });

                Socket.connect(Net(address, port), {}, (socket, error) -> {
                    socket.close((_, error) -> {
                        Assert.isNull(error);
                    });
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