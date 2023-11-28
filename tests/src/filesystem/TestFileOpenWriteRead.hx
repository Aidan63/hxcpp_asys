package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.File;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenWriteRead extends FileOpenTests {
    final nonExistingFile : String;

    final flags : FileOpenFlag<File>;

    public function new() {
        super();

        nonExistingFile = "does_not_exist.txt";
        flags           = FileOpenFlag.WriteRead;
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

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (error, file) -> {
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

    function test_can_read_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (error, file) -> {
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

    function test_can_read_truncated_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
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

    function test_will_truncate_existing_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(text, sys.io.File.getContent(dummyFileName));

                    async.done();
                });
            });
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.isNull(file);
            Assert.notNull(error);
            Assert.equals(emptyDirName, error.path);
            Assert.equals(IoErrorType.IsDirectory, error.type);

            async.done();
        });
    }
}