package filesystem;

import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;
import haxe.io.Bytes;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;

class TestFileSystemResize extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.resize(null, 10, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_negative_size(async:Async) {
        FileSystem.resize(dummyFileName, -10, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("newSize", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_non_existing_file(async:Async) {
        final size = 10;

        FileSystem.resize(nonExistingFile, size, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, sys.io.File.getBytes(nonExistingFile).compare(Bytes.alloc(size)));
            }

            async.done();
        });
    }

    function test_directory(async:Async) {
        FileSystem.resize(directoryName, 10, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_resize_to_zero(async:Async) {
        FileSystem.resize(dummyFileName, 0, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, sys.FileSystem.stat(dummyFileName).size);
            }

            async.done();
        });
    }

    function test_shrink_file(async:Async) {
        final newSize  = 5;
        final expected = Bytes.ofString(dummyFileData.substr(0, newSize));

        FileSystem.resize(dummyFileName, newSize, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, sys.io.File.getBytes(dummyFileName).compare(expected));
            }

            async.done();
        });
    }

    function test_expand_file(async:Async) {
        final newSize  = dummyFileData.length * 2;
        final expected = Bytes.alloc(newSize);

        expected.blit(0, Bytes.ofString(dummyFileData), 0, dummyFileData.length);

        FileSystem.resize(dummyFileName, newSize, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, sys.io.File.getBytes(dummyFileName).compare(expected));
            }

            async.done();
        });
    }
}