package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.File;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenWriteRead extends FileOpenTests {
    final flags : FileOpenFlag<File>;

    public function new() {
        super();

        flags = FileOpenFlag.WriteRead;
    }

    function test_write_to_non_existing_file(async:Async) {
        FileSystem.openFile(nonExistingFile, flags, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
                        Assert.equals(text, sys.io.File.getContent(nonExistingFile));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
                        Assert.equals(text, sys.io.File.getContent(emptyFileName));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_can_read_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final size   = 8;
                final buffer = Bytes.alloc(size);
    
                file.read(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(0, count);
                    Assert.equals(0, buffer.compare(Bytes.alloc(size)));
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_can_read_truncated_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final size   = 8;
                final buffer = Bytes.alloc(size);
    
                file.read(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(0, count);
                    Assert.equals(0, buffer.compare(Bytes.alloc(size)));
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_will_truncate_existing_file(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
                        Assert.equals(text, sys.io.File.getContent(dummyFileName));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (file, error) -> {
            Assert.isNull(file);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyDirName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }
}