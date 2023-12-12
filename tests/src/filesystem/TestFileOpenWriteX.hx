package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenWriteX extends FileOpenTests {
    final flags : FileOpenFlag<FileWrite>;

    public function new() {
        super();

        flags = FileOpenFlag.WriteX;
    }

    function test_write_to_non_existing_file(async:Async) {
        FileSystem.openFile(nonExistingFile, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(text, sys.io.File.getContent(nonExistingFile));

                    async.done();
                });
            });
        });
    }

    function test_fails_to_write_to_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (error, file) -> {
            Assert.isNull(file);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_fails_to_write_to_existing_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(file);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(dummyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.isNull(file);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
            }

            async.done();
        });
    }
}