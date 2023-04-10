package cpp.asys;

import asys.native.net.SocketAddress;

function makeSocketAddress(e : cpp.EnumBase):Null<SocketAddress> {
    return if (e != null) {
        switch e.getIndex() {
            case 0:
                SocketAddress.Net(e.getParamI(0), e.getParamI(1));
            case 1:
                SocketAddress.Ipc(e.getParamI(0));
            case _:
                null;
        }
    } else {
        null;
    }
}