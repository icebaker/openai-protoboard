FROM python:3.12.0a7-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends \
      git build-essential
RUN apt-get install -y --no-install-recommends \
      curl jq iputils-ping telnet openssl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN mkdir /.cargo
WORKDIR /app
COPY ./python-gateway /app
RUN PATH="$PATH:$HOME/.cargo/bin" pip install -r requirements.txt
RUN chown 1000:1000 /app

USER 1000
WORKDIR /app
CMD ["bash", "./init.sh"]
