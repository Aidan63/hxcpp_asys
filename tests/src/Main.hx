import filesystem.TestFile;
import filesystem.TestFilePath;
import filesystem.TestFileOpenRead;
import filesystem.TestFileOpenWrite;
import filesystem.TestDirectoryOpen;
import filesystem.TestDirectoryList;
import filesystem.TestFilePathExtras;
import filesystem.TestFileOpenAppend;
import filesystem.TestFileOpenWriteX;
import filesystem.TestFileSystemWrite;
import filesystem.TestFileDodgyAccess;
import filesystem.TestFileSystemAppend;
import filesystem.TestFileSystemWriteX;
import filesystem.TestFileOpenReadWrite;
import filesystem.TestFileOpenWriteRead;
import filesystem.TestFileOpenOverwrite;
import filesystem.TestFileSystemTempFile;
import filesystem.TestFileSystemOverwrite;
import filesystem.TestFileSystemReadBytes;
import filesystem.TestFileSystemReadString;
import filesystem.TestFileModifyingBuffers;
import filesystem.TestFileOpenOverwriteRead;
import filesystem.TestFileSystemCreateDirectory;
import filesystem.TestFileSystemUniqueDirectory;
import utest.ui.Report;
import utest.Runner;

function main() {
    final runner = new Runner();
    runner.addCase(new TestFileOpenRead());
    runner.addCase(new TestFileOpenReadWrite());
    runner.addCase(new TestFileOpenAppend());
    runner.addCase(new TestFileOpenWrite());
    runner.addCase(new TestFileOpenWriteRead());
    runner.addCase(new TestFileOpenWriteX());
    runner.addCase(new TestFileOpenOverwrite());
    runner.addCase(new TestFileOpenOverwriteRead());
    runner.addCase(new TestFile());
    runner.addCase(new TestFileDodgyAccess());
    runner.addCase(new TestFileModifyingBuffers());
    runner.addCase(new TestDirectoryOpen());
    runner.addCase(new TestDirectoryList());
    runner.addCase(new TestFileSystemTempFile());
    runner.addCase(new TestFileSystemReadBytes());
    runner.addCase(new TestFileSystemReadString());
    runner.addCase(new TestFileSystemWrite());
    runner.addCase(new TestFileSystemAppend());
    runner.addCase(new TestFileSystemWriteX());
    runner.addCase(new TestFileSystemOverwrite());
    runner.addCase(new TestFileSystemCreateDirectory());
    runner.addCase(new TestFileSystemUniqueDirectory());
    runner.addCase(new TestFilePath());
    runner.addCase(new TestFilePathExtras());

    Report.create(runner);
    
    runner.run();
}