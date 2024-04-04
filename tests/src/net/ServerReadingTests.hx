package net;

import asys.native.IoErrorType;
import asys.native.IoException;
import utils.IReadableTests;
import haxe.Exception;
import haxe.io.Bytes;
import sys.io.Process;
import haxe.exceptions.ArgumentException;
import asys.native.net.Server;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(1000)
class ServerReadingTests extends Test implements IReadableTests {
    final address : String;
    final port : Int;
    final text : String;

    var proc : Null<Process>;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
        text    = "Hello, World!";
        proc    = null;
    }

    function setup() {
        proc = new Process('haxe -p scripts/client --run TcpWriter "$text"');
    }

    function teardown() {
        if (proc != null) {
            proc.kill();
            proc.exitCode();
            proc.close();
            proc = null;
        }
    }

    public function test_reading(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
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
    
                                    async.done();
                                });
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

    public function test_reading_after_closing(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        server.close((_, error) -> {
                            Assert.isNull(error);

                            final buffer   = Bytes.alloc(1024);
                            final expected = Bytes.ofString(text);

                            socket.read(buffer, 0, buffer.length, (count, error) -> {
                                Assert.isNull(error);
    
                                if (Assert.equals(expected.length, count)) {
                                    Assert.equals(0, buffer.sub(0, count).compare(expected));
                                }
    
                                socket.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    async.done();
                                });
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

    public function test_reading_from_killed_client(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, 0, buffer.length, (count, error) -> {
                            if (Assert.isOfType(error, IoException)) {
                                Assert.equals(IoErrorType.CustomError("EOF"), (cast error : IoException).type);
                            }

                            socket.close((_, error) -> {
                                Assert.isNull(error);
    
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    async.done();
                                });
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

    public function test_reading_null_callback(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        Assert.raises(() -> socket.read(buffer, 0, buffer.length, null), ArgumentException);
                    }
                    
                    server.close((_, error) -> {
                        Assert.isNull(error);
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_null_buffer(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
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
    
                                    async.done();
                                });
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

    public function test_reading_negative_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
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
    
                                    async.done();
                                });
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

    public function test_reading_large_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
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
    
                                    async.done();
                                });
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

    public function test_reading_negative_length(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
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
    
                                    async.done();
                                });
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

    public function test_reading_invalid_range_due_to_large_length(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, 0, buffer.length * 2, (count, error) -> {
                            Assert.isOfType(error, Exception);

                            socket.close((_, error) -> {
                                Assert.isNull(error);
                                
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    async.done();
                                });
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

    public function test_reading_invalid_range_due_to_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.alloc(1024);

                        socket.read(buffer, 10, buffer.length, (count, error) -> {
                            Assert.isOfType(error, Exception);

                            socket.close((_, error) -> {
                                Assert.isNull(error);
                                
                                server.close((_, error) -> {
                                    Assert.isNull(error);
    
                                    async.done();
                                });
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
}