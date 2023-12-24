package filesystem;

import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;

class TestFileSystemCopyFile extends DirectoryTests {
    function test_null_source(async:Async) {
        FileSystem.copyFile(null, dummyFileName, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("source", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_null_destination(async:Async) {
        FileSystem.copyFile(dummyFileName, null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("destination", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_non_existing_source(async:Async) {
        FileSystem.copyFile(nonExistingFile, dummyFileName, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_copying_file_no_overwrite_to_non_existing_destination(async:Async) {
        FileSystem.copyFile(dummyFileName, nonExistingFile, false, (_, error) -> {
            if (Assert.isNull(error)) {
                if (Assert.isTrue(sys.FileSystem.exists(nonExistingFile))) {
                    Assert.equals(0, sys.io.File.getBytes(dummyFileName).compare(sys.io.File.getBytes(nonExistingFile)));
                }
            }

            async.done();
        });
    }

    function test_copying_file_no_overwrite(async:Async) {
        FileSystem.copyFile(dummyFileName, emptyFileName, false, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_copying_file_overwrite(async:Async) {
        FileSystem.copyFile(dummyFileName, emptyFileName, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getContent(dummyFileName));
                Assert.equals(dummyFileData, sys.io.File.getContent(emptyFileName));
            }

            async.done();
        });
    }

    function test_copying_directory(async:Async) {
        FileSystem.copyFile(directoryName, emptyFileName, true, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_copying_to_directory(async:Async) {
        FileSystem.copyFile(dummyFileName, directoryName, true, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}