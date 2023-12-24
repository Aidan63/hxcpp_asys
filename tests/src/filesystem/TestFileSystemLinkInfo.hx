package filesystem;

import asys.native.IoErrorType;
import asys.native.filesystem.FsException;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

@:depends(filesystem.TestFileSystemInfo)
class TestFileSystemLinkInfo extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.linkInfo(null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_non_existing_file(async:Async) {
        FileSystem.linkInfo(nonExistingFile, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_linkInfo_on_non_link(async:Async) {
        FileSystem.linkInfo(dummyFileName, (info, error) -> {
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

    function test_linkInfo(async:Async) {
        FileSystem.link(dummyFileName, linkName, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.linkInfo(linkName, (info, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(info.mode.isFile());
                        Assert.isFalse(info.mode.isDirectory());
                        Assert.isTrue(info.mode.isLink());
                    }
                    
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }
}