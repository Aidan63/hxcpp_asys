package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

class TestFileSystemIsDirectory extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.isDirectory(null, (result, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_directory(async:Async) {
        FileSystem.isDirectory(directoryName, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(result);
            }

            async.done();
        });
    }

    function test_file(async:Async) {
        FileSystem.isDirectory(dummyFileName, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_non_existing_file(async:Async) {
        FileSystem.isDirectory(nonExistingFile, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }
}