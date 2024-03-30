package net;

import haxe.Exception;
import haxe.exceptions.ArgumentException;
import sys.io.Process;
import sys.thread.Lock;
import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.io.Bytes;
import utest.Assert;
import asys.native.net.Socket;
import sys.thread.Thread;
import utest.Async;
import utest.Test;

@:timeout(1000)
class SocketConnectTests extends Test {
    final address : String;
    final port : Int;

    public function new() {
        super();

        address = "127.0.0.1";
        port    = 7000;
    }

    function test_connect_null_callback() {
        Assert.exception(
            () -> Socket.connect(Net(address, port), null, null),
            ArgumentException,
            exn -> exn.argument == "callback");
    }

    function test_connect_null_address(async:Async) {
        Socket.connect(null, null, (socket, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("address", (cast error:ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_connect_null_host(async:Async) {
        Socket.connect(Net(null, port), null, (socket, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("ip", (cast error:ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_connect_invalid_host(async:Async) {
        Socket.connect(Net("not_a_host", port), null, (socket, error) -> {
            Assert.isOfType(error, Exception);

            async.done();
        });
    }

    function test_net_connect_timeout(async:Async) {
        Socket.connect(Net(address, port), null, (socket, error) -> {
            if (Assert.isOfType(error, IoException)) {
                Assert.equals(IoErrorType.ConnectionRefused, (cast error : IoException).type);
            }

            async.done();
        });
    }

    function test_net_connect(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        proc.stdout.readLine();

        Socket.connect(Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
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

    function test_default_keep_alive(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        proc.stdout.readLine();

        Socket.connect(Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(KeepAlive, (enabled, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(enabled);
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

    function test_default_send_buffer_size(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        proc.stdout.readLine();

        Socket.connect(Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(SendBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(size > 0);
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

    function test_default_recv_buffer_size(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        proc.stdout.readLine();

        Socket.connect(Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(ReceiveBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(size > 0);
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
}