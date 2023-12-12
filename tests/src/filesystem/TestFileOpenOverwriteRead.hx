package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.File;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenOverwriteRead extends FileOpenTests {
    final flags : FileOpenFlag<File>;

    public function new() {
        super();

        flags = FileOpenFlag.OverwriteRead;
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

    function test_will_not_truncate_existing_file_when_writing(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "World";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(text + dummyFileData.substr(text.length), sys.io.File.getContent(dummyFileName));

                    async.done();
                });
            });
        });
    }

    
    function test_will_not_truncate_existing_file_when_reading(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
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

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.notNull(file);
            Assert.isNull(error);
            
            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(0, buffer, 0, buffer.length, (error, count) -> {
                if (Assert.isOfType(error, FsException)) {
                    Assert.equals(emptyDirName, (cast error : FsException).path);
                    Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
                }
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.notNull(file);
            Assert.isNull(error);
            
            final buffer = Bytes.alloc(8);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                if (Assert.isOfType(error, FsException)) {
                    Assert.equals(emptyDirName, (cast error : FsException).path);
                    Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
                }
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }
}