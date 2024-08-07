package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

@:depends(filesystem.TestFileSystemLink)
class TestFileSystemReadLink extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.readLink(null, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_symlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, SymLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.readLink(linkName, (path, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(dummyFileName, path);
                    }

                    async.done();
                });
            }
            else {
                async.done();
            }
        });
    }

    function test_symlink_to_directory(async:Async) {
        FileSystem.link(directoryName, linkName, SymLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.readLink(linkName, (path, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.equals(directoryName, path);
                    }

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_hardlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, HardLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.readLink(linkName, (path, error) -> {
                    Assert.notNull(error);

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }
}