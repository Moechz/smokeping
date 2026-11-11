#!/bin/sh
# TOS wrapper: the image runs Apache on :80 as root. Rebuild a minimal
# non-root Apache on 8080 from the image's own /defaults config, serve the
# smokeping CGI from a writable wrapper, and run the smokeping daemon as 1000.
set -u
set -e
mkdir -p /config /data /run/apache2 /var/cache/smokeping
cp -rn /defaults/smoke-conf/* /config/ 2>/dev/null || true
printf '#!/bin/sh\nexec /usr/bin/smokeping_cgi /etc/smokeping/config\n' > /config/smokeping.cgi
chmod 755 /config/smokeping.cgi
cp /defaults/tcpping /config/tcpping 2>/dev/null || true
chmod 755 /config/tcpping 2>/dev/null || true
sed -i 's|/usr/bin/tcpping|/config/tcpping|' /config/Probes 2>/dev/null || true
cp /defaults/httpd.conf /tmp/httpd.conf
sed -i 's/^Listen 80/Listen 8080/; s/^User abc/#User abc/; s/^Group abc/#Group abc/; s|^PidFile .*|PidFile /tmp/httpd.pid|; s|^ErrorLog .*|ErrorLog /tmp/error.log|; s|CustomLog logs/access.log combined|CustomLog /tmp/access.log combined|' /tmp/httpd.conf
cat >> /tmp/httpd.conf <<'CONF'
DirectoryIndex smokeping.cgi index.html
ScriptAlias /smokeping/smokeping.cgi /config/smokeping.cgi
Alias /smokeping /usr/share/webapps/smokeping
<Directory "/usr/share/webapps/smokeping">
    Options +ExecCGI +FollowSymLinks
    AddHandler cgi-script .cgi
    Require all granted
</Directory>
<Directory "/config">
    Options +ExecCGI
    AddHandler cgi-script .cgi
    Require all granted
</Directory>
CONF
/usr/sbin/smokeping --config=/etc/smokeping/config --nodaemon >/tmp/smokeping.log 2>&1 &
exec /usr/sbin/httpd -f /tmp/httpd.conf -X
