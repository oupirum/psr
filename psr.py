#!/usr/bin/env python3

# Simple encrypted storage (password manager?)
# Usage:
# ~$ ./psr
#   then type commands:
#     a some str      - add new value
#     d N             - delete value with index N
#     p               - print all values
#     s somestr       - search by given substring
#     chkey           - change encryption key

import sys, os, random, struct, base64
from Crypto.Cipher import AES
from Crypto.Hash import MD5
import re

storage_file = './.psr_storage'
key = None

def main():
    while True:
        cmd = split_cmd(_input('Command (h for help): '))
        
        # help
        if cmd[0] == 'h':
            _print(
                'p            - print all values\n'\
                'a some str   - add new value\n'\
                'd N          - delete value with index N\n'\
                's somestr    - search by given substring\n'\
                'chkey        - change encryption key'\
            )
        
        # print all
        if cmd[0] == 'p':
            _print(read_storage())
        
        # add new
        if cmd[0] == 'a':
            new_line = cmd[1]
            if not new_line:
                _print('data should be non-empty')
                continue
            data = read_storage()
            new_line = constr_new_line(data, new_line)
            if len(data) > 0:
                data += '\n'
            data += new_line
            write_storage(data)
        
        # search
        if cmd[0] == 's':
            query = cmd[1]
            if not query:
                _print('search query should be non-empty')
                continue
            data = read_storage()
            lines = data.split('\n')
            for line in lines:
                if line.find(query) > 0:
                    _print(line)
        
        # delete by index
        if cmd[0] == 'd':
            index = cmd[1]
            if not re.match(r'^[\d]+$', index):
                _print('argument must be a number')
                continue
            data = read_storage()
            lines = data.split('\n')
            for line in lines:
                if line.split(' ', 1)[0] == index:
                    lines.remove(line)
                    _print('removed', '"' + line + '"')
                    data = '\n'.join(lines)
                    write_storage(data)
                    break
        
        # change encryption key
        if cmd[0] == 'chkey':
            global key
            key = None
            data = read_storage()
            key = None
            write_storage(data)
        
        # quit
        if cmd[0] == 'e' or cmd[0] == 'q':
            return
        
        _print('')

def split_cmd(input):
    parts = input.split(' ', 1)
    cmd = parts[0]
    args = ''
    if len(parts) > 1:
        args = parts[1]
    return (cmd, args)

def constr_new_line(data, new_str):
    new_index = 0
    if len(data) > 0:
        lines = data.split('\n')
        last_line = lines[len(lines) - 1]
        new_index = int(last_line.split(' ')[0], 10) + 1
    new_line = str(new_index) + ' ' + new_str
    return new_line

def read_storage():
    global key
    if not os.path.exists(storage_file):
        _print('storage file not found')
        return ''
    storage = open(storage_file, 'r')
    encr = storage.read()
    storage.close()
    if len(encr) == 0:
        _print('storage file empty')
        return ''
    if key == None:
        key = _input('encryption key: ')
    decr = decrypt(key, encr)
    return decr

def write_storage(data):
    global key
    if key == None:
        key = _input('encryption key (write): ')
    if not key:
        _print('key not specified')
        return
    encr = encrypt(key, data)
    storage = open(storage_file, 'w')
    storage.write(encr)
    storage.close()

def encrypt(key, data):
    data = bytes(data, 'utf-8')
    
    iv = os.urandom(16)
    encryptor = cryptor(key, iv)
    
    header = create_header(len(data), iv)
    
    data_encr = b''
    if len(data) > 0:
        if len(data) % 16 != 0:
            data += b' ' * (16 - len(data) % 16)
        
        data_encr += encryptor.encrypt(data)
        
    return base64.b64encode(header + data_encr).decode()

def decrypt(key, data):
    data = base64.b64decode(bytes(data, 'utf-8'))
    
    header = parse_header(data)
    data_len = header[0]
    header_size = header[2]
    
    iv = header[1]
    decryptor = cryptor(key, iv)
    
    data_decr = b''
    data_encr = data[header_size:]
    if len(data_encr) > 0:
        data_decr = decryptor.decrypt(data_encr)
        data_decr = data_decr[:data_len]
    
    return data_decr.decode()

def cryptor(key, iv):
    key = MD5.new(bytes(key, 'utf-8')).digest()
    cryptor = AES.new(key, AES.MODE_CBC, iv)
    return cryptor

def create_header(data_len, iv):
    len_struct = struct.pack('<Q', data_len)
    header = len_struct + iv
    return header

def parse_header(data):
    len_struct_size = struct.calcsize('Q')
    header_size = len_struct_size + 16
    header = data[:header_size]
    data_len = struct.unpack('<Q', header[:len_struct_size])[0]
    iv = header[len_struct_size:header_size]
    return (data_len, iv, header_size)

def _input(prompt):
    return input(prompt)

def _print(*args):
    print(*args)


def test_encryption():
    key = 'test key'
    data = 'test data йцу йцу йцу йцу йцу йцу йцу йцу йцу йцу йцу йцу йцу'
    data_encr = encrypt(key, data)
    print('encrypted:', data_encr)
    data_decr = decrypt(key, data_encr)
    print('decrypted:', data_decr)
    if data_decr != data:
        raise Exception('decrypted != source')
    print('OK')

def test_read_write():
    global storage_file
    storage_file = './.psr_storage_test'
    
    try:
        input_values = []
        
        def test_input(prompt):
            nonlocal input_values
            res = input_values[0]
            input_values = input_values[1:]
            print('<', prompt, res)
            return res
        global _input
        _input = test_input
        
        output_values = []
        
        def test_print(*args):
            print('>', ' '.join(args))
            nonlocal output_values
            output_values = output_values + list(args)
        global _print
        _print = test_print
        
        input_values = ['a line 1', 'test key', 'e']
        main()
        
        input_values = ['a another', 'e']
        main()
        
        input_values = ['a third qwe', 'e']
        main()
        
        output_values = []
        input_values = ['d 1', 'e']
        main()
        if output_values != ['removed', '"1 another"', '']:
            raise Exception(output_values)
        
        output_values = []
        input_values = ['p', 'e']
        main()
        if output_values != ['0 line 1\n2 third qwe', '']:
            raise Exception(output_values)
        
        output_values = []
        input_values = ['s qwe', 'e']
        main()
        if output_values[0] != '2 third qwe':
            raise Exception(output_values)
    finally:
        if os.path.exists(storage_file):
            os.remove(storage_file)
    print('OK')

if len(sys.argv) == 2 and sys.argv[1] == 'test':
    test_encryption()
    test_read_write()
else:
    if len(sys.argv) == 3 and sys.argv[1] == '--storage' and\
            isinstance(sys.argv[2], str):
        storage_file = sys.argv[2]
    main()
