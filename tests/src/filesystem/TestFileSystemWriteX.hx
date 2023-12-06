package filesystem;

import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFileSystemWriteX extends FileOpenTests {   
    function test_write_bytes_to_empty_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(emptyFileName, bytes, WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(emptyFileName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }

    function test_write_string_to_empty_file(async:Async) {
        FileSystem.writeString(emptyFileName, dummyFileData, WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(emptyFileName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }

    function test_write_bytes_to_non_existing_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(nonExistingFile, bytes, WriteX, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(nonExistingFile)));
            }

            async.done();
        });
    }

    function test_write_string_to_non_existing_file(async:Async) {
        FileSystem.writeString(nonExistingFile, dummyFileData, WriteX, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getBytes(nonExistingFile));
            }

            async.done();
        });
    }

    function test_bytes_truncating_existing_file(async:Async) {
        final bytes = Bytes.ofString("lorem");

        FileSystem.writeBytes(dummyFileName, bytes, WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(dummyFileName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }

    function test_string_truncating_existing_file(async:Async) {
        final text = "lorem";

        FileSystem.writeString(dummyFileName, text, WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(dummyFileName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }

    function test_writing_bytes_directory_as_file(async:Async) {
        FileSystem.writeBytes(emptyDirName, Bytes.ofString(dummyFileData), WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(emptyDirName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }

    function test_writing_string_directory_as_file(async:Async) {
        FileSystem.writeString(emptyDirName, dummyFileData, WriteX, (error, _) -> {
            if (Assert.notNull(error)) {
                Assert.equals(emptyDirName, error.path);
                Assert.equals(IoErrorType.FileExists, error.type);
            }

            async.done();
        });
    }
}