import net.SocketTests;
import net.IpTests;
import net.DnsTests;
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
    runner.addCase(new SocketTests());

    // System
    // runner.addCase(new TestProcessOpen());
     
    Report.create(runner);
    
    runner.run();

    // Socket.connect(Net("127.0.0.1", 7777), null, (socket, error) -> {
    //     switch error {
    //         case null:
    //             final buffer = Bytes.ofString("Hello, Server");

    //             trace(socket.localAddress);
    //             trace(socket.remoteAddress);

    //             socket.write(buffer, 0, buffer.length, (count, error) -> {
    //                 switch error {
    //                     case null:
    //                         trace('sent $count');
    //                     case exn:
    //                         trace(exn);
    //                 }

    //                 socket.close((_, error) -> {
    //                     switch error {
    //                         case null:
    //                             trace('client closed');
    //                         case exn:
    //                             trace(exn);
    //                     }
    //                 });
    //             });
    //         case exn:
    //             trace(exn);
    //     }
    // });

    // Server.open(Net("0.0.0.0", 7777), null, (server, error) -> {
    //     switch error {
    //         case null:
    //             trace(server.localAddress);

    //             server.accept((client, error) -> {
    //                 switch error {
    //                     case null:
    //                         trace('client connected');
    //                         trace(client.localAddress);
    //                         trace(client.remoteAddress);

    //                         final buffer = Bytes.ofString("Hello, Server");

    //                         client.write(buffer, 0, buffer.length, (count, error) -> {
    //                             switch error {
    //                                 case null:
    //                                     trace('sent $count');
    //                                 case exn:
    //                                     trace(exn);
    //                             }

    //                             client.close((_, error) -> {
    //                                 switch error {
    //                                     case null:
    //                                         trace('client closed');

    //                                         server.close((_, error) -> {
    //                                             switch error {
    //                                                 case null:
    //                                                     trace('server closed');         
    //                                                 case exn:
    //                                                     trace(exn);
    //                                             }
    //                                         });
    //                                     case exn:
    //                                         trace(exn);
    //                                 }
    //                             });
    //                         });
    //                     case exn:
    //                         trace(exn);
    //                 }
    //             });
    //         case exn:
    //             trace(exn);
    //     }
    // });
}