package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FilePath;
import asys.native.filesystem.FileSystem;

using StringTools;

class TestFileSystemUniqueDirectory extends DirectoryTests {
    function test_create_single_dir_recursive(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, true, (error, path) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_single_dir_non_recursive(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, false, (error, path) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_nested_dir_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "other_dir");

        FileSystem.uniqueDirectory(target, null, null, true, (error, path) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
            }

            async.done();
        });
    }

    function test_create_nested_dir_non_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "other_dir");

        FileSystem.uniqueDirectory(target, null, null, false, (error, path) -> {
            if (Assert.notNull(error)) {
                Assert.isNull(path);
                Assert.equals(target, error.path.substr(0, target.toString().length));
                Assert.equals(IoErrorType.FileNotFound, error.type);
            }

            async.done();
        });
    }

    function test_create_with_prefix(async:Async) {
        final prefix = "HelloWorld";

        FileSystem.uniqueDirectory(directoryName, prefix, null, true, (error, path) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(path));
                Assert.isTrue(new haxe.io.Path(path).file.startsWith(prefix));
            }

            async.done();
        });
    }

    function test_create_multiple_unique_dirs(async:Async) {
        FileSystem.uniqueDirectory(directoryName, null, null, true, (error, path1) -> {
            if (Assert.isNull(error)) {
                FileSystem.uniqueDirectory(directoryName, null, null, true, (error, path2) -> {
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