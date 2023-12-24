package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemReadString extends FileOpenTests {
    function test_null_path(async:Async) {
        FileSystem.readString(null, (string, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_reading_file(async:Async) {
        FileSystem.readString(dummyFileName, (string, error) -> {
            Assert.isNull(error);
            Assert.equals(string, dummyFileData);

            async.done();
        });
    }

    function test_reading_empty_file(async:Async) {
        FileSystem.readString(emptyFileName, (string, error) -> {
            Assert.isNull(error);
            Assert.equals("", string);

            async.done();
        });
    }

    function test_reading_big_file(async:Async) {
        final data = haxe.Resource.getBytes("long_ipsum");

        sys.io.File.saveBytes(emptyFileName, data);

        FileSystem.readString(emptyFileName, (string, error) -> {
            Assert.isNull(error);
            Assert.equals(data.toString(), string);

            async.done();
        });
    }

    function test_reading_non_existant_file(async:Async) {
        FileSystem.readString("does_not_exist.txt", (bytes, error) -> {
            Assert.isNull(bytes);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals("does_not_exist.txt", (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.readString(emptyDirName, (bytes, error) -> {
            Assert.isNull(bytes);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}