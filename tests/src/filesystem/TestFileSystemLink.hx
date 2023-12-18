package filesystem;

import asys.native.IoErrorType;
import asys.native.filesystem.FsException;
import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;

class TestFileSystemLink extends DirectoryTests {   
    function test_null_target(async:Async) {
        FileSystem.link(null, dummyFileName, SymLink, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("target", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_null_path(async:Async) {
        FileSystem.link(dummyFileName, null, SymLink, (error, _) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_symlink_to_non_existing_target(async:Async) {
        FileSystem.link(nonExistingFile, linkName, SymLink, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.exists(linkName));
            }

            async.done();
        });
    }

    function test_symlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, SymLink, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.exists(linkName));
            }

            async.done();
        });
    }

    function test_symlink_to_directory(async:Async) {
        FileSystem.link(directoryName, linkName, SymLink, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.exists(linkName));
            }

            async.done();
        });
    }

    function test_hardlink_to_non_existing_target(async:Async) {
        FileSystem.link(nonExistingFile, linkName, HardLink, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(linkName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            Assert.isFalse(sys.FileSystem.exists(linkName));

            async.done();
        });
    }

    function test_hardlink_to_file(async:Async) {
        FileSystem.link(dummyFileName, linkName, HardLink, (error, _) -> {
            if (Assert.isNull(error)) {
                Assert.isTrue(sys.FileSystem.exists(linkName));
            }

            async.done();
        });
    }

    function test_hardlink_to_directory(async:Async) {
        FileSystem.link(directoryName, linkName, HardLink, (error, _) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(linkName, (cast error : FsException).path);
                Assert.equals(IoErrorType.AccessDenied, (cast error : FsException).type);
                Assert.isFalse(sys.FileSystem.exists(linkName));
            }

            async.done();
        });
    }
}