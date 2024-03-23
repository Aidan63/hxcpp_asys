enum abstract Mode(String) from String to String {
    final StdoutEcho;
    final StderrEcho;
    final ZeroExit;
    final ErrorExit;
    final LoopForever;
}