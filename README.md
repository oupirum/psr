# psr
Simple AES-encrypted storage (password manager?)

Usage:
<pre>
~$ ./psr.sh
  then type any of commands:
    a <value>       - add new entry
    add <value>       - long form

    d <N>           - delete entry with id N
    rm <N>
    delete <N>
    remove <N>

    p               - print all entries
    print

    s <somestr>     - search entries by given substring (or extended regex pattern)
    search <somestr>

    chpass          - change encryption key

    q               - quit
    quit
    exit
</pre>

On first command in session it will require password.
This password will be remembered for current session.


Commands can be used in non-interactive mod too:
<pre>
~$ ./psr.sh add my secret value
</pre>
