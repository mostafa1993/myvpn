**Install:**

```bash
git clone git@github.com:mostafa1993/myvpn.git
./install.sh --user=USER --protocol=PROTOCOL --domain=DOMAIN --group=GROUP
```

If group is not specified for your case use `--group=GROUP=''`
During installation you will be asked to enter your root and vpn password.



**Usage:**

If you want to connect the vpn with your defualt settings, the ones used during installation, you only need to run,

```bash
myvpn start --default
```

If you want to connect with different settings,

```bash
myvpn start -u=USER -p=PROTOCOL -d=DOMAIN -g=GROUP
```

for stopping the vpn,

```bash
myvpn stop
```



**How to change default setting:**

It is possible to change the default setting, the trivial option is to uninstall and install the program with new settings.

The beeter way is to access the config file and change the settings there. You may find the config file in `/etc/myvpn/myvpn.config`.
