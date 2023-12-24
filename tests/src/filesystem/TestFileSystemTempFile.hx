package filesystem;

import cpp.asys.FilePathExtras;
import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;
import haxe.io.Bytes;

class TestFileSystemTempFile extends FileOpenTests {
    function test_opening_temp_file(async:Async) {
        FileSystem.tempFile((file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                file.close((_, error) -> {
                    Assert.isNull(error);
    
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_temp_file_name(async:Async) {
        FileSystem.tempFile((file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {

                // TODO : Could we have a better test for temp file names?
                if (Assert.notNull(file.path)) {
                    Assert.isFalse(FilePathExtras.empty(file.path));
                }

                file.close((_, error) -> {
                    Assert.isNull(error);
    
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_temp_file_permissions(async:Async) {
        FileSystem.tempFile((file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file) && Assert.notNull(file.path)) {
                // On Windows, chmod can only modify S_IWUSR (_S_IWRITE) bit,
                // so only testing for the specified flags.
                final mode = 666;
                final stat = sys.FileSystem.stat(file.path);
                if (Sys.systemName() == "Windows") {
                    Assert.equals(0, (stat.mode & 777) & mode);
                } else {
                    Assert.isTrue((stat.mode & 777) == mode);
                }

                file.close((_, error) -> {
                    Assert.isNull(error);
    
                    async.done();
                });
            } else {
                async.done();
            }
        });
    }

    function test_writing_to_temp_file(async:Async) {
        FileSystem.tempFile((file, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file)) {
                final buffer = Bytes.ofString(dummyFileData);

                file.write(0, buffer, 0, buffer.length, (count, error) -> {
                    Assert.isNull(error);
                    Assert.equals(buffer.length, count);

                    file.close((_, error) -> {
                        Assert.isNull(error);
        
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_multiple_temp_files(async:Async) {
        FileSystem.tempFile((file1, error) -> {
            Assert.isNull(error);

            if (Assert.notNull(file1)) {

                FileSystem.tempFile((file2, error) -> {
                    Assert.isNull(error);

                    if (Assert.notNull(file2) && Assert.notNull(file2.path)) {
                        Assert.notEquals(file1.path, file2.path);

                        file2.close((_, error) -> {
                            Assert.isNull(error);

                            file1.close((_, error) -> {
                                Assert.isNull(error);
                
                                async.done();
                            });
                        });
                    } else {
                        file1.close((_, error) -> {
                            Assert.isNull(error);
            
                            async.done();
                        });
                    }
                });
            } else {
                async.done();
            }
        });
    }
}