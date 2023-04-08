# OpenAI Protoboard

A [_protoboard_](https://en.wikipedia.org/wiki/Breadboard) for [OpenAI](https://platform.openai.com/overview) exploration, aimed at helping people develop intuition, rapidly prototype ideas, and foster innovation with OpenAI technology.

![8cd62093-08a7-4d80-918f-6e8ebbc52389](https://user-images.githubusercontent.com/113217272/230728178-75396b12-362d-4ccc-b61d-16b34a5817db.png)

> Image artificially created by [Midjourney](https://www.midjourney.com)

- [Running](#running)
- [Screenshots](#screenshots)
- [Cost Estimates Disclaimer](#cost-estimates-disclaimer)
- [Security and Privacy](#security-and-privacy)
## Running

### TLDR

```sh
git clone git@github.com:icebaker/openai-protoboard.git
cd openai-protoboard
./build.sh
cp docker-compose.example.yml docker-compose.yml # OPENAI_API_KEY
docker-compose up -d
# http://localhost:3090
```

### Step-by-Step

Follow these steps to run the OpenAI Protoboard application using Docker.

#### Step 1: Clone the repository

```sh
git clone git@github.com:icebaker/openai-protoboard.git
cd openai-protoboard
```

#### Step 2: Build the Docker images

```.sh
./build.sh
```

#### Step 3: Configure the OpenAI API Key

Copy the example docker-compose file and edit the `docker-compose.yml` to include your OpenAI API Key at `OPENAI_API_KEY`.


```sh
cp docker-compose.example.yml docker-compose.yml
```

#### Step 4: Start the application
Run the containers in detached mode:

```sh
docker-compose up -d
```

#### Step 5: Access the web interface

Open your browser and navigate to http://localhost:3090 to access the OpenAI Protoboard interface.

## Screenshots

![Screenshot_20230408_121531](https://user-images.githubusercontent.com/113217272/230730039-2dffa63e-7a59-4d45-be1e-719e847aa6e5.png)

![Screenshot_20230408_123609](https://user-images.githubusercontent.com/113217272/230730045-67a58718-1e78-4b4b-8fc7-a3304eb55a79.png)


## Cost Estimates Disclaimer

OpenAI APIs are paid services. We make an effort to provide rough estimates of the cost associated with your requests; however, these are not guaranteed and you may incur additional expenses. To prevent overspending, ensure that you have set appropriate usage limits on the OpenAI Platform. Keep in mind that during prototyping, you may perform actions that could consume your entire API budget. Exercise caution and monitor your usage closely.

## Security and Privacy

### Network

Protoboard assumes that your local network and computer are secure. As a result, local network communication is not encrypted, using plain text HTTP, and there are no passwords required to access interfaces and APIs.

Additionally, all services and APIs are exposed under the Docker Host Network, which means your computer's local host.

In summary, Protoboard's security relies on the security of your local network and computer.

### File System

The containers and services create local, unencrypted volumes on your file system. The security of these volumes depends on the security of your computer. Unauthorized access to your computer could compromise your data.

### Privacy

All data provided will be sent to OpenAI APIs for processing. We strongly encourage you to be mindful of the data you share during prototyping. Your data protection depends on the trust you place in OpenAI's handling of your information. Be sure to read [OpenAI's Privacy Policy](https://openai.com/policies/privacy-policy) for more details on their data management practices.
