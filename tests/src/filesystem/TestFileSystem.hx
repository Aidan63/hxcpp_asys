package filesystem;

import asys.native.filesystem.FilePermissions;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileSystem extends FileOpenTests {
    function test_temp_file(async:Async) {
        FileSystem.tempFile((error, file1) -> {
            Assert.isNull(error);

            if (Assert.notNull(file1)) {
                // TODO : Could we have a better test for temp file names?
                if (Assert.notNull(file1.path)) {
                    Assert.isTrue(file1.path.length > 0);
                }

                // Check permissions
                // On Windows, chmod can only modify S_IWUSR (_S_IWRITE) bit,
                // so only testing for the specified flags.
                final mode = 666;
                final stat = sys.FileSystem.stat(file1.path);
                if (Sys.systemName() == "Windows") {
                    Assert.equals(0, (stat.mode & 777) & mode);
                } else {
                    Assert.isTrue((stat.mode & 777) == mode);
                }

                // Ensure we can write to the file.
                final buffer = Bytes.ofString(dummyFileData);

                file1.write(0, buffer, 0, buffer.length, (error, count) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);

                    // Open another temp file to check if they have different names.
                    FileSystem.tempFile((error, file2) -> {
                        Assert.isNull(error);

                        if (Assert.notNull(file2)) {
                            Assert.notEquals(file1.path, file2.path);

                            file2.close((error, _) -> {
                                Assert.isNull(error);

                                file1.close((error, _) -> {
                                    Assert.isNull(error);
                    
                                    async.done();
                                });
                            });

                        } else {
                            file1.close((error, _) -> {
                                Assert.isNull(error);
                
                                async.done();
                            });
                        }
                    });
                });
            } else {
                async.done();
            }
        });
    }
}