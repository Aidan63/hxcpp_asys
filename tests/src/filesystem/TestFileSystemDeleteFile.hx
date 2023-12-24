package filesystem;

import haxe.exceptions.ArgumentException;
import utils.Directory;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemDeleteFile extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.deleteFile(null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_deleting_file(async:Async) {
        FileSystem.deleteFile(dummyFileName, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(sys.FileSystem.exists(dummyFileName));
            } else {
                Assert.isTrue(sys.FileSystem.exists(dummyFileName));
            }


            async.done();
        });
    }

    function test_deleting_non_existing_file(async:Async) {
        FileSystem.deleteFile(nonExistingFile, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_deleting_directory(async:Async) {
        FileSystem.deleteFile(directoryName, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.AccessDenied, (cast error : FsException).type);
            }

            Assert.isTrue(sys.FileSystem.exists(directoryName));

            async.done();
        });
    }
}