package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

class TestFileSystemCheck extends DirectoryTests {
    function test_check_file_exists(async:Async) {
        FileSystem.check(dummyFileName, Exists, (result, error) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_directory_exists(async:Async) {
        FileSystem.check(directoryName, Exists, (result, error) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_non_existing_file_exists(async:Async) {
        FileSystem.check(nonExistingFile, Exists, (result, error) -> {
            Assert.isNull(error);
            Assert.isFalse(result);

            async.done();
        });
    }

    function test_check_file_is_readable_and_writable(async:Async) {
        FileSystem.check(dummyFileName, Readable | Writable, (result, error) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_file_is_executable(async:Async) {
        FileSystem.check(dummyFileName, Executable, (result, error) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }

    function test_check_directory_is_not_executable(async:Async) {
        FileSystem.check(directoryName, Executable, (result, error) -> {
            Assert.isNull(error);
            Assert.isFalse(result);

            async.done();
        });
    }

    function test_null_path(async:Async) {
        FileSystem.check(null, Executable, (result, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_zero_check(async:Async) {
        FileSystem.check(dummyFileName, cast 0, (result, error) -> {
            Assert.isNull(error);
            Assert.isTrue(result);

            async.done();
        });
    }
}