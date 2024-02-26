import asys.native.net.SecureSocket;
import cpp.asys.SecureSession;
import sys.thread.Thread;
import asys.native.net.Dns;
import cpp.Pointer;
import haxe.Exception;
import haxe.Callback;
import haxe.io.Bytes;
import asys.native.net.Socket;
import net.IpTests;
import net.DnsTests;
import net.ServerTests;
import net.SocketTests;
import system.TestProcessOpen;
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

function main() {
    SecureSocket.connect(Net("127.0.0.1", 4443), null, (socket, error) -> {
        switch error {
            case null:
                final message = Bytes.alloc(1024);

                socket.read(message, 0, message.length, (count, error) -> {
                    switch error {
                        case null:
                            trace(message.sub(0, count).toString());
                        case exn:
                            throw exn;
                    }

                    socket.close((_, error) -> {
                        switch error {
                            case null:
                                trace('closed');
                            case exn:
                                throw exn;
                        }
                    });
                });
            case exn:
                throw exn;
        }
    });

    // final runner = new Runner();
    
    // // Fs
    // runner.addCase(new TestFileOpenRead());
    // runner.addCase(new TestFileOpenReadWrite());
    // runner.addCase(new TestFileOpenAppend());
    // runner.addCase(new TestFileOpenWrite());
    // runner.addCase(new TestFileOpenWriteRead());
    // runner.addCase(new TestFileOpenWriteX());
    // runner.addCase(new TestFileOpenOverwrite());
    // runner.addCase(new TestFileOpenOverwriteRead());
    // runner.addCase(new TestFile());
    // runner.addCase(new TestFileDodgyAccess());
    // runner.addCase(new TestFileModifyingBuffers());
    // runner.addCase(new TestDirectoryOpen());
    // runner.addCase(new TestDirectoryList());
    // runner.addCase(new TestFileSystemTempFile());
    // runner.addCase(new TestFileSystemReadBytes());
    // runner.addCase(new TestFileSystemReadString());
    // runner.addCase(new TestFileSystemWrite());
    // runner.addCase(new TestFileSystemAppend());
    // runner.addCase(new TestFileSystemWriteX());
    // runner.addCase(new TestFileSystemOverwrite());
    // runner.addCase(new TestFileSystemCreateDirectory());
    // runner.addCase(new TestFileSystemUniqueDirectory());
    // runner.addCase(new TestFilePath());
    // runner.addCase(new TestFilePathExtras());
    // runner.addCase(new TestFileSystemMove());
    // runner.addCase(new TestFileSystemDeleteFile());
    // runner.addCase(new TestFileSystemDeleteDirectory());
    // runner.addCase(new TestFileSystemInfo());
    // runner.addCase(new TestFileSystemCheck());
    // runner.addCase(new TestFileSystemIsDirectory());
    // runner.addCase(new TestFileSystemIsFile());
    // runner.addCase(new TestFileSystemLink());
    // runner.addCase(new TestFileSystemIsLink());
    // runner.addCase(new TestFileSystemReadLink());
    // runner.addCase(new TestFileSystemLinkInfo());
    // runner.addCase(new TestFileSystemCopyFile());
    // runner.addCase(new TestFileSystemResize());
    // runner.addCase(new TestFileSystemSetTimes());
    // runner.addCase(new TestFileSystemRealPath());

    // // Net
    // runner.addCase(new DnsTests());
    // runner.addCase(new IpTests());
    // // runner.addCase(new SocketTests());
    // runner.addCase(new ServerTests());

    // // System
    // // runner.addCase(new TestProcessOpen());
     
    // Report.create(runner);
    
    // runner.run();
}