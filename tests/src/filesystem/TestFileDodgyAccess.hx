package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileDodgyAccess extends FileOpenTests {
    function test_writing_null_buffer(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                file.write(0, null, 0, 8, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_writing_negative_position(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(-1, buffer, 0, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_writing_negative_offset(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, -1, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_writing_wrong_buffer_offset(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, buffer.length + 1, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_writing_too_long_buffer_length(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
    
                file.write(0, buffer, 0, buffer.length * 2, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(count, buffer.length);
    
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

    function test_writing_too_long_buffer_length_due_to_offset(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final text   = "lorem ipsum";
                final buffer = Bytes.ofString(text);
                final offset = 5;
    
                file.write(0, buffer, offset, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(count, buffer.length - offset);
    
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

    function test_reading_null_buffer(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                file.read(0, null, 0, 8, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_reading_negative_position(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(dummyFileData.length);
    
                file.read(-1, buffer, 0, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_reading_negative_offset(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(dummyFileData.length);
    
                file.read(0, buffer, -1, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_reading_wrong_buffer_offset(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(dummyFileData.length);
    
                file.read(0, buffer, buffer.length + 1, buffer.length, (count, error) -> {
                    Assert.notNull(error);
    
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

    function test_reading_too_long_buffer_length(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(dummyFileData.length);
    
                file.read(0, buffer, 0, buffer.length * 2, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);
    
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

    function test_reading_too_long_buffer_length_due_to_offset(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(dummyFileData.length);
                final offset = 5;
    
                file.read(0, buffer, offset, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length - offset, count);
    
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