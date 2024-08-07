import net.IpTests;
import net.DnsTests;
import net.ServerOpenTests;
import net.ServerAcceptTests;
import net.SocketWritingTests;
import net.SocketReadingTests;
import net.SocketConnectTests;
import net.ServerReadingTests;
import net.ServerWritingTests;
import system.TestProcessOpen;
import system.TestCurrentProcessSignals;
import system.TestCurrentProcessWriteTty;
import filesystem.TestFile;
import filesystem.TestFilePath;
import filesystem.TestFileOpenRead;
import filesystem.TestFileOpenWrite;
import filesystem.TestDirectoryOpen;
import filesystem.TestDirectoryList;
import filesystem.TestFileSystemInfo;
import filesystem.TestFileSystemMove;
import filesystem.TestFilePathExtras;
import filesystem.TestFileOpenAppend;
import filesystem.TestFileOpenWriteX;
import filesystem.TestFileSystemLink;
import filesystem.TestFileSystemWrite;
import filesystem.TestFileDodgyAccess;
import filesystem.TestFileSystemCheck;
import filesystem.TestFileSystemAppend;
import filesystem.TestFileSystemIsFile;
import filesystem.TestFileSystemWriteX;
import filesystem.TestFileSystemIsLink;
import filesystem.TestFileSystemResize;
import filesystem.TestFileOpenReadWrite;
import filesystem.TestFileOpenWriteRead;
import filesystem.TestFileOpenOverwrite;
import filesystem.TestFileSystemTempFile;
import filesystem.TestFileSystemReadLink;
import filesystem.TestFileSystemLinkInfo;
import filesystem.TestFileSystemCopyFile;
import filesystem.TestFileSystemSetTimes;
import filesystem.TestFileSystemRealPath;
import filesystem.TestFileSystemOverwrite;
import filesystem.TestFileSystemReadBytes;
import filesystem.TestFileSystemReadString;
import filesystem.TestFileModifyingBuffers;
import filesystem.TestFileSystemDeleteFile;
import filesystem.TestFileSystemIsDirectory;
import filesystem.TestFileOpenOverwriteRead;
import filesystem.TestFileSystemCreateDirectory;
import filesystem.TestFileSystemUniqueDirectory;
import filesystem.TestFileSystemDeleteDirectory;
import utest.Runner;
import utest.ui.Report;

function test() {   
    final runner = new Runner();
    
    // Fs
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
    runner.addCase(new TestFileSystemMove());
    runner.addCase(new TestFileSystemDeleteFile());
    runner.addCase(new TestFileSystemDeleteDirectory());
    runner.addCase(new TestFileSystemInfo());
    runner.addCase(new TestFileSystemCheck());
    runner.addCase(new TestFileSystemIsDirectory());
    runner.addCase(new TestFileSystemIsFile());
    runner.addCase(new TestFileSystemLink());
    runner.addCase(new TestFileSystemIsLink());
    runner.addCase(new TestFileSystemReadLink());
    runner.addCase(new TestFileSystemLinkInfo());
    runner.addCase(new TestFileSystemCopyFile());
    runner.addCase(new TestFileSystemResize());
    runner.addCase(new TestFileSystemSetTimes());
    runner.addCase(new TestFileSystemRealPath());

    // Net
    runner.addCase(new DnsTests());
    runner.addCase(new IpTests());
    runner.addCase(new SocketConnectTests());
    runner.addCase(new SocketReadingTests());
    runner.addCase(new SocketWritingTests());
    runner.addCase(new ServerOpenTests());
    runner.addCase(new ServerAcceptTests());
    runner.addCase(new ServerReadingTests());
    runner.addCase(new ServerWritingTests());

    // System
    runner.addCase(new TestProcessOpen());
    runner.addCase(new TestCurrentProcessWriteStdout());
    runner.addCase(new TestCurrentProcessWriteStderr());
    runner.addCase(new TestCurrentProcessSignals());
     
    Report.create(runner);
    
    runner.run();
}

function main() {
    switch Sys.args() {
        case [ Mode.ZeroExit ]:
            Sys.exit(0);
        case [ Mode.ErrorExit, code ]:
            Sys.exit(Std.parseInt(code));
        case [ Mode.StdoutEcho, str ]:
            final output = Sys.stdout();

            output.writeString(str);
            output.flush();
        case [ Mode.StderrEcho, str ]:
            final output = Sys.stderr();

            output.writeString(str);
            output.flush();
        case [ Mode.StdinEcho, expected ]:
            final input  = Sys.stdin().readString(expected.length);
            
            Sys.exit(input == expected ? 0 : 1);
        case [ Mode.PrintCwd ]:
            final output = Sys.stdout();

            output.writeString(Sys.getCwd());
            output.flush();
        case [ Mode.PrintEnv, env ]:
            final output = Sys.stdout();

            output.writeString(Sys.getEnv(env));
            output.flush();
        case [ Mode.LoopForever ]:
            while (true) {
                Sys.sleep(1);
            }
        case _:
            test();
    }
}