function main() {
    switch Sys.args() {
        case [ ip, port ]:
            final server = new sys.net.Socket();
            server.setTimeout(0.5);
            server.bind(new sys.net.Host(ip), Std.parseInt(port));
            server.listen(1);
            
            final client = server.accept();
            client.shutdown(true, true);
            client.close();

            server.close();
        case _:
            Sys.exit(1);
    }
}