package system;

import haxe.io.Bytes;
import utest.Assert;
import asys.native.system.Process;
import utest.Async;
import utest.Test;

class TestProcessOpen extends Test {
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

        Process.open(Sys.programPath(), { args: [ Mode.StdoutEcho, srcString ], stdio : [ null, PipeWrite ] }, (proc, error) -> {
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
}