package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

class TestFileSystemIsFile extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.isFile(null, (error, result) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_directory(async:Async) {
        FileSystem.isFile(directoryName, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_file(async:Async) {
        FileSystem.isFile(dummyFileName, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(result);
            }

            async.done();
        });
    }

    function test_non_existing_file(async:Async) {
        FileSystem.isFile(nonExistingFile, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }
}