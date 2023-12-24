package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenReadWrite extends FileOpenTests {
    function test_fails_to_open_non_existing_file(async:Async) {
        final nonExistingFile = "does_not_exist.txt";

        FileSystem.openFile(nonExistingFile, FileOpenFlag.ReadWrite, (file, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_can_read_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.ReadWrite, (file, error) -> {
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

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.ReadWrite, (file, error) -> {
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

    function test_can_replace_data_in_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "Universe!";
                final buffer = Bytes.ofString(text);
    
                file.write(7, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);
                    
                    file.close((_, error) -> {
                        Assert.isNull(error);
                        Assert.equals("Hello, Universe!", sys.io.File.getContent(dummyFileName));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_can_read_file_contents(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final size   = 32;
                final buffer = Bytes.alloc(size);
    
                file.read(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(dummyFileData.length, count);
                    Assert.equals(0, buffer.sub(0, count).compare(Bytes.ofString(dummyFileData)));
                    
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

    function test_reading_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final size   = 32;
                final buffer = Bytes.alloc(size);
    
                file.read(0, buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, FsException)) {
                        Assert.equals(emptyDirName, (cast error : FsException).path);
                        Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
                    }
                    
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

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, FileOpenFlag.ReadWrite, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, 0, buffer.length, (count, error) -> {
                    if (Assert.isOfType(error, FsException)) {
                        Assert.equals(emptyDirName, (cast error : FsException).path);
                        Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
                    }
                    
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
}