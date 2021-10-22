# composer

### Set environment variables

You can set any environment variables in .env file

POSTGRES_TAG - Postgres version (default value is 11)

ODOO_IMAGE - ODOO image (default value is odoo)

ODOO_TAG - ODOO version/ODOO image tag (default value is fb-11-pipe)

ODOO_DATA - temporary data directory

ODOO_CODE_BRANCH - branch of cetmix-tools repository

Example:
```
composer % cat ./.env
POSTGRES_TAG=11
ODOO_TAG=fb-11-pipe
ODOO_DATA=~/cetmix/data
```

### Deploy local odoo

```make deploy``` 

This command will deploy postgres, init odoo and create odoo container

You can find URL in output of deploy

### Terminate local odoo

```make terminate``` 

It will destroy all containers