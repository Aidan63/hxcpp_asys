import sys.net.Host;
import sys.net.Socket;

function main() {
    final client = new Socket();
    client.setTimeout(1);
    client.connect(new Host("127.0.0.1"), 7000);
    client.waitForRead();
    client.close();
}