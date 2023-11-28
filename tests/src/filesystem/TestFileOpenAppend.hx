package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenAppend extends FileOpenTests
{
    final nonExistingFile : String;

    final flags : FileOpenFlag<FileAppend>;

    public function new() {
        super();

        nonExistingFile = "does_not_exist.txt";
        flags           = FileOpenFlag.Append;
    }

    function teardown() {
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

            file.write(buffer, 0, buffer.length, (error, count) -> {
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

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(text, sys.io.File.getContent(emptyFileName));

                    async.done();
                });
            });
        });
    }

    function test_can_append_to_existing_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "Universe!";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(dummyFileData + text, sys.io.File.getContent(dummyFileName));

                    async.done();
                });
            });
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.notNull(error);
                Assert.equals(emptyDirName, error.path);
                Assert.equals(IoErrorType.IsDirectory, error.type);
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }
}