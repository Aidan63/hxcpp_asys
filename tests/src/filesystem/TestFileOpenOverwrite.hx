package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileOpenOverwrite extends FileOpenTests {
    final flags : FileOpenFlag<FileWrite>;

    public function new() {
        super();

        flags = FileOpenFlag.Overwrite;
    }

    function test_write_to_non_existing_file(async:Async) {
        FileSystem.openFile(nonExistingFile, flags, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
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
            } else {
                async.done();
            }
        });
    }

    function test_can_write_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, flags, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
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
            } else {
                async.done();
            }
        });
    }

    function test_will_not_truncate_existing_file_when_writing(async:Async) {
        FileSystem.openFile(dummyFileName, flags, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
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
            } else {
                async.done();
            }
        });
    }

    function test_writing_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, flags, (error, file) -> {
            Assert.notNull(file);

            if (Assert.isNull(error)) {
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
            } else {
                async.done();
            }
        });
    }
}