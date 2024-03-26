enum abstract Mode(String) from String to String {
    final StdoutEcho;
    final StderrEcho;
    final StdinEcho;
    final PrintCwd;
    final PrintEnv;
    final ZeroExit;
    final ErrorExit;
    final LoopForever;
}