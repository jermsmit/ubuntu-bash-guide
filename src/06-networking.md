# Networking

Commands for fetching things, checking connectivity, diagnosing DNS, and
working on remote machines.

## Downloading and calling APIs: `curl` and `wget`

`curl` transfers data from URLs and is the standard tool for talking to web
APIs. Without options it prints the response to your terminal.

<!-- test -->
```bash
curl --version | head -n 1
```

```bash
curl https://example.com                      # print the page
curl -o page.html https://example.com         # save to a file
curl -O https://example.com/file.zip          # save using the remote name
curl -L https://example.com/redirect          # follow redirects
curl -I https://example.com                   # headers only
curl -fsS https://api.example.com/items       # fail on errors, quiet, still show errors
```

Posting data and calling JSON APIs:

```bash
curl -X POST https://api.example.com/items \
     -H 'Content-Type: application/json' \
     -d '{"name":"widget"}'

curl -fsS https://api.example.com/items | jq '.[0].name'
```

> **Flags worth memorizing:** `-f` (fail on HTTP errors, so scripts can notice),
> `-s` (silent), `-S` (still show errors when silent), `-L` (follow redirects).
> The combination `-fsSL` is common in scripts.

`wget` is similar and good at simple downloads and mirroring:

```bash
wget https://example.com/file.zip
wget -c https://example.com/big.iso     # resume a partial download
```

### Do not pipe the internet into your shell blindly

You will see instructions like `curl -fsSL https://site/install.sh | bash`.
That runs whatever the server returns, instantly. Safer: download the script,
read it, then run it.

```bash
curl -fsSL -o install.sh https://example.com/install.sh
less install.sh
bash install.sh
```

## Is it up? `ping`

```bash
ping -c 4 example.com        # send exactly 4 packets
```

Without `-c`, `ping` runs until you press Ctrl+C.

## Your addresses and routes: `ip`

The old `ifconfig` and `netstat` are obsolete. Use `ip` and `ss`.

```bash
ip addr                      # interfaces and IP addresses
ip -br addr                  # the same, one line each (brief)
ip route                     # routing table; the default gateway is here
ip link                      # interface state
```

## Open ports and connections: `ss`

```bash
ss -tulpn                    # listening TCP/UDP sockets and their processes
ss -tn                       # established TCP connections
ss -tlnp | grep :22          # is anything listening on port 22?
```

Flags: `t` TCP, `u` UDP, `l` listening, `p` process, `n` numeric (no name
lookups). Seeing process names for other users' sockets needs `sudo`.

## DNS: `dig`

`dig` comes from the `dnsutils` package (`sudo apt install dnsutils`).

```bash
dig example.com              # full answer
dig +short example.com       # just the address
dig +short MX example.com    # mail servers
dig @1.1.1.1 example.com     # ask a specific resolver
resolvectl status            # how this machine is configured to resolve names
```

## Remote machines: `ssh`, `scp`, `rsync`

```bash
ssh alice@server.example.com             # log in
ssh -p 2222 alice@server.example.com     # a non-default port
ssh alice@server 'df -h /'               # run one command and return
```

### Keys instead of passwords

```bash
ssh-keygen -t ed25519 -C "you@example.com"   # create a key pair
ssh-copy-id alice@server.example.com         # install your public key there
```

Your **private key** (`~/.ssh/id_ed25519`) must stay secret and private
(mode `600`). Share only the `.pub` file.

### A config file saves typing

`~/.ssh/config`:

```text
Host web
    HostName server.example.com
    User alice
    Port 2222
```

Now `ssh web` does the right thing, and so do `scp` and `rsync`.

### Copying files

```bash
scp report.pdf web:/home/alice/             # copy to the server
scp web:/var/log/app.log .                  # copy from the server
rsync -avh --progress project/ web:backup/project/
rsync -avh --delete project/ backup/        # make backup/ mirror project/
```

`rsync` only transfers differences, so repeated runs are fast. **Trailing
slashes matter:** `project/` means "the contents of project", while `project`
means "the directory itself".

> Always rehearse `--delete` with `-n` (dry run) first:
> `rsync -avhn --delete project/ backup/`

## Firewall: `ufw`

Ubuntu's friendly firewall front end is off by default.

```bash
sudo ufw status verbose
sudo ufw allow OpenSSH       # do this BEFORE enabling on a remote machine
sudo ufw enable
sudo ufw allow 443/tcp
```

## Exercises

1. Print only your machine's primary IPv4 address (hint: `ip -4 -br addr`).
2. Check whether anything is listening on port 22.
3. Write a `curl` command that downloads a URL, fails loudly on HTTP errors,
   follows redirects, and saves to `out.html`.
4. Before syncing `project/` to `backup/` with `--delete`, how can you see what
   would change?

<details>
<summary>Answers</summary>

1. `ip -4 -br addr` then pick the column, for example:
   `ip -4 -br addr | awk '$1 != "lo" { print $3 }'`
2. `ss -tln | grep ':22 '`
3. `curl -fsSL -o out.html URL`
4. Add `-n`: `rsync -avhn --delete project/ backup/`

</details>
