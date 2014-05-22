#!/bin/bash

clean_every=10 #builds
github_user="bubuntux"
github_repo="mvn"
branch="repo"
commit_message="Clean up build ${TRAVIS_BUILD_NUMBER} ( https://travis-ci.org/${github_user}/${github_repo}/builds/${TRAVIS_BUILD_ID} )"
notify_email_on_failure="bubuntux@gmail.com"

if [[ ${TRAVIS_PULL_REQUEST} == 'false' && $((${TRAVIS_BUILD_NUMBER}%${clean_every})) == 0 ]]; then
	git config user.email ${notify_email_on_failure}
	git config user.name  "Travis-CI"
	
	echo 'Updating repo'
	git checkout ${branch} --quiet
	git fetch origin ${branch} --quiet
	git reset --hard origin/${branch} --quiet
	
	echo 'Removing old snapshot jars'
	for DIR in $(find . -type d | grep -v "/.git" | grep "SNAPSHOT$"); do 
		latestJar=`ls ${DIR} | grep ".jar$" | sort -rV | head -1`
		for FILE in $(find "${DIR}" -type f | grep -v "/${latestJar%.jar}" | grep -v "/maven-metadata"); do
			git rm "${FILE}" --quiet
		done;
	done;
	git commit -m "remove old jars" --quiet 
	
	echo 'Removing history'
	git branch tmp $(echo "${commit_message}" | git commit-tree HEAD^{tree}) --quiet 
	git checkout tmp --quiet
	git branch -D ${branch} --quiet
	git branch -m ${branch} --quiet
	
	echo 'Pushing...'
	git push https://${github_user}:${SECRET}@github.com/${github_user}/${github_repo}.git ${branch} --force --quiet #replace origin/repo branch with local tmp
else
    echo "Nothing to do for this build"
fi
