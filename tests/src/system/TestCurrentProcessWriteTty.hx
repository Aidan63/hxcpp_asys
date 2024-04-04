package system;

import utils.IWritableTests;
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

abstract class TestCurrentProcessWriteTty extends Test implements IWritableTests {
    final data : Bytes;
    final writable : IWritable;

    public function new(_writable) {
        super();

        data     = Bytes.ofString("Hello, World\r\n");
        writable = _writable;
    }

    public function test_writing(async:Async) {
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

    public function test_writing_null_callback(async:Async) {
        Assert.raises(() -> writable.write(data, 0, data.length, null), ArgumentException);

        async.done();
    }

    public function test_writing_null_buffer(async:Async) {
        writable.write(null, 0, 7, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("buffer", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    public function test_writing_negative_offset(async:Async) {
        writable.write(data, -1, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("offset", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    public function test_writing_large_offset(async:Async) {
        writable.write(data, 0, -1, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    public function test_writing_negative_length(async:Async) {
        writable.write(data, data.length + 1, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("offset", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    public function test_writing_invalid_range_due_to_large_length(async:Async) {
        writable.write(data, 0, data.length * 2, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    public function test_writing_invalid_range_due_to_offset(async:Async) {
        writable.write(data, 8, data.length, (count, error) -> {
            Assert.equals(0, count);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("length", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }
}