package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenReadWrite extends FileOpenTests {
    function test_fails_to_open_non_existing_file(async:Async) {
        final nonExistingFile = "does_not_exist.txt";

        FileSystem.openFile(nonExistingFile, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.notNull(error);
            Assert.equals(nonExistingFile, error.path);
            Assert.equals(IoErrorType.FileNotFound, error.type);

            async.done();
        });
    }

    function test_can_read_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 8;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(0, count);
                Assert.equals(0, buffer.compare(Bytes.alloc(size)));
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
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

    function test_can_replace_data_in_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "Universe!";
            final buffer = Bytes.ofString(text);

            file.write(7, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals("Hello, Universe!", sys.io.File.getContent(dummyFileName));

                    async.done();
                });
            });
        });
    }

    function test_can_read_file_contents(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 32;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(dummyFileData.length, count);
                Assert.equals(0, buffer.sub(0, count).compare(Bytes.ofString(dummyFileData)));
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 32;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
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

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
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