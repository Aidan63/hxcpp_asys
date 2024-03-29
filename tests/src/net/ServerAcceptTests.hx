package net;

import sys.io.Process;
import haxe.Exception;
import haxe.exceptions.ArgumentException;
import asys.native.net.Server;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(1000)
class ServerAcceptTests extends Test {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    function test_accept_net_client(async:Async) {
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
                            Assert.isNull(error);

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

    function test_accept_null_callback(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final proc = new Process("haxe -p scripts/client --run TcpConnect");

                Assert.raises(() -> server.accept(null), ArgumentException);

                server.close((_, error) -> {
                    Assert.isNull(error);

                    proc.kill();
                    proc.close();

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_accept_custom_keep_alive(async:Async) {
        final expected = false;

        Server.open(Net(address, port), { keepAlive: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final proc = new Process("haxe -p scripts/client --run TcpConnect");

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.getOption(KeepAlive, (keepAlive, error) -> {
                            Assert.isNull(error);
                            Assert.equals(expected, keepAlive);

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
                        });
                    } else {
                        server.close((_, error) -> {
                            Assert.isNull(error);

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

    function test_accept_custom_send_buffer_size(async:Async) {
        final expected = 7000;

        Server.open(Net(address, port), { sendBuffer: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final proc = new Process("haxe -p scripts/client --run TcpConnect");

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.getOption(SendBuffer, (size, error) -> {
                            Assert.isNull(error);
                            Assert.equals(expected, size);

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
                        });
                    } else {
                        server.close((_, error) -> {
                            Assert.isNull(error);

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

    function test_accept_custom_recv_buffer_size(async:Async) {
        final expected = 7000;

        Server.open(Net(address, port), { receiveBuffer: expected }, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final proc = new Process("haxe -p scripts/client --run TcpConnect");

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        socket.getOption(ReceiveBuffer, (size, error) -> {
                            Assert.isNull(error);
                            Assert.equals(expected, size);

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
                        });
                    } else {
                        server.close((_, error) -> {
                            Assert.isNull(error);

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
}