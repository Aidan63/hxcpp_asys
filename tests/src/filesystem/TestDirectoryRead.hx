package filesystem;

import haxe.io.Path;
import utils.Directory;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestDirectoryRead extends FileOpenTests {
    final directoryName : String;

    public function new() {
        super();

        directoryName = "test_dir";
    }

    override function setup() {
        super.setup();

        ensureDirectoryIsEmpty(directoryName);

        sys.FileSystem.createDirectory(Path.join([ directoryName, "sub_dir" ]));

        sys.io.File.saveContent(Path.join([ directoryName, "file1.txt" ]), "");
        sys.io.File.saveContent(Path.join([ directoryName, "file2.txt" ]), "");
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
            Assert.notNull(dir);

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
        });
    }

    function test_reading_directory_after_reading_all(async:Async) {
        FileSystem.openDirectory(directoryName, 64, (error, dir) -> {
            Assert.isNull(error);
            Assert.notNull(dir);

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
        });
    }

    function test_reading_directory_batching(async:Async) {
        FileSystem.openDirectory(directoryName, 2, (error, dir) -> {
            Assert.isNull(error);
            Assert.notNull(dir);

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
        });
    }

    function test_reading_file_as_directory(async:Async) {
        FileSystem.openDirectory(dummyFileName, 64, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.notNull(error)) {
                Assert.equals(IoErrorType.NotDirectory, error.type);
            }

            async.done();
        });
    }

    function test_reading_non_existing_directory(async:Async) {
        FileSystem.openDirectory("does_not_exist", 64, (error, dir) -> {
            Assert.isNull(dir);

            if (Assert.notNull(error)) {
                Assert.equals(IoErrorType.FileNotFound, error.type);
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