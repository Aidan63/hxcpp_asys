package net;

import sys.io.Process;
import haxe.Exception;
import haxe.exceptions.ArgumentException;
import haxe.exceptions.NotImplementedException;
import asys.native.IoErrorType;
import asys.native.IoException;
import asys.native.net.Socket;
import utest.Assert;
import utest.Async;
import utest.Test;
import utils.SocketHelper;

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

        tryConnect(0, Net(address, port), null, (socket, error) -> {
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

        tryConnect(0, Net(address, port), null, (socket, error) -> {
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

        tryConnect(0, Net(address, port), null, (socket, error) -> {
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

        tryConnect(0, Net(address, port), null, (socket, error) -> {
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

    function test_custom_keep_alive(async:Async) {
        final proc     = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');
        final expected = false;

        tryConnect(0, Net(address, port), { keepAlive: expected }, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(KeepAlive, (enabled, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected, enabled);
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

    function test_custom_send_buffer_size(async:Async) {
        final proc     = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');
        final expected = 7000;

        tryConnect(0, Net(address, port), { sendBuffer: expected }, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(SendBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected, size);
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

    function test_custom_recv_buffer_size(async:Async) {
        final proc     = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');
        final expected = 7000;

        tryConnect(0, Net(address, port), { receiveBuffer: expected }, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(ReceiveBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected, size);
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

    function test_local_address(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(ReceiveBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        switch socket.localAddress {
                            case Net(host, port):
                                Assert.equals(address, host);
                                Assert.isTrue(port > 0);
                            case Ipc(_):
                                Assert.fail('Expected network socket address');
                        }
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

    function test_remote_address(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(ReceiveBuffer, (size, error) -> {
                    if (Assert.isNull(error)) {
                        switch socket.localAddress {
                            case Net(host, port):
                                Assert.equals(address, host);
                                Assert.isTrue(port > 0);
                            case Ipc(_):
                                Assert.fail('Expected network socket address');
                        }
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

    function test_get_option_null_callback(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                Assert.exception(
                    () -> socket.getOption(ReceiveBuffer, null),
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

    function test_get_unsupported_option(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(MulticastLoop, (_, error) -> {
                    Assert.isOfType(error, NotImplementedException);

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

    function test_get_invalid_option(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.getOption(cast -1, (_, error) -> {
                    Assert.isOfType(error, NotImplementedException);

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

    function test_set_option_null_callback(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                Assert.exception(
                    () -> socket.setOption(ReceiveBuffer, 1024, null),
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

    function test_set_unsupported_option(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.setOption(MulticastLoop, true, (_, error) -> {
                    Assert.isOfType(error, NotImplementedException);

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

    function test_set_invalid_option(async:Async) {
        final proc = new Process('haxe -p scripts/server --run TcpListen "$address" "$port"');

        tryConnect(0, Net(address, port), null, (socket, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(socket)) {
                socket.setOption(cast -1, null, (_, error) -> {
                    Assert.isOfType(error, NotImplementedException);

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