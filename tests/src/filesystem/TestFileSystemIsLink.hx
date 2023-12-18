package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

@:depends(filesystem.TestFileSystemLink)
class TestFileSystemIsLink extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.isLink(null, (error, result) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_non_existant_file(async:Async) {
        FileSystem.isLink(nonExistingFile, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_non_link_file(async:Async) {
        FileSystem.isLink(dummyFileName, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_non_link_directory(async:Async) {
        FileSystem.isLink(directoryName, (error, result) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_symlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, SymLink, (error, _) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (error, result) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(result);
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
        FileSystem.link(directoryName, linkName, SymLink, (error, _) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (error, result) -> {
                    if (Assert.isNull(error)) {
                        Assert.isTrue(result);
                    }

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_hardlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, HardLink, (error, _) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (error, result) -> {
                    if (Assert.isNull(error)) {
                        Assert.isFalse(result);
                    }

                    async.done();
                });
            } else {
                async.done();
            }
        });
    }
}