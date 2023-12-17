package filesystem;

import haxe.exceptions.ArgumentException;
import asys.native.filesystem.FsException;
import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFileSystemCheck extends DirectoryTests {
    function test_check_file_exists(async:Async) {
        FileSystem.check(dummyFileName, Exists, (error, result) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_directory_exists(async:Async) {
        FileSystem.check(directoryName, Exists, (error, result) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_non_existing_file_exists(async:Async) {
        FileSystem.check(nonExistingFile, Exists, (error, result) -> {
            Assert.isNull(error);
            Assert.isFalse(result);

            async.done();
        });
    }

    function test_check_file_is_readable_and_writable(async:Async) {
        FileSystem.check(dummyFileName, Readable | Writable, (error, result) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_file_is_executable(async:Async) {
        FileSystem.check(dummyFileName, Executable, (error, result) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_directory_is_not_executable(async:Async) {
        FileSystem.check(directoryName, Executable, (error, result) -> {
            Assert.isNull(error);
            Assert.isFalse(result);

            async.done();
        });
    }

    function test_null_path(async:Async) {
        FileSystem.check(null, Executable, (error, result) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_zero_check(async:Async) {
        FileSystem.check(dummyFileName, cast 0, (error, result) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }
}