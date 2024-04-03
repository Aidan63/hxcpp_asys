package net;

import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.Exception;
import haxe.exceptions.ArgumentException;
import haxe.io.Bytes;
import utest.Assert;
import sys.io.Process;
import utest.Async;
import utest.Test;
import utils.SocketHelper;
import utils.IWritableTests;

@:timeout(1000)
class SocketWritingTests extends Test implements IWritableTests {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    public function test_writing(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(buffer.length, count);
                        // Assert.equals(text, proc.stdout.readLine());
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

    public function test_writing_to_killed_server(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                proc.exitCode();
                proc.close();

                socket.write(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, IoException)) {
                        Assert.equals(0, count);
                        Assert.equals(IoErrorType.CustomError("EOF"), (cast error:IoException).type);
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

    public function test_writing_null_callback(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                Assert.exception(
                    () -> socket.write(buffer, 0, buffer.length, null),
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

    public function test_writing_null_buffer(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(null, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals('buffer', (cast error : ArgumentException).argument);
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

    public function test_writing_negative_offset(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, -10, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals('offset', (cast error : ArgumentException).argument);
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

    public function test_writing_large_offset(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, buffer.length * 2, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals('offset', (cast error : ArgumentException).argument);
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

    public function test_writing_negative_length(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 0, -10, (count, error) -> {
                    if (Assert.isOfType(error, ArgumentException)) {
                        Assert.equals('length', (cast error : ArgumentException).argument);
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

    public function test_writing_invalid_range_due_to_large_length(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 0, buffer.length * 2, (count, error) -> {
                    Assert.isOfType(error, Exception);

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

    public function test_writing_invalid_range_due_to_offset(async:Async) {
        final text = "Hello, World!";
        final proc = new Process('haxe -p scripts/server --run TcpListenRead "$address" "$port" ${ text.length }');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                final buffer = Bytes.ofString(text);

                socket.write(buffer, 10, buffer.length, (count, error) -> {
                    Assert.isOfType(error, Exception);

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