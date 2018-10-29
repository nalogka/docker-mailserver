Postfix MTA with DKIM signing and no local delivery
===================================================

This image setup the Postfix MTA with DKIM signature capability (via OpenDKIM
mail filter) and no local delivery.

DKIM private keys must be placed into container within directory
`/run/secrets/opendkim` using volume binding (running the Regular Docker mode)
or using swarm secrets (running the Docker Swarm Mode). Naming of a key files
must follow given pattern `selector.domain.tld.private`, where `selector`
is DKIM selector, `domain.tld` is sender domain FQDN, `private` - constant
suffix.

Regular mode
------------

```
docker run -d --name mail \
    --hostname mail.example.com \
    --network mail_clients_net \
    -v "$DKIM_SECRETS_DIR:/run/secrets/opendkim" \
  minity/mailserver:latest
```

Docker Swarm mode
-----------------

```
docker service create --name mail --replicas 1 \
    --secret source=dkim.mail.example.com,target=opendkim/mail.nalogka.com.private \
    --secret source=dkim.sub.example.com,target=opendkim/sub.nalogka.com.private \
    --hostname mail.example.com \
    --network mail_clients_net \
  minity/mailserver:latest
```
