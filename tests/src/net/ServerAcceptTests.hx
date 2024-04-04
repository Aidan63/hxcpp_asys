package net;

import sys.io.Process;
import haxe.exceptions.ArgumentException;
import asys.native.net.Server;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(1000)
class ServerAcceptTests extends Test {
    final address : String;
    final port : Int;

    var proc : Null<Process>;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
        proc    = null;
    }

    function setup() {
        proc = new Process("haxe -p scripts/client --run TcpConnect");
    }

    function teardown() {
        if (proc != null) {
            proc.kill();
            proc.exitCode();
            proc.close();
            proc = null;
        }
    }

    function test_accept_net_client(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.close((_, error) -> {
                            if (Assert.isNull(error)) {
                                proc.exitCode();
                            }

                            server.close((_, error) -> {
                                Assert.isNull(error);

                                async.done();
                            });
                        });
                    } else {
                        server.close((_, error) -> {
                            Assert.isNull(error);

                            async.done();
                        });
                    }
                });
            } else {
                async.done();
            }
        });
    }

    function test_accept_null_callback(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                Assert.exception(
                    () -> server.accept(null),
                    ArgumentException,
                    exn -> exn.argument == "callback");

                server.close((_, error) -> {
                    Assert.isNull(error);

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    // function test_multiple_connections(async:Async) {
    //     Server.open(Net(address, port), null, (server, error) -> {
    //         Assert.isNull(error);

    //         if (Assert.notNull(server)) {
    //             final proc1 = new Process("haxe -p scripts/client --run TcpConnect");

    //             server.accept((socket1, error) -> {
    //                 Assert.isNull(error);
                    
    //                 if (Assert.notNull(socket1)) {
    //                     final proc2 = new Process("haxe -p scripts/client --run TcpConnect");

    //                     server.accept((socket2, error) -> {
    //                         Assert.isNull(error);

    //                         if (Assert.notNull(socket2)) {
    //                             socket2.close((_, error) -> {
    //                                 if (Assert.isNull(error)) {
    //                                     proc2.exitCode();
    //                                 }

    //                                 socket1.close((_, error) -> {
    //                                     if (Assert.isNull(error)) {
    //                                         proc1.exitCode();
    //                                     }
            
    //                                     server.close((_, error) -> {
    //                                         Assert.isNull(error);
            
    //                                         proc1.close();
    //                                         async.done();
    //                                     });
    //                                 });
    //                             });
    //                         }
    //                         else {
    //                             proc2.kill();
    //                             proc2.close();

    //                             socket1.close((_, error) -> {
    //                                 if (Assert.isNull(error)) {
    //                                     proc1.exitCode();
    //                                 }
        
    //                                 server.close((_, error) -> {
    //                                     Assert.isNull(error);
        
    //                                     proc1.close();
    //                                     async.done();
    //                                 });
    //                             });
    //                         }                            
    //                     });
    //                 } else {
    //                     server.close((_, error) -> {
    //                         Assert.isNull(error);

    //                         proc1.kill();
    //                         proc1.close();

    //                         async.done();
    //                     });
    //                 }
    //             });
    //         } else {
    //             async.done();
    //         }
    //     });
    // }
}