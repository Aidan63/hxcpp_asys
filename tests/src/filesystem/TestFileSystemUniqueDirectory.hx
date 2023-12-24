package filesystem;

import asys.native.filesystem.FsException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FilePath;
import asys.native.filesystem.FileSystem;

using StringTools;

class TestFileSystemUniqueDirectory extends DirectoryTests {
    function test_create_single_dir_recursive(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, true, (path, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_single_dir_non_recursive(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, false, (path, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_nested_dir_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "other_dir");

        FileSystem.uniqueDirectory(target, null, null, true, (path, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_nested_dir_non_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "other_dir");

        FileSystem.uniqueDirectory(target, null, null, false, (path, error) -> {
            Assert.isNull(path);
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(target, (cast error : FsException).path.substr(0, target.toString().length));
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_create_with_prefix(async:Async) {
        final prefix = "HelloWorld";

        FileSystem.uniqueDirectory(directoryName, prefix, null, true, (path, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
                Assert.isTrue(new haxe.io.Path(path).file.startsWith(prefix));
            }

            async.done();
        });
    }

    function test_create_multiple_unique_dirs(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, true, (path1, error) -> {
            if (Assert.isNull(error)) {
                FileSystem.uniqueDirectory(directoryName, null, null, true, (path2, error) -> {
                    if (Assert.isNull(error)) {
                        Assert.notEquals(path1, path2);
                    }

                    async.done();
                });
            } else {
                async.done();
            }

        });
    }
}