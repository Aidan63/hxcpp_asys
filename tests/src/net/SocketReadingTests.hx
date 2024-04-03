package net;

import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.io.Bytes;
import sys.io.Process;
import haxe.Exception;
import haxe.exceptions.ArgumentException;
import utest.Assert;
import utest.Async;
import utest.Test;
import utils.SocketHelper;
import utils.IReadableTests;

@:timeout(1000)
class SocketReadingTests extends Test implements IReadableTests {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    public function test_reading(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer   = Bytes.alloc(1024);
                final expected = Bytes.ofString(data);

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected.length, count);
                        Assert.equals(0, buffer.sub(0, count).compare(expected));
                    }

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_from_killed_server(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                proc.exitCode();
                proc.close();

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, IoException)) {
                        Assert.equals(0, count);
                        Assert.equals(IoErrorType.CustomError("EOF"), (cast error:IoException).type);
                    } else {
                        Assert.equals(count, buffer.length);
                    }

                    socket.close((_, error) -> {
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_null_callback(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                Assert.exception(
                    () -> socket.read(buffer, 0, buffer.length, null),
                    ArgumentException,
                    exn -> exn.argument == 'callback');

                socket.close((_, error) -> {                   
                    Assert.isNull(error);
                    
                    proc.exitCode();
                    proc.close();

                    async.done();
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_null_buffer(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(null, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals(0, count);
                        Assert.equals('buffer', (cast error:ArgumentException).argument);
                    }

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_negative_offset(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, -10, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals(0, count);
                        Assert.equals('offset', (cast error:ArgumentException).argument);
                    }

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_large_offset(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, buffer.length * 2, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals(0, count);
                        Assert.equals('offset', (cast error:ArgumentException).argument);
                    }

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_negative_length(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 0, -10, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals(0, count);
                        Assert.equals('length', (cast error:ArgumentException).argument);
                    }

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_invalid_range_due_to_large_length(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 0, buffer.length * 2, (count, error) -> {
                    Assert.isOfType(error, Exception);
                    Assert.equals(0, count);

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }

    public function test_reading_invalid_range_due_to_offset(async:Async) {
        final data = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$data"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 10, buffer.length, (count, error) -> {
                    Assert.isOfType(error, Exception);
                    Assert.equals(0, count);

                    socket.close((_, error) -> {                   
                        Assert.isNull(error);
                        
                        proc.exitCode();
                        proc.close();
    
                        async.done();
                    });
                });
            } else {
                proc.kill();
                proc.close();

                async.done();
            }
        });
    }
}