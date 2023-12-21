package filesystem;

import haxe.exceptions.ArgumentException;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FsException;

class TestDirectoryOpen extends DirectoryTests {
    function test_null_path(async:Async) {
        FileSystem.openDirectory(null, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("path", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_invalid_batch_size(async:Async) {
        FileSystem.openDirectory(directoryName, 0, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.isOfType(error, ArgumentException)) {
                Assert.equals("maxBatchSize", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_opening_directory(async:Async) {
        FileSystem.openDirectory(directoryName, 64, (error, dir) -> {
            Assert.isNull(error);

            if (Assert.notNull(dir)) {
                Assert.equals(directoryName, dir.path);
            }

            dir.close((error, _) -> {
                Assert.isNull(error);

                async.done();
            });
        });
    }

    function test_reading_directory_in_single_batch(async:Async) {
        FileSystem.openDirectory(directoryName, 64, (error, dir) -> {
            Assert.isNull(error);
            if (Assert.notNull(dir)) {
                dir.next((error, entries) -> {
                    Assert.isNull(error);
    
                    if (Assert.notNull(entries)) {
                        Assert.equals(3, entries.length);
                        Assert.contains("sub_dir", entries);
                        Assert.contains("file1.txt", entries);
                        Assert.contains("file2.txt", entries);
                    }
    
                    dir.close((error, _) -> {
                        Assert.isNull(error);
        
                        async.done();
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_directory_after_reading_all(async:Async) {
        FileSystem.openDirectory(directoryName, 64, (error, dir) -> {
            Assert.isNull(error);

            if (Assert.notNull(dir)) {
                dir.next((error, _) -> {
                    Assert.isNull(error);
    
                    dir.next((error, entries) -> {
                        Assert.isNull(error);
                        if (Assert.notNull(entries)) {
                            Assert.equals(0, entries.length);
                        }
    
                        dir.close((error, _) -> {
                            Assert.isNull(error);
            
                            async.done();
                        });
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_directory_batching(async:Async) {
        FileSystem.openDirectory(directoryName, 2, (error, dir) -> {
            Assert.isNull(error);

            if (Assert.notNull(dir)) {
                final accumulated = [];
    
                dir.next((error, entries) -> {
                    Assert.isNull(error);
    
                    if (Assert.notNull(entries)) {
                        Assert.equals(2, entries.length);
    
                        for (entry in entries) {
                            accumulated.push(entry);
                        }
                    }
    
                    dir.next((error, entries) -> {
                        Assert.isNull(error);
        
                        if (Assert.notNull(entries)) {
                            Assert.equals(1, entries.length);
    
                            for (entry in entries) {
                                accumulated.push(entry);
                            }
                        }
    
                        Assert.contains("sub_dir", accumulated);
                        Assert.contains("file1.txt", accumulated);
                        Assert.contains("file2.txt", accumulated);
        
                        dir.close((error, _) -> {
                            Assert.isNull(error);
            
                            async.done();
                        });
                    });
                });
            } else {
                async.done();
            }
        });
    }

    function test_reading_file_as_directory(async:Async) {
        FileSystem.openDirectory(dummyFileName, 64, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals(IoErrorType.NotDirectory, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_reading_non_existing_directory(async:Async) {
        FileSystem.openDirectory("does_not_exist", 64, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.isOfType(error, FsException)) {
                Assert.equals(IoErrorType.FileNotFound, (cast error : FsException).type);
            }

            async.done();
        });
    }

    function test_reading_empty_directory(async:Async) {
        FileSystem.openDirectory(emptyDirName, 64, (error, dir) -> {
            Assert.isNull(error);
            
            if (Assert.notNull(dir)) {
                dir.next((error, entries) -> {
                    Assert.isNull(error);
    
                    if (Assert.notNull(entries)) {
                        Assert.equals(0, entries.length);
                    }
    
                    dir.close((error, _) -> {
                        Assert.isNull(error);
        
                        async.done();
                    });
                });   
            } else {
                async.done();
            }
        });
    }
}