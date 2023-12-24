package filesystem;

import haxe.exceptions.ArgumentException;
import utils.Directory;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemDeleteDirectory extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.deleteDirectory(null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_deleting_directory(async:Async) {
        ensureDirectoryIsEmpty(directoryName);

        FileSystem.deleteDirectory(directoryName, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(sys.FileSystem.exists(directoryName));
            }

            async.done();
        });
    }

    function test_deleting_populated_directory(async:Async) {
        FileSystem.deleteDirectory(directoryName, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.NotEmpty, (cast error : FsException).type);
                Assert.isTrue(sys.FileSystem.exists(directoryName));
            }

            async.done();
        });
    }

    function test_deleting_non_existing_directory(async:Async) {
        FileSystem.deleteDirectory(nonExistingFile, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_deleting_file(async:Async) {
        FileSystem.deleteDirectory(dummyFileName, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
                Assert.isTrue(sys.FileSystem.exists(dummyFileName));
            }

            async.done();
        });
    }
}