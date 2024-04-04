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
        proc = new Process('haxe -p scripts/server --run TcpListenWrite "$address" "$port" "$text"');
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
        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer   = Bytes.alloc(1024);
                final expected = Bytes.ofString(text);

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected.length, count);
                        Assert.equals(0, buffer.sub(0, count).compare(expected));
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

    public function test_reading_from_killed_server(async:Async) {
        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                proc.kill();
                proc.exitCode();
                proc.close();
                proc = null;

                socket.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, IoException)) {
                        Assert.equals(0, count);
                        Assert.equals(IoErrorType.CustomError("EOF"), (cast error:IoException).type);
                    } else {
                        Assert.equals(count, buffer.length);
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

    public function test_reading_null_callback(async:Async) {
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
                    
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_null_buffer(async:Async) {
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

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_negative_offset(async:Async) {
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

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_large_offset(async:Async) {
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

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_negative_length(async:Async) {
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
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    public function test_reading_invalid_range_due_to_large_length(async:Async) {
        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 0, buffer.length * 2, (count, error) -> {
                    Assert.isOfType(error, Exception);
                    Assert.equals(0, count);

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

    public function test_reading_invalid_range_due_to_offset(async:Async) {
        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.alloc(1024);

                socket.read(buffer, 10, buffer.length, (count, error) -> {
                    Assert.isOfType(error, Exception);
                    Assert.equals(0, count);

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
}