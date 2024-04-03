package net;

import asys.native.IoErrorType;
import asys.native.IoException;
import utils.IWritableTests;
import haxe.Exception;
import haxe.io.Bytes;
import sys.io.Process;
import haxe.exceptions.ArgumentException;
import asys.native.net.Server;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(1000)
class ServerWritingTests extends Test implements IWritableTests {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    public function test_writing(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, 0, buffer.length, (count, error) -> {
                            Assert.isNull(error);
                            Assert.equals(text, proc.stdout.readLine());

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

    public function test_writing_to_killed_client(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpConnect');

                server.accept((socket, error) -> {
                    Assert.isNull(error);

                    proc.kill();
                    proc.close();
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, 0, buffer.length, (count, error) -> {
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

    public function test_writing_after_closing(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        server.close((_, error) -> {
                            Assert.isNull(error);

                            final buffer = Bytes.ofString(text);

                            socket.write(buffer, 0, buffer.length, (count, error) -> {
                                Assert.isNull(error);
                                Assert.equals(text, proc.stdout.readLine());
    
                                socket.close((_, error) -> {
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

    public function test_writing_null_callback(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        Assert.exception(
                            () -> socket.write(buffer, 0, buffer.length, null),
                            ArgumentException,
                            exn -> exn.argument == "callback");
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

    public function test_writing_null_buffer(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(null, 0, buffer.length, (count, error) -> {
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

    public function test_writing_negative_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, -10, buffer.length, (count, error) -> {
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

    public function test_writing_large_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, buffer.length * 2, buffer.length, (count, error) -> {
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

    public function test_writing_negative_length(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, 0, -10, (count, error) -> {
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

    public function test_writing_invalid_range_due_to_large_length(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, 0, buffer.length * 2, (count, error) -> {
                            Assert.isOfType(error, Exception);

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

    public function test_writing_invalid_range_due_to_offset(async:Async) {
        Server.open(Net(address, port), null, (server, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(server)) {
                final text = "Hello, World!";
                final proc = new Process('haxe -p scripts/client --run TcpReader ${text.length}');

                server.accept((socket, error) -> {
                    Assert.isNull(error);
                    
                    if (Assert.notNull(socket)) {
                        final buffer = Bytes.ofString(text);

                        socket.write(buffer, 10, buffer.length, (count, error) -> {
                            Assert.isOfType(error, Exception);

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