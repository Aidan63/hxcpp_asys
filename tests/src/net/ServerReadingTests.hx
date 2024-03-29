package net;

import haxe.io.Bytes;
import sys.io.Process;
import haxe.exceptions.ArgumentException;
import asys.native.net.Server;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(1000)
class ServerReadingTests extends Test {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    function test_net_reading(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer   = Bytes.alloc(1024);
                        final expected = Bytes.ofString(text);

                        socket.read(buffer, 0, buffer.length, (count, error) -> {
                            Assert.isNull(error);

                            if (Assert.equals(expected.length, count)) {
                                Assert.equals(0, buffer.sub(0, count).compare(expected));
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
    
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    proc.kill();
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

    function test_net_reading_null_callback(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        Assert.raises(() -> socket.read(buffer, 0, buffer.length, null), ArgumentException);
                    }
                    
                    server.close((_, error) -> {
                        Assert.isNull(error);

                        proc.kill();
                        proc.close();

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_net_reading_null_buffer(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(null, 0, buffer.length, (count, error) -> {
                            if (Assert.isOfType(error, ArgumentException)) {
                                Assert.equals("buffer", (cast error:ArgumentException).argument);
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
    
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    proc.kill();
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

    function test_net_reading_negative_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, -10, buffer.length, (count, error) -> {
                            if (Assert.isOfType(error, ArgumentException)) {
                                Assert.equals("offset", (cast error:ArgumentException).argument);
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
    
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    proc.kill();
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

    function test_net_reading_large_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, buffer.length * 2, buffer.length, (count, error) -> {
                            if (Assert.isOfType(error, ArgumentException)) {
                                Assert.equals("offset", (cast error:ArgumentException).argument);
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
                                
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    proc.kill();
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

    function test_net_reading_negative_length(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, 0, -10, (count, error) -> {
                            if (Assert.isOfType(error, ArgumentException)) {
                                Assert.equals("length", (cast error:ArgumentException).argument);
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
                                
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    proc.kill();
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