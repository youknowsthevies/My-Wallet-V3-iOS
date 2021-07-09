set -ue

cd Submodules/My-Wallet-V3

git log -1 | cat

echo "Cleaning..."
rm -rf build dist

echo "Building..."
npm run build

echo "Build success"
