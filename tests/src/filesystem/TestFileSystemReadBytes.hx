package filesystem;

import haxe.exceptions.ArgumentException;
import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFileSystemReadBytes extends FileOpenTests {
    function test_null_path(async:Async) {
        FileSystem.readBytes(null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_reading_file(async:Async) {
        FileSystem.readBytes(dummyFileName, (bytes, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(bytes)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(dummyFileName)));
            }

            async.done();
        });
    }

    function test_reading_empty_file(async:Async) {
        FileSystem.readBytes(emptyFileName, (bytes, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(bytes)) {
                Assert.equals(0, bytes.length);
            }

            async.done();
        });
    }

    function test_reading_big_file(async:Async) {
        final data = haxe.Resource.getBytes("long_ipsum");

        sys.io.File.saveBytes(emptyFileName, data);

        FileSystem.readBytes(emptyFileName, (bytes, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(bytes)) {
                Assert.equals(0, bytes.compare(data));
            }

            async.done();
        });
    }

    function test_reading_non_existant_file(async:Async) {
        FileSystem.readBytes("does_not_exist.txt", (bytes, error) -> {
            Assert.isNull(bytes);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals("does_not_exist.txt", (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.readBytes(emptyDirName, (bytes, error) -> {
            Assert.isNull(bytes);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}