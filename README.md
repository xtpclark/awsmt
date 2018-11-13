# Flywheel

## Local installation

### Prerequisites and assumptions

- [Vagrant is set up](https://github.com/xtuple/xdruple-server/blob/master/vagrant.md) and virtual machine is up and running.
- Mobilized ERP database is up and running, and you have admin access to it.

### ERP connection

1. In the browser, go to the ERP mobile client, provide your admin login and password and log in.
2. Go to `OAuth2` menu; press `+ New` to create a new OAuth2 key: enter name for the key, your email, select `Client type` → `Service Account`; copy the value of `ID` field; press `Save` and wait until the key is downloaded.
3. Move the downloaded key into the `${XDRUPLE_SERVER}/xtuple/keys` directory (where `${XDRUPLE_SERVER}` is directory with cloned `xdruple-server`); the keys should appear in `/vagrant/xtuple/keys` on your virtual machine.
4. In ERP mobile client go to the `xDruple` menu; press `+ New` to add a new app (client); enter your app name (e.g. `local_john`) and site URL (e.g. `john.local.xd`) (name and URL should be unique).
5. Make sure you have ready: `p12` key file in `/vagrant/xtuple/keys` directory on your virtual machine, key `ID` (from OAuth2 key record), and your app name (from xDruple menu).

You should be ready for Drupal setup.

### Drupal setup

```bash
# Run `vagrant ssh` to ssh into your virtual machine
git clone git@github.com:xtuple/flywheel.git /var/www/flywheel.xd && \
cd /var/www/flywheel.xd && \
composer install
```

Edit `application/config/environment.xml`, replace parameter tokens:

- `{ENVIRONMENT}` - must be `development`, `stage` or `production`.
- `{ERP_APP_NAME}` - the name of the app created in xDruple menu of the mobile client.
- `{ERP_HOST}` -  mobile client URL (e.g. https://{project}_stage.xtuplecloud.com).
- `{ERP_DATABASE}` - DB name. 
- `{ERP_ISS}` - the ID of the key created in OAuth2 menu.
- `{ERP_KEY_FILE}` - an absolute path to the file with the key (e.g. `/var/xtuple/keys/{project}-stage.p12`).
- `{ERP_DEBUG}` - must be `true`, if SSL for mobile client is not set up or self-signed; `false` otherwise.

*If re-installing Drupal, remove old settings.php files:*
```bash
sudo chmod +w ./drupal/core/sites/default && \
sudo chmod +w ./drupal/core/sites/default/settings.php && \
sudo rm ./drupal/core/sites/default/settings.php && \
sudo rm ./application/drupal/settings.php
```

```bash
# NB: Use your own Drupal user password (`--user-pass`) and email (`--site-mail`)
./console.php install:drupal \
  --db-name='flywheel' \
  --db-pass='flywheel' \
  --db-user='flywheel' \
  --user-pass='xTuple-WSG' \
  --site-mail='developer.wsg@xtuple.com' \
  --site-name="Flywheel"
```

Check that your local installation has correct DNS record:

```bash
# On your host machine
ping flywheel.xd
```

It should return something like this (`192.168.33.10` (default) would be the IP for your virtual machine)
```
PING flywheel.xd (192.168.33.10): 56 data bytes
64 bytes from 192.168.33.10: icmp_seq=0 ttl=64 time=0.294 ms
```

If it returns `ping: cannot resolve flywheel.xd: Unknown host` then `/etc/hosts` file on host machine should be edited (if you changed the IP for the virtual machine in `config.rb` make sure to use it instead of `192.168.33.10`):

```bash
sudo sh -c "echo '192.168.33.10   flywheel.xd' >> /etc/hosts"
```

Finally, you should be able to see the result in the browser. Note, as some browsers, like Google Chrome combine address and search fields, you might need to type the full address: `http://flywheel.xd/`.

## PHPStorm IDE

- Exclude directories that contain user-generated content and symlinks: `web`, `drupal/core/vendor`, `drupal/core/sites`.
- Enable Drupal support: installation path is `drupal/core`, version is `7`.
- Detect PSR-0 namespaces (Menu: `Code` → `Detect PSR-0 Namespace Roots`).
- Set `xDruple` code-style.
