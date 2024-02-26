# deb-demo
This git repository is used to create a basic deb packaging environment

### How to build deb file?

1. clone this project

````
git clone https://github.com/gobkc/deb-demo.git
````

2. Modify the "devscript" directory name to your own app name

````
cd deb-demo
mv devscript your-app
````

3. Modify package information

````
vi devscript/DEBIAN/control

````
control file:
````
Package: your app name
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Depends: bash
Maintainer: your name
Description: app description
````

4. Add the script you want to package to usr/bin
