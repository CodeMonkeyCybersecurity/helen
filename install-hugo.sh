# Find latest version at https://github.com/gohugoio/hugo/releases/latest
HUGO_VER=0.127.0  # <-- set to latest (or at least 0.128.0, e.g. 0.127.0 is below the requirement)
# Use 0.128.0 or newer! Example:
HUGO_VER=0.128.2

cd /tmp
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_extended_${HUGO_VER}_linux-amd64.tar.gz
tar -xvf hugo_extended_${HUGO_VER}_linux-amd64.tar.gz
sudo mv hugo /usr/bin/
hugo version
