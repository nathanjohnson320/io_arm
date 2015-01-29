#!/bin/bash

# Get the most recent version of node
url=http://nodejs.org/dist/latest/node-
version=
url+=$version.tar.gz
wget $url -O ./node/node.source.tar.gz

# change into the node directory and untar
cd ./node
tar -xvzf node.source.tar.gz
rm node.source.tar.gz

# Configure and make the file
cd ./node-$version
./configure
make

# Install and make a package
sudo checkinstall -D -pkgversion ${version#?} -y
# Move the package do the files directory
cp node_${version#?}-1_armhf.deb ../../../files

# Remove the compilation directories
cd ../../../
sudo rm -rf ./scripts/node/node-$version

# Remove routes from web.js
head -n -12 web.js > tmp.js
mv tmp.js web.js

# Delete the oldest package
cd files
ls | sort | head -1 | xargs git rm

# Replace existing routes in web.js
FILES=*
count=0
for f in $FILES
do
  count=$(($count + 1))
  if [[ "$count" -gt 2 ]]
  then
    # Write the specific routes for versions
    echo "app.get('/node_latest_armhf.deb', function (req, res) {" >> ../$appfile
  else
    # Write the route for the newest package
    echo "app.get('/$f', function (req, res) {" >> ../web.js >> ../$appfile
  fi
  echo "  insert_ip(req.connection.remoteAddress, $count);" >> ../$appfile
  echo "  res.download(__dirname + '/files/$f');" >> ../$appfile
  echo "});" >> ../$appfile
done

# Commit and push all the files
cd ../
git add .
git commit -m "Updated node version to $version"
#  git push origin master
#  git push heroku master

# Rename the new changelog to the old one
cd ./scripts/
mv ./new-log.html changelog.html 
