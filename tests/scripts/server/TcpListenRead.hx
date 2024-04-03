function main() {
    switch Sys.args() {
        case [ ip, port, length ]:
            final server = new sys.net.Socket();
            server.setTimeout(0.5);
            server.bind(new sys.net.Host(ip), Std.parseInt(port));
            server.listen(1);
            
            final client = server.accept();

            Sys.println(client.input.readString(Std.parseInt(length)));
            
            client.shutdown(true, true);
            client.close();
            server.close();
        case _:
            Sys.exit(1);
    }
}