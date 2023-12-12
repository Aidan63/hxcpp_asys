package filesystem;

import asys.native.filesystem.FsException;
import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;


class TestFileSystemAppend extends FileOpenTests {
    function test_write_bytes_to_empty_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(emptyFileName, bytes, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(emptyFileName)));
            }

            async.done();
        });
    }

    function test_write_string_to_empty_file(async:Async) {
        FileSystem.writeString(emptyFileName, dummyFileData, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getContent(emptyFileName));
            }

            async.done();
        });
    }

    function test_write_bytes_to_non_existing_file(async:Async) {
        final bytes = Bytes.ofString(dummyFileData);

        FileSystem.writeBytes(nonExistingFile, bytes, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, bytes.compare(sys.io.File.getBytes(nonExistingFile)));
            }

            async.done();
        });
    }

    function test_write_string_to_non_existing_file(async:Async) {
        FileSystem.writeString(nonExistingFile, dummyFileData, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData, sys.io.File.getBytes(nonExistingFile));
            }

            async.done();
        });
    }

    function test_bytes_appending_existing_file(async:Async) {
        final text  = "lorem";
        final bytes = Bytes.ofString(text);

        FileSystem.writeBytes(dummyFileName, bytes, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(0, Bytes.ofString(dummyFileData + text).compare(sys.io.File.getBytes(dummyFileName)));
            }

            async.done();
        });
    }

    function test_string_appending_existing_file(async:Async) {
        final text = "lorem";

        FileSystem.writeString(dummyFileName, text, Append, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.equals(dummyFileData + text, sys.io.File.getContent(dummyFileName));
            }

            async.done();
        });
    }

    function test_writing_bytes_directory_as_file(async:Async) {
        FileSystem.writeBytes(emptyDirName, Bytes.ofString(dummyFileData), Append, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_writing_string_directory_as_file(async:Async) {
        FileSystem.writeString(emptyDirName, dummyFileData, Append, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}