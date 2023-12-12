package filesystem;

import asys.native.filesystem.FsException;
import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFileSystemWrite extends FileOpenTests {   
    function test_write_bytes_to_empty_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(emptyFileName, bytes, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(emptyFileName)));
            }

            async.done();
        });
    }

    function test_write_string_to_empty_file(async:Async) {
        FileSystem.writeString(emptyFileName, dummyFileData, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getContent(emptyFileName));
            }

            async.done();
        });
    }

    function test_write_bytes_to_non_existing_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(nonExistingFile, bytes, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(nonExistingFile)));
            }

            async.done();
        });
    }

    function test_write_string_to_non_existing_file(async:Async) {
        FileSystem.writeString(nonExistingFile, dummyFileData, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getBytes(nonExistingFile));
            }

            async.done();
        });
    }

    function test_bytes_truncating_existing_file(async:Async) {
        final bytes = Bytes.ofString("lorem");

        FileSystem.writeBytes(dummyFileName, bytes, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(dummyFileName)));
            }

            async.done();
        });
    }

    function test_string_truncating_existing_file(async:Async) {
        final text = "lorem";

        FileSystem.writeString(dummyFileName, text, Write, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(text, sys.io.File.getContent(dummyFileName));
            }

            async.done();
        });
    }

    function test_writing_bytes_directory_as_file(async:Async) {
        FileSystem.writeBytes(emptyDirName, Bytes.ofString(dummyFileData), Write, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_writing_string_directory_as_file(async:Async) {
        FileSystem.writeString(emptyDirName, dummyFileData, Write, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}