package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenWriteX extends FileOpenTests {
    final nonExistingFile : String;

    final flags : FileOpenFlag<FileWrite>;

    public function new() {
        super();

        nonExistingFile = "does_not_exist.txt";
        flags           = FileOpenFlag.WriteX;
    }

    override function setup() {
        super.setup();
        
        if (sys.FileSystem.exists(nonExistingFile)) {
            sys.FileSystem.deleteFile(nonExistingFile);
        }
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
            Assert.notNull(error);
            Assert.equals(emptyFileName, error.path);
            Assert.equals(IoErrorType.FileExists, error.type);

            async.done();
        });
    }

    function test_fails_to_write_to_existing_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(file);
            Assert.notNull(error);
            Assert.equals(dummyFileName, error.path);
            Assert.equals(IoErrorType.FileExists, error.type);

            async.done();
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.isNull(file);
            Assert.notNull(error);
            Assert.equals(emptyDirName, error.path);
            Assert.equals(IoErrorType.FileExists, error.type);

            async.done();
        });
    }
}