package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestDirectoryList extends DirectoryTests {
    function test_reading_all_entries(async:Async) {
        FileSystem.listDirectory(directoryName, (error, entries) -> {
            Assert.isNull(error);

            if (Assert.notNull(entries)) {
                Assert.equals(3, entries.length);
                    Assert.contains("sub_dir", entries);
                    Assert.contains("file1.txt", entries);
                    Assert.contains("file2.txt", entries);
            }

            async.done();
        });

        function test_reading_file_as_directory(async:Async) {
            FileSystem.listDirectory(dummyFileName, (error, entries) -> {
                Assert.isNull(entries);
    
                if (Assert.notNull(error)) {
                    Assert.equals(IoErrorType.NotDirectory, error.type);
                }
    
                async.done();
            });
        }
    
        function test_reading_non_existing_directory(async:Async) {
            FileSystem.listDirectory("does_not_exist", (error, entries) -> {
                Assert.isNull(entries);
    
                if (Assert.notNull(error)) {
                    Assert.equals(IoErrorType.FileNotFound, error.type);
                }
    
                async.done();
            });
        }
    
        function test_reading_empty_directory(async:Async) {
            FileSystem.listDirectory(emptyDirName, (error, entries) -> {
                Assert.isNull(error);
                
                if (Assert.notNull(entries)) {
                    Assert.equals(0, entries.length);
                }

                async.done();
            });
        }
    }
}