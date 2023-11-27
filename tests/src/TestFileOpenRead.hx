import haxe.io.Bytes;
import asys.native.IoErrorType;
import asys.native.filesystem.FileOpenFlag;
import asys.native.filesystem.FileSystem;
import utest.Test;
import utest.Assert;
import utest.Async;

class TestFileOpenRead extends Test {
    final emptyFileName : String;
    final dummyFileName : String;
    final dummyFileData : String;
    final emptyDirName : String;

    public function new() {
        super();

        emptyFileName = "empty.txt";
        dummyFileName = "dummy.txt";
        dummyFileData = "Hello, World!";
        emptyDirName  = "empty";
    }

    function setup() {
        sys.io.File.saveContent(emptyFileName, "");
        sys.io.File.saveContent(dummyFileName, dummyFileData);
        sys.FileSystem.createDirectory(emptyDirName);
    }

    function test_fails_to_open_non_existing_file(async:Async) {
        final nonExistingFile = "does_not_exist.txt";

        FileSystem.openFile(nonExistingFile, FileOpenFlag.Read, (error, file) -> {
            Assert.notNull(error);
            Assert.equals(nonExistingFile, error.path);
            Assert.equals(IoErrorType.FileNotFound, error.type);

            async.done();
        });
    }

    function test_can_read_empty_file(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 8;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(0, count);
                Assert.equals(0, buffer.compare(Bytes.alloc(size)));
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }

    function test_can_read_file_contents(async:Async) {
        FileSystem.openFile(dummyFileName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 32;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(dummyFileData.length, count);
                Assert.equals(0, buffer.sub(0, count).compare(Bytes.ofString(dummyFileData)));
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }

    function test_reading_directory_as_file(async:Async) {
        FileSystem.openFile(emptyDirName, FileOpenFlag.Read, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final size   = 32;
            final buffer = Bytes.alloc(size);

            file.read(0, buffer, 0, buffer.length, (error, count) -> {
                Assert.notNull(error);
                Assert.equals(emptyDirName, error.path);
                Assert.equals(IoErrorType.IsDirectory, error.type);
                
                file.close((error, _) -> {
                    Assert.isNull(error);

                    async.done();
                });
            });
        });
    }
}
