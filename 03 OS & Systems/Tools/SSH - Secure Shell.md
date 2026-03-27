Also known as OpenSSH

Standard remote management using command line.

"Server - Client" 

Server is the remote device we want to access and client is the device we are using ssh to access the server.

_ssh_ is present by default in linux devices.

## How does it work?

It has 2 components:
- SSH Client
- SSH Server

Use client to connect to the server.

## How to connect using SSH

Check if SSH is present:
```bash
whcih ssh
```

```bash
ssh <username-server>@<ip-address>
```

Then enter password and it will be connected.

`exit` to logout.

To connect with a port:
```bash
ssh -p <port -no> <usernamer-server>@<ip-address>
```

Tags: #concept #linux 