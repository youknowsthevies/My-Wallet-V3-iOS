#  scripts/bootstrap.sh
#
#  What It Does
#  ------------
#  - Runs carthage, recaptcha integration, generates the project and opens it.
# 

set -ue

if [ ! -f ".env" ]; then
	echo "renaming .env.default to .env"
	cp .env.default .env
fi

git config blame.ignoreRevsFile .git-blame-ignore-revs

echo "Running Carthage"
sh ./scripts/carthage.sh bootstrap --use-ssh --cache-builds --platform iOS --use-xcframeworks --no-use-binaries

echo "Running Recaptcha"
sh ./scripts/recaptcha.sh

echo "Generating project"
sh ./scripts/generate_projects.sh
