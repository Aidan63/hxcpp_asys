package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

@:depends(filesystem.TestFileSystemLink)
class TestFileSystemIsLink extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.isLink(null, (result, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_non_existant_file(async:Async) {
        FileSystem.isLink(nonExistingFile, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_non_link_file(async:Async) {
        FileSystem.isLink(dummyFileName, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_non_link_directory(async:Async) {
        FileSystem.isLink(directoryName, (result, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(result);
            }

            async.done();
        });
    }

    function test_symlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, SymLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (result, error) -> {
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
        FileSystem.link(directoryName, linkName, SymLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (result, error) -> {
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
        FileSystem.link(dummyFileName, linkName, HardLink, (_, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.isLink(linkName, (result, error) -> {
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