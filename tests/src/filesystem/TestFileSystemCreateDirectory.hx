package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FilePath;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

import utils.Directory;

class TestFileSystemCreateDirectory extends DirectoryTests {
    override function setup() {
        ensureDirectoryIsEmpty(directoryName);

        sys.FileSystem.deleteDirectory(directoryName);
    }

    function test_null_path(async:Async) {
        FileSystem.createDirectory(null, null, true, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_create_single_dir_recursive(async:Async) {
        FileSystem.createDirectory(directoryName, null, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(directoryName));
            }

            async.done();
        });
    }

    function test_create_single_dir_non_recursive(async:Async) {
        FileSystem.createDirectory(directoryName, null, false, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(directoryName));
            }

            async.done();
        });
    }

    function test_create_nested_dir_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "sub_dir");

        FileSystem.createDirectory(target, null, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(target));
            }

            async.done();
        });
    }

    function test_create_nested_dir_non_recursive(async:Async) {
        final target = FilePath.createPath(directoryName, "sub_dir");

        FileSystem.createDirectory(target, null, false, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(target, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
                Assert.isFalse(sys.FileSystem.exists(target));
            }

            async.done();
        });
    }

    function test_creating_already_existing_directory(async:Async) {
        sys.FileSystem.createDirectory(directoryName);

        FileSystem.createDirectory(directoryName, null, true, (_, error) -> {
            Assert.isNull(error);

            async.done();
        });
    }

    function test_multi_stage_directory_creation(async:Async) {
        sys.FileSystem.createDirectory(directoryName);

        final target = FilePath.createPath(directoryName, "some", "sub_dir");

        FileSystem.createDirectory(target, null, false, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(target, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_multi_stage_recursive_directory_creation(async:Async) {
        sys.FileSystem.createDirectory(directoryName);

        final target = FilePath.createPath(directoryName, "some", "sub_dir");

        FileSystem.createDirectory(target, null, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.isDirectory(target));
            }
            
            async.done();
        });
    }
}