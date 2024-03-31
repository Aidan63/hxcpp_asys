package system;

import haxe.exceptions.ArgumentException;
import asys.native.filesystem.FilePath;
import asys.native.IoErrorType;
import asys.native.IoException;
import haxe.io.Bytes;
import utest.Assert;
import asys.native.system.Process;
import utest.Async;
import utest.Test;

class TestProcessOpen extends Test {
    function test_non_existing_program(async:Async) {
        Process.open("does_not_exist", {}, (proc, error) -> {
            Assert.isNull(proc);

            if (Assert.isOfType(error, IoException)) {
                Assert.equals(IoErrorType.FileNotFound, (cast error : IoException).type);
            }

            async.done();
        });
    }

    function test_null_callback() {
        Assert.exception(
            () -> Process.open(Sys.programPath(), null, null),
            ArgumentException,
            exn -> exn.argument == "callback");
    }

    function test_null_program(async:Async) {
        Process.open(null, null, (proc, error) -> {
            Assert.isNull(proc);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals((cast error : ArgumentException).argument, "command");
            }

            async.done();
        });
    }

    function test_pid(async:Async) {
        Process.open(Sys.programPath(), { args: [ Mode.ZeroExit ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                Assert.isTrue(proc.pid > 0);

                proc.close((_, error) -> {
                    Assert.isNull(error);

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_exit_code(async:Async) {
        Process.open(Sys.programPath(), { args: [ Mode.ZeroExit ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                proc.exitCode((exit, error) -> {
                    Assert.isNull(error);
                    Assert.equals(0, exit);

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_non_zero_exit_code(async:Async) {
        final code = 7;

        Process.open(Sys.programPath(), { args: [ Mode.ErrorExit, Std.string(code) ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                proc.exitCode((exit, error) -> {
                    Assert.isNull(error);
                    Assert.equals(code, exit);

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_stdout(async:Async) {
        final srcString = "hello";
        final srcBytes  = Bytes.ofString(srcString);

        Process.open(Sys.programPath(), { args: [ Mode.StdoutEcho, srcString ], stdio : [ Ignore, PipeWrite, Ignore ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(count > 0);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(srcBytes.length, read);
                        Assert.equals(0, buffer.sub(0, read).compare(srcBytes));

                        proc.close((_, error) -> {
                            Assert.isNull(error);
    
                            async.done();
                        });
                    } else {
                        async.done();
                    }
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_stderr(async:Async) {
        final srcString = "hello";
        final srcBytes  = Bytes.ofString(srcString);

        Process.open(Sys.programPath(), { args: [ Mode.StderrEcho, srcString ], stdio : [ Ignore, Ignore, PipeWrite ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stderr.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(count > 0);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(srcBytes.length, read);
                        Assert.equals(0, buffer.sub(0, read).compare(srcBytes));

                        proc.close((_, error) -> {
                            Assert.isNull(error);
    
                            async.done();
                        });
                    } else {
                        async.done();
                    }
                });
            } else {
                async.done();
            }
        });
    }

    function test_writing_stdin(async:Async) {
        final srcString = "hello";
        final srcBytes  = Bytes.ofString(srcString);

        Process.open(Sys.programPath(), { args: [ Mode.StdinEcho, srcString ], stdio : [ PipeRead, PipeWrite, Ignore ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                proc.stdin.write(srcBytes, 0, srcBytes.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(srcBytes.length, count);
                    }
                });

                proc.exitCode((exit, error) -> {
                    Assert.isNull(error);
                    Assert.equals(0, exit);
                    
                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_killing_process(async:Async) {
        Process.open(Sys.programPath(), { args: [ Mode.LoopForever ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                proc.sendSignal(Kill, (_, error) -> {
                    Assert.isNull(error);
    
                    proc.exitCode((exit, error) -> {
                        Assert.isTrue(exit != 0);
                        Assert.isNull(error);
        
                        proc.close((_, error) -> {
                            Assert.isNull(error);
        
                            async.done();
                        });
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_exitcode_after_exit(async:Async) {
        final expected = 7;

        Process.open(Sys.programPath(), { args: [ Mode.ErrorExit, Std.string(expected) ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected, exit);

                        proc.exitCode((exit, error) -> {
                            if (Assert.isNull(error)) {
                                Assert.equals(expected, exit);
                            }

                            proc.close((_, error) -> {
                                Assert.isNull(error);
            
                                async.done();
                            });
                        });
                    } else {
                        proc.close((_, error) -> {
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

    function test_inherit_cwd(async:Async) {
        final expected = Bytes.ofString(Sys.getCwd());

        Process.open(Sys.programPath(), { args: [ Mode.PrintCwd ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(count > 0);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(expected.length, read);
                        Assert.equals(0, buffer.sub(0, read).compare(expected));
                    }

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_different_cwd(async:Async) {
        final path = FilePath.ofString(Sys.getCwd()).parent().parent();

        Process.open(Sys.programPath(), { args: [ Mode.PrintCwd ], cwd : path }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(count > 0);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(path, FilePath.ofString(buffer.sub(0, read).toString()).normalize());
                    }

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_custom_envvar(async:Async) {
        final env   = "FOO";
        final value = "BAR";

        Process.open(Sys.programPath(), { args: [ Mode.PrintEnv, env ], env: [ env => value ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(value.length, count);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(0, Bytes.ofString(value).compare(buffer.sub(0, read)));
                    }

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_inherit_envvar(async:Async) {
        final env   = "FOO";
        final value = "BAR";

        Sys.putEnv(env, value);

        Process.open(Sys.programPath(), { args: [ Mode.PrintEnv, env ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(value.length, count);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(0, Bytes.ofString(value).compare(buffer.sub(0, read)));
                    }

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_both_envvar(async:Async) {
        final env   = "FOO";
        final value = "BAR";

        Sys.putEnv(env, value);

        Process.open(Sys.programPath(), { args: [ Mode.PrintEnv, env ], env: [ "BAR" => "BAZ" ] }, (proc, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(proc)) {
                final buffer = Bytes.alloc(1024);
                var read = 0;

                proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(value.length, count);

                        read += count;
                    }
                });

                proc.exitCode((exit, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(0, Bytes.ofString(value).compare(buffer.sub(0, read)));
                    }

                    proc.close((_, error) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    @:timeout(1000)
    function test_argument_escaping(async:Async) {
        final cases = [
            'HelloWorld',
            'Hello World',
            'Hello"World',
            'Hello World\\',
            'Hello\\"World',
            'Hello\\World',
            'Hello\\\\World',
            "c:\\path\\to\\node.exe --eval \"require('c:\\\\path\\\\to\\\\test.js')\""
        ];

        function run() {

            function again() {
                if (cases.length > 0) {
                    run();
                } else {
                    async.done();
                }
            }

            final srcString = cases.shift();
            final srcBytes  = Bytes.ofString(srcString);

            Process.open(Sys.programPath(), { args: [ Mode.StdoutEcho, srcString ], stdio : [ Ignore, PipeWrite ] }, (proc, error) -> {
                Assert.isNull(error);

                if (Assert.notNull(proc)) {
                    final buffer = Bytes.alloc(1024);
                    var read = 0;

                    proc.stdout.read(buffer, 0, buffer.length, (count, error) -> {
                        if (Assert.isNull(error)) {
                            Assert.isTrue(count > 0);

                            read += count;
                        }
                    });

                    proc.exitCode((exit, error) -> {
                        if (Assert.isNull(error)) {
                            Assert.equals(srcBytes.length, read);
                            Assert.equals(0, buffer.sub(0, read).compare(srcBytes));   
                        }

                        proc.close((_, error) -> {
                            Assert.isNull(error);
    
                            again();
                        });
                    });
                } else {
                    again();
                }
            });
        }

        run();
    }
}