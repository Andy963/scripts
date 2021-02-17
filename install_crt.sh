systemctl stop nginx
acme.sh --issue --standalone -d jingang.ga
acme.sh --install-cert -d jingang.ga \
--key-file       /opt/certs/ga/private.key  \
--fullchain-file /opt/certs/ga/fullchain.cer 


