#!/bin/sh

if [ -z "$1" ]; then
	exit 0
fi

OLD=`cat VERSION`
NEW=$1
echo Making new release: $NEW from current release: $OLD... && \
	echo Patching package.json... && \
	sed -i.bak -e "s/$OLD/$NEW/" package.json && \
	rm package.json.bak && \
	echo Writing VERSION file... && \
	echo $NEW > VERSION &&
	echo Committing package.json && \
	git commit --no-gpg-sign package.json VERSION -m "v$NEW" &> /dev/null && \
	echo Buiding site branch... && \
	make site && \
	echo Pushing to github... && \
	git push && \
	# echo Pushing site to blingjs.com... && \
	# ssh jesse@blingjs.com "cd /var/www/blingjs.com; and git pull" && \
	echo Publishing to npm... && \
	npm publish
