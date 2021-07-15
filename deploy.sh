#!/bin/sh

log() {
	echo '[deploy.sh]' "$@"
}

log 'Deploying the website'

[ ! -f website.tar.gz ] && ./gen.sh
log 'Copying over the tarball'
scp website.tar.gz masflam@masflam.com:/var/www/masflam.com/website.tar.gz
log 'Backing up previous site files and replacing them with the tarball content'
ssh masflam@masflam.com 'cd /var/www/masflam.com; [ ! -d site ] && mkdir site; rm -rf site_prev && mv site site_prev && tar -xzf website.tar.gz && mv output site && rm website.tar.gz'

log 'Deployed the website'
