import sys.net.Host;
import sys.net.Socket;

function main() {
    final client = new Socket();
    client.setTimeout(0.5);
    client.connect(new Host("127.0.0.1"), 7000);
    client.setFastSend(true);

    for (str in Sys.args()) {
        client.output.writeString(str);
    }

    client.close();
}