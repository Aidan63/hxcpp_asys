package asys.native.system;

abstract AsysError(cpp.EnumBase) {
    @:to public function toIoErrorType() {
        return switch this._hx_getIndex() {
            case 0:
                IoErrorType.FileNotFound;
            case 1:
                IoErrorType.FileExists;
            case 2:
                IoErrorType.ProcessNotFound;
            case 3:
                IoErrorType.AccessDenied;
            case 4:
                IoErrorType.NotDirectory;
            case 5:
                IoErrorType.TooManyOpenFiles;
            case 6:
                IoErrorType.BrokenPipe;
            case 7:
                IoErrorType.NotEmpty;
            case 8:
                IoErrorType.AddressNotAvailable;
            case 9:
                IoErrorType.ConnectionReset;
            case 10:
                IoErrorType.TimedOut;
            case 11:
                IoErrorType.ConnectionRefused;
            case 12:
                IoErrorType.BadFile;
            case 13:
                IoErrorType.IsDirectory;
            case 14:
                IoErrorType.CustomError(this.getParamI(0));
            default:
                IoErrorType.CustomError('Unknown Error ${ this._hx_getIndex() }');
        }
    }
}