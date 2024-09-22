# psr
**A Simple AES-Encrypted Storage (Password Manager)**


`psr` is a simple AES256-encrypted storage utility for managing sensitive data such as passwords. You can securely store, search, add, and delete entries via a command-line interface.

### Usage
To start the tool, run the following command:
```bash
$ ./psr.sh
```

Upon launching the tool for the first time in a session, you will be prompted to enter a password. This password will be used for encrypting and decrypting entries and will be remembered for the duration of the session.

### Available Commands
You can interact with `psr` using the following commands:

- **Add a new entry:**
  - `a <value>`: Add a new entry.
  - `add <value>`: Long-form alias for adding an entry.

- **Delete an entry by ID:**
  - `d <N>`: Delete the entry with ID `N`.
  - Aliases:
    - `rm <N>`
    - `delete <N>`
    - `remove <N>`

- **Print all entries:**
  - `p`: Print all stored entries.
  - Alias:
    - `print`

- **Search entries:**
  - `s <substring/regex>`: Search for entries containing the given substring or matching a regex pattern.
  - Alias:
    - `search <substring/regex>`

- **Change encryption key:**
  - `chpass`: Rewrite data with a new encrption key.

- **Quit the session:**
  - `q`: Quit the session.
  - Aliases:
    - `quit`
    - `exit`

### Non-Interactive Mode
Commands can also be executed in non-interactive mode by passing them directly as arguments:

```bash
$ ./psr.sh add "my secret value"
```

This will execute the `add` command and store the entry without starting an interactive session.


### Data Storage
All encrypted data is stored in the `~/.psr_storage` file. This file is automatically created if it doesn't exist. Ensure that you safeguard or backup this file as losing it will result in the permanent loss of all stored entries.