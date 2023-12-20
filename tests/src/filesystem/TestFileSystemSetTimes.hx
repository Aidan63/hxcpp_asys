package filesystem;

import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;

@:depends(filesystem.TestFileSystemInfo)
class TestFileSystemSetTimes extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.setTimes(null, 0, 0, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_negative_access_time(async:Async) {
        FileSystem.setTimes(dummyFileName, -1, 0, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("accessTime", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_negative_modification_time(async:Async) {
        FileSystem.setTimes(dummyFileName, 0, -1, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("modificationTime", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_modifying_directory_time(async:Async) {
        FileSystem.setTimes(directoryName, 100, 200, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.IsDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_modifying_file_time(async:Async) {
        final accessTime       = 100;
        final modificationTime = 200;

        FileSystem.setTimes(dummyFileName, accessTime, modificationTime, (error, _) -> {
            if (Assert.isNull(error)) {
                FileSystem.info(dummyFileName, (error, stat) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(accessTime, stat.accessTime);
                        Assert.equals(modificationTime, stat.modificationTime);
                    }

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }
}