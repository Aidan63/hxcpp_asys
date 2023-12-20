package filesystem;

import asys.native.filesystem.FilePath;
import asys.native.filesystem.FileSystem;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;

@:depends(filesystem.TestFilePath, filesystem.TestFileSystemLink)
class TestFileSystemRealPath extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.realPath(null, (error, path) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_make_path_absolute(async:Async) {
        FileSystem.realPath(dummyFileName, (error, path) -> {
            if (Assert.isNull(error)) {
                final expected = FilePath.ofString(Sys.getCwd()).add(dummyFileName).normalize();

                Assert.equals(expected, path);
            }

            async.done();
        });
    }

    function test_resolve_double_dots(async:Async) {
        FileSystem.realPath(FilePath.createPath(directoryName, ".."), (error, path) -> {
            if (Assert.isNull(error)) {
                final expected = FilePath.ofString(Sys.getCwd()).normalize();

                Assert.equals(expected, path);
            }

            async.done();
        });
    }

    function test_resolve_single_dots(async:Async) {
        FileSystem.realPath(FilePath.createPath(Sys.getCwd(), ".", directoryName), (error, path) -> {
            if (Assert.isNull(error)) {
                final expected = FilePath.ofString(Sys.getCwd()).add(directoryName).normalize();

                Assert.equals(expected, path);
            }

            async.done();
        });
    }

    function test_resolve_links(async:Async) {
        FileSystem.link(dummyFileName, linkName, (error, _) -> {
            if (Assert.isNull(error)) {
                FileSystem.realPath(linkName, (error, path) -> {
                    if (Assert.isNull(error)) {
                        final expected = FilePath.ofString(Sys.getCwd()).add(dummyFileName).normalize();
        
                        Assert.equals(expected, path);
                    }
        
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }
}