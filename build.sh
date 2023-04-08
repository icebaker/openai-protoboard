
echo "Building API..."

rm -rf temp
mkdir temp
cp docker/Ruby.Dockerfile temp/Dockerfile
cp -R api/ temp/api

cd temp && docker build . -t "openai-protoboard-api" && cd ..

echo "Building UI..."

rm -rf temp
mkdir temp
cp docker/Svelte.Dockerfile temp/Dockerfile
cp -R ui/ temp/ui

cd temp && docker build . -t "openai-protoboard-ui" && cd ..

echo "Building Python..."

rm -rf temp
mkdir temp
cp docker/Python.Dockerfile temp/Dockerfile
cp -R python-gateway/ temp/python-gateway

cd temp && docker build . -t "openai-protoboard-python-gateway" && cd ..

rm -rf temp

echo "Done!"
