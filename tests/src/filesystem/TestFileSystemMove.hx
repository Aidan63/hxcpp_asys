package filesystem;

import haxe.exceptions.ArgumentException;
import utils.Directory;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestFileSystemMove extends DirectoryTests {
    final newDirectoryName : String;

    public function new() {
        super();

        newDirectoryName = "copied_dir_name";
    }

    override function setup() {
        super.setup();

        ensureDirectoryIsEmpty(newDirectoryName);

        sys.FileSystem.deleteDirectory(newDirectoryName);
    }

    function test_null_src(async:Async) {
        FileSystem.move(null, dummyFileName, false, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("oldPath", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_null_dst(async:Async) {
        FileSystem.move(dummyFileName, null, false, (_, error) -> {
            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("newPath", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_moving_non_existing_object(async:Async) {
        FileSystem.move(nonExistingFile, dummyFileName, true, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(nonExistingFile, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_moving_same_src_and_dst(async:Async) {
        FileSystem.move(dummyFileName, dummyFileName, false, (_, error) -> {
            Assert.notNull(error);

            async.done();
        });
    }

    function test_moving_file_to_new_file_overwrite(async:Async) {
        FileSystem.move(dummyFileName, nonExistingFile, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(sys.FileSystem.exists(dummyFileName));

                if (Assert.isTrue(sys.FileSystem.exists(nonExistingFile))) {
                    Assert.equals(dummyFileData, sys.io.File.getContent(nonExistingFile));
                }
            }

            async.done();
        });
    }

    function test_moving_file_to_new_file_no_overwrite(async:Async) {
        FileSystem.move(dummyFileName, nonExistingFile, false, (_, error) -> {
            if (Assert.isNull(error) && Assert.isTrue(sys.FileSystem.exists(nonExistingFile))) {
                Assert.equals(dummyFileData, sys.io.File.getContent(nonExistingFile));
            }

            async.done();
        });
    }

    function test_moving_file_to_existing_file_overwrite(async:Async) {
        FileSystem.move(emptyFileName, dummyFileName, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.equals("", sys.io.File.getContent(dummyFileName));
            }

            async.done();
        });
    }

    function test_moving_file_to_existing_file_no_overwrite(async:Async) {
        FileSystem.move(emptyFileName, dummyFileName, false, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(emptyFileName, (cast error : FsException).path);
                Assert.equals(IoErrorType.FileExists, (cast error : FsException).type);
                Assert.equals(dummyFileData, sys.io.File.getContent(dummyFileName));
            }

            async.done();
        });
    }

    //

    function test_moving_directory_to_non_existing_directory_no_overwrite(async:Async) {
        FileSystem.move(directoryName, newDirectoryName, false, (_, error) -> {
            Assert.isNull(error);
            Assert.isFalse(sys.FileSystem.exists(directoryName));

            if (Assert.isTrue(sys.FileSystem.exists(newDirectoryName))) {
                final items = sys.FileSystem.readDirectory(newDirectoryName);

                Assert.equals(3, items.length);
                Assert.contains("sub_dir", items);
                Assert.contains("file1.txt", items);
                Assert.contains("file2.txt", items);
            }

            async.done();
        });
    }

    function test_moving_directory_to_non_existing_directory_overwrite(async:Async) {
        FileSystem.move(directoryName, newDirectoryName, true, (_, error) -> {
            Assert.isNull(error);
            Assert.isFalse(sys.FileSystem.exists(directoryName));

            if (Assert.isTrue(sys.FileSystem.exists(newDirectoryName))) {
                final items = sys.FileSystem.readDirectory(newDirectoryName);

                Assert.equals(3, items.length);
                Assert.contains("sub_dir", items);
                Assert.contains("file1.txt", items);
                Assert.contains("file2.txt", items);
            }

            async.done();
        });
    }

    function test_moving_directory_to_existing_empty_directory_no_overwrite(async:Async) {
        sys.FileSystem.createDirectory(newDirectoryName);

        FileSystem.move(directoryName, newDirectoryName, false, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.AccessDenied, (cast error : FsException).type);
                Assert.equals(0, sys.FileSystem.readDirectory(newDirectoryName).length);
            }

            async.done();
        });
    }

    function test_moving_directory_to_existing_empty_directory_overwrite(async:Async) {
        sys.FileSystem.createDirectory(newDirectoryName);

        FileSystem.move(directoryName, newDirectoryName, true, (_, error) -> {
            if (Assert.isNull(error)) {
                Assert.isFalse(sys.FileSystem.exists(directoryName));
    
                final items = sys.FileSystem.readDirectory(newDirectoryName);
    
                Assert.equals(3, items.length);
                Assert.contains("sub_dir", items);
                Assert.contains("file1.txt", items);
                Assert.contains("file2.txt", items);
            }

            async.done();
        });
    }

    function test_moving_directory_to_existing_directory_overwrite(async:Async) {
        sys.FileSystem.createDirectory(newDirectoryName);
        sys.io.File.saveContent(haxe.io.Path.join([ newDirectoryName, "file.txt" ]), dummyFileData);

        FileSystem.move(directoryName, newDirectoryName, true, (_, error) -> {
            if (Assert.isOfType(error, FsException)) {
                Assert.equals(directoryName, (cast error : FsException).path);
                Assert.equals(IoErrorType.AccessDenied, (cast error : FsException).type);

                final items = sys.FileSystem.readDirectory(newDirectoryName);
                Assert.equals(1, items.length);
                Assert.contains("file.txt", items);
            }

            async.done();
        });
    }
}