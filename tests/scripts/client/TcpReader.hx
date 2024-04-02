import sys.net.Host;
import sys.net.Socket;

function main() {
    switch Sys.args() {
        case [ length ]:
            final client = new Socket();
            client.setTimeout(0.5);
            client.connect(new Host("127.0.0.1"), 7000);

            Sys.println(client.input.readString(Std.parseInt(length)));

            client.close();
        case _:
            Sys.exit(1);
    }
}