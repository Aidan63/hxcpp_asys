package filesystem;

import haxe.io.Bytes;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemWriteX extends FileOpenTests {
    function test_bytes_null_path(async:Async) {
        FileSystem.writeBytes(null, null, WriteX, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_bytes_null_data(async:Async) {
        FileSystem.writeBytes(emptyFileName, null, WriteX, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("data", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_string_null_path(async:Async) {
        FileSystem.writeString(null, dummyFileData, WriteX, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_string_null_data(async:Async) {
        FileSystem.writeString(emptyFileName, null, WriteX, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("text", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_write_bytes_to_empty_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(emptyFileName, bytes, WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_write_string_to_empty_file(async:Async) {
        FileSystem.writeString(emptyFileName, dummyFileData, WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_write_bytes_to_non_existing_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(nonExistingFile, bytes, WriteX, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(nonExistingFile)));
            }

            async.done();
        });
    }

    function test_write_string_to_non_existing_file(async:Async) {
        FileSystem.writeString(nonExistingFile, dummyFileData, WriteX, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getContent(nonExistingFile));
            }

            async.done();
        });
    }

    function test_bytes_truncating_existing_file(async:Async) {
        final bytes = Bytes.ofString("lorem");

        FileSystem.writeBytes(dummyFileName, bytes, WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_string_truncating_existing_file(async:Async) {
        final text = "lorem";

        FileSystem.writeString(dummyFileName, text, WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_writing_bytes_directory_as_file(async:Async) {
        FileSystem.writeBytes(emptyDirName, Bytes.ofString(dummyFileData), WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_writing_string_directory_as_file(async:Async) {
        FileSystem.writeString(emptyDirName, dummyFileData, WriteX, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }
}