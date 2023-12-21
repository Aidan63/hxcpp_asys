package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FsException;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

using StringTools;

class TestFile extends FileOpenTests {
    static inline var TOO_LONG_NAME_LENGTH = 65536;
    static inline var PATH_MAX = 4096;

    function test_null_path(async:Async) {
        FileSystem.openFile(null, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(file);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_name_too_long(async:Async) {
        final bytes = Bytes.alloc(TOO_LONG_NAME_LENGTH);

        bytes.fill(0, TOO_LONG_NAME_LENGTH, 'a'.code);

        final path = bytes.toString();

        FileSystem.openFile(path, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(file);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(path, (cast error : FsException).path);
                Assert.equals(IoErrorType.CustomError("ENAMETOOLONG"), (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_resize_shrink_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                file.resize(5, (error, _) -> {
                    Assert.isNull(error);
    
                    file.close((error, _) -> {
                        Assert.isNull(error);
                        Assert.equals(dummyFileData.substr(0, 5), sys.io.File.getContent(dummyFileName));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_resize_expand_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            
            if (Assert.notNull(file)) {
                file.resize(dummyFileData.length * 2, (error, _) -> {
                    Assert.isNull(error);
    
                    file.close((error, _) -> {
                        Assert.isNull(error);
    
                        final found = sys.io.File.getContent(dummyFileName);
    
                        Assert.equals(dummyFileData, found.substr(0, dummyFileData.length));
                        Assert.equals(dummyFileData.length * 2, found.length);
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_flush_writes(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final data = haxe.Resource.getBytes("long_ipsum");
    
                file.write(data, 0, data.length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(data.length, count);
                });
    
                file.flush((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(0, sys.io.File.getBytes(emptyFileName).compare(data));
    
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

    function test_info(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                file.info((error, stat) -> {
                    Assert.isNull(error);
                    Assert.notNull(stat);
    
                    Assert.isTrue(stat.mode.isFile());
                    Assert.isFalse(stat.mode.isLink());
                    Assert.isFalse(stat.mode.isLink());
    
                    final expected = sys.FileSystem.stat(dummyFileName);
    
                    Assert.equals(expected.size, stat.size);
                    Assert.equals(expected.mode, stat.mode);
                    Assert.equals(expected.atime.getTime() / 1000, stat.accessTime);
                    // Assert.equals(expected.ctime.getTime() / 1000, stat.creationTime);
                    Assert.equals(expected.mtime.getTime() / 1000, stat.modificationTime);
                    Assert.equals(expected.mode, stat.mode);
    
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

    function test_setting_times(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final access   = 1234;
                final modified = 5678;
    
                file.setTimes(access, modified, (error, _) -> {
                    Assert.isNull(error);
    
                    final stat = sys.FileSystem.stat(dummyFileName);
    
                    Assert.equals(access, stat.atime.getTime() / 1000);
                    Assert.equals(modified, stat.mtime.getTime() / 1000);
    
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

    function test_writing_bigger_data(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final data = haxe.Resource.getBytes("long_ipsum");
    
                file.write(data, 0, data.length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(data.length, count);
    
                    file.close((error, _) -> {
                        Assert.isNull(error);
                        Assert.equals(0, sys.io.File.getBytes(emptyFileName).compare(data));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_bigger_data(async:Async) {
        final data = haxe.Resource.getBytes("long_ipsum");

        sys.io.File.saveBytes(emptyFileName, data);

        FileSystem.openFile(emptyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(data.length);
    
                file.read(0, buffer, 0, buffer.length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(data.length, count);
                    Assert.equals(0, buffer.compare(data));
    
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

    function test_write_order(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                {
                    final data = Bytes.ofString(dummyFileData.substr(0, 5));
    
                    file.write(data, 0, data.length, (error, count) -> {
                        Assert.isNull(error);
                        Assert.equals(data.length, count);
                    });
                }
    
                {
                    final data = Bytes.ofString(dummyFileData.substr(5, 8));
    
                    file.write(data, 0, data.length, (error, count) -> {
                        Assert.isNull(error);
                        Assert.equals(data.length, count);
        
                        file.close((error, _) -> {
                            Assert.isNull(error);
                            Assert.equals(dummyFileData, sys.io.File.getContent(emptyFileName));
        
                            async.done();
                        });
                    });
                }
            } else {
                async.done();
            }
        });
    }

    function test_read_order(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final read = Bytes.alloc(dummyFileData.length);
    
                read.fill(0, read.length, 'a'.code);
    
                file.read(0, read, 0, 5, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(5, count);
                    Assert.equals(0, Bytes.ofString(dummyFileData.substr(0, 5).rpad('a', dummyFileData.length)).compare(read));
                });
    
                file.read(5, read, 5, 8, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(8, count);
                    Assert.equals(dummyFileData, read.toString());
    
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

    function test_write_offset_buffer(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final data   = Bytes.ofString(dummyFileData);
                final offset = 2;
                final length = 5;
    
                file.write(data, offset, length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(length, count);
    
                    file.close((error, _) -> {
                        Assert.isNull(error);
                        Assert.equals(dummyFileData.substr(offset, length), sys.io.File.getContent(emptyFileName));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_write_pads_empty_file_when_position_is_non_zero(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final data = Bytes.ofString(dummyFileData);
                final pos  = 2;
    
                file.write(pos, data, 0, data.length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(data.length, count);
    
                    file.close((error, _) -> {
                        final found = sys.io.File.getBytes(emptyFileName);
                        final built = Bytes.alloc(data.length + pos);
                        
                        built.blit(pos, Bytes.ofString(dummyFileData), 0, dummyFileData.length);
    
                        Assert.isNull(error);
                        Assert.equals(0, built.compare(found));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_write_pads_empty_file_when_position_is_non_zero_and_offset_buffer(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Write, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final data   = Bytes.ofString(dummyFileData);
                final pos    = 2;
                final length = 5;
                final offset = 3;
    
                file.write(pos, data, offset, length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(length, count);
    
                    file.close((error, _) -> {
                        final found = sys.io.File.getBytes(emptyFileName);
                        final built = Bytes.alloc(pos + length);
    
                        built.blit(pos, Bytes.ofString(dummyFileData.substr(offset, length)), 0, length);
    
                        Assert.isNull(error);
                        Assert.equals(0, built.compare(found));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_read_into_offset_buffer(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(16);
                final offset = 2;
                final length = 5;
                
                buffer.fill(0, buffer.length, 'a'.code);
    
                file.read(0, buffer, offset, length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(length, count);
    
                    file.close((error, _) -> {
                        final expected = Bytes.alloc(16);
    
                        expected.fill(0, buffer.length, 'a'.code);
                        expected.blit(offset, Bytes.ofString(dummyFileData.substr(0, length)), 0, length);
    
                        Assert.isNull(error);
                        Assert.equals(0, buffer.compare(expected));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_read_from_file_non_zero_position(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(16);
                final pos    = 2;
                final length = 5;
                
                buffer.fill(0, buffer.length, 'a'.code);
    
                file.read(pos, buffer, 0, length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(length, count);
    
                    file.close((error, _) -> {
                        final expected = Bytes.alloc(16);
    
                        expected.fill(0, buffer.length, 'a'.code);
                        expected.blit(0, Bytes.ofString(dummyFileData.substr(pos, length)), 0, length);
    
                        Assert.isNull(error);
                        Assert.equals(0, buffer.compare(expected));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_read_from_file_non_zero_position_into_offset_buffer(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            
            if (Assert.notNull(file)) {
                final buffer = Bytes.alloc(16);
                final pos    = 2;
                final offset = 3;
                final length = 5;
                
                buffer.fill(0, buffer.length, 'a'.code);
    
                file.read(pos, buffer, offset, length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(length, count);
    
                    file.close((error, _) -> {
                        final expected = Bytes.alloc(16);
    
                        expected.fill(0, buffer.length, 'a'.code);
                        expected.blit(offset, Bytes.ofString(dummyFileData.substr(pos, length)), 0, length);
    
                        Assert.isNull(error);
                        Assert.equals(0, buffer.compare(expected));
    
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }
}