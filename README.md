# psr
Simple AES-encrypted storage (password manager?)

Usage:
<pre>
~$ ./psr.sh
  then type any of commands:
    a &lt;value&gt;       - add new entry
    add &lt;value&gt;       - long form

    d &lt;N&gt;           - delete entry with id N
    rm &lt;N&gt;
    delete &lt;N&gt;
    remove &lt;N&gt;

    p               - print all entries
    print

    s &lt;somestr&gt;     - search entries by given substring (or extended regex pattern)
    search &lt;somestr&gt;

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
