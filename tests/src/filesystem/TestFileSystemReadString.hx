package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFileSystemReadString extends FileOpenTests {
    function test_reading_file(async:Async) {
        FileSystem.readString(dummyFileName, (error, string) -> {
            Assert.isNull(error);
            Assert.equals(string, dummyFileData);

            async.done();
        });
    }

    function test_reading_empty_file(async:Async) {
        FileSystem.readString(emptyFileName, (error, string) -> {
            Assert.isNull(error);
            Assert.equals("", string);

            async.done();
        });
    }

    function test_reading_big_file(async:Async) {
        final data = haxe.Resource.getBytes("long_ipsum");

        sys.io.File.saveBytes(emptyFileName, data);

        FileSystem.readString(emptyFileName, (error, string) -> {
            Assert.isNull(error);
            Assert.equals(data.toString(), string);

            async.done();
        });
    }

    function test_reading_non_existant_file(async:Async) {
        FileSystem.readString("does_not_exist.txt", (error, bytes) -> {
            Assert.isNull(bytes);

            if (Assert.notNull(error)) {
                Assert.equals("does_not_exist.txt", error.path);
                Assert.equals(IoErrorType.FileNotFound, error.type);
            }

            async.done();
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.readString(emptyDirName, (error, bytes) -> {
            Assert.isNull(bytes);

            if (Assert.notNull(error)) {
                Assert.equals(emptyDirName, error.path);
                Assert.equals(IoErrorType.IsDirectory, error.type);
            }

            async.done();
        });
    }
}