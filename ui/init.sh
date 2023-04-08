rm -rf static/config/environment.json
rm -rf .svelte-kit/output/client/config/environment.json
cp static/config/environment.template.json static/config/environment.json

sed -i "s?{PROTOBOARD_API_ADDRESS}?$PROTOBOARD_API_ADDRESS?g" static/config/environment.json

if [ -d ".svelte-kit/output/client/config" ]; then
  cp static/config/environment.json .svelte-kit/output/client/config/environment.json
fi

npx vite preview --port $PORT --host 0.0.0.0 --mode production
