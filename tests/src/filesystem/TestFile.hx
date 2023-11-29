package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFile extends FileOpenTests {
    static inline var TOO_LONG_NAME_LENGTH = 65536;
    static inline var PATH_MAX = 4096;

    function test_name_too_long(async:Async) {
        final bytes = Bytes.alloc(TOO_LONG_NAME_LENGTH);

        bytes.fill(0, TOO_LONG_NAME_LENGTH, 'a'.code);

        final path = bytes.toString();

        FileSystem.openFile(path, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(file);
            Assert.notNull(error);
            Assert.equals(path, error.path);
            Assert.equals(IoErrorType.CustomError("ENAMETOOLONG"), error.type);

            async.done();
        });
    }

    function test_resize_shrink_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            file.resize(5, (error, _) -> {
                Assert.isNull(error);

                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(dummyFileData.substr(0, 5), sys.io.File.getContent(dummyFileName));

                    async.done();
                });
            });
        });
    }

    function test_resize_expand_file(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

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
        });
    }

    function test_flush_writes(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(buffer.length, count);
                
                file.flush((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(text, sys.io.File.getContent(emptyFileName));

                    file.close((error, _) -> {
                        Assert.isNull(error);

                        async.done();
                    });
                });
            });
        });
    }

    function test_info(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

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
        });
    }

    function test_setting_times(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.ReadWrite, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

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
        });
    }
}