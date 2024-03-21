package system;

import asys.native.system.Process;
import asys.native.IWritable;
import haxe.exceptions.ArgumentException;
import haxe.io.Bytes;
import utest.Test;
import utest.Async;
import utest.Assert;

class TestCurrentProcessWriteStdout extends TestCurrentProcessWriteTty {
    public function new() {
        super(Process.current.stdout);
    }
}

class TestCurrentProcessWriteStderr extends TestCurrentProcessWriteTty {
    public function new() {
        super(Process.current.stderr);
    }
}

abstract class TestCurrentProcessWriteTty extends Test {
    final data : Bytes;
    final writable : IWritable;

    public function new(_writable) {
        super();

        data     = Bytes.ofString("Hello, World\r\n");
        writable = _writable;
    }

    function test_write(async:Async) {
        writable.write(
            data,
            0,
            data.length,
            (count, error) -> {
                Assert.isNull(error);
                Assert.equals(data.length, count);

                async.done();
            });
    }

    function test_null_callback() {
        Assert.raises(() -> writable.write(data, 0, data.length, null), ArgumentException);
    }

    function test_null_buffer(async:Async) {
        writable.write(null, 0, 7, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("buffer", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_negative_offset(async:Async) {
        writable.write(data, -1, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("offset", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_negative_length(async:Async) {
        writable.write(data, 0, -1, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_wrong_buffer_offset(async:Async) {
        writable.write(data, data.length + 1, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("offset", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_writing_too_long_buffer(async:Async) {
        writable.write(data, 0, data.length * 2, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_writing_too_long_buffer_length_due_to_offset(async:Async) {
        writable.write(data, 8, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }
}