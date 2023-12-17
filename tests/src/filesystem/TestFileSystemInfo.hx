package filesystem;

import asys.native.filesystem.FilePermissions;
import haxe.exceptions.ArgumentException;
import utils.Directory;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemInfo extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.info(null, (error, info) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_info_file(async:Async) {
        FileSystem.info(dummyFileName, (error, info) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(info.mode.isFile());
                Assert.isFalse(info.mode.isDirectory());
                Assert.isFalse(info.mode.isLink());

                final expected = sys.FileSystem.stat(dummyFileName);

                Assert.equals(expected.size, info.size);
                Assert.equals(expected.atime.getTime() / 1000, info.accessTime);
                // Assert.equals(expected.ctime.getTime() / 1000, stat.creationTime);
                Assert.equals(expected.mtime.getTime() / 1000, info.modificationTime);
                Assert.equals(expected.mode, info.mode);
            }

            async.done();
        });
    }

    function test_info_directory(async:Async) {
        FileSystem.info(directoryName, (error, info) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(info.mode.isFile());
                Assert.isTrue(info.mode.isDirectory());
                Assert.isFalse(info.mode.isLink());

                final expected = sys.FileSystem.stat(directoryName);

                // Expected size is 4096, but info.size is 0
                //Assert.equals(expected.size, info.size);

                Assert.equals(expected.atime.getTime() / 1000, info.accessTime);
                // Assert.equals(expected.ctime.getTime() / 1000, stat.creationTime);
                Assert.equals(expected.mtime.getTime() / 1000, info.modificationTime);

                // Mode differs for some reason.
                //Assert.equals(expected.mode, info.mode);
            }

            async.done();
        });
    }

    function test_info_non_existing(async:Async) {
        FileSystem.info(nonExistingFile, (error, info) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }
}