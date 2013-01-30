coffee --compile --output lib/ src/
lessc src/App.less lib/App.css
component install
component build
cp build/build.js public/build.js
cp build/build.css public/build.css

rm -rf build
rm -rf lib
