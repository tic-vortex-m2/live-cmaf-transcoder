# Live CMAF Transcoder

Distributed system designed to re-encode live streams into the Common Media Application Format (CMAF). 

It has the capability to output streams in both DASH (Dynamic Adaptive Streaming over HTTP) and HLS (HTTP Live Streaming) formats with multiple Adaptation Sets and Representations. 

It uses hardware acceleration, which significantly improves the efficiency and speed of the encoding process. 

The distributed nature of the system allows for encoding tasks to be run on different GPUs and across multiple machines, thereby enhancing the scalability and performance of the system.

This project is built atop a customized version of ffmpeg

![Overview](https://raw.githubusercontent.com/sessystems/live-cmaf-transcoder/main/docs/images/overview.png)

## Features

- **Live Stream Re-encoding**: Convert live streams into CMAF format.
- **Multi-Format Output**: Supports both DASH and HLS streaming formats.
- **Hardware Acceleration**: Utilizes GPUs to speed up the encoding process.
- **Scalability**: Distributed system capable of running on multiple machines.


## Getting Started

Follow these instructions to set up and run the transcoder.

### Prerequisites

- **Docker**: Ensure that Docker and Docker Compose are installed on your machine. You can find the installation guides [here](https://docs.docker.com/get-docker/).
- **NVIDIA Container Toolkit** (optional, for NVIDIA GPU support): If using NVIDIA GPUs, install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) on your host machine.


### Running the Transcoder

#### 1. **Without Hardware Acceleration Support**

To run the live-cmaf-transcoder without GPU acceleration, use the following command:

```sh
docker compose up
```

#### 2. **With Intel GPU Support**

To use Intel hardware acceleration, use the command below:

```sh
docker compose --profile=intel up
```

#### 2. **With NVidia + Intel GPU Support**

For both NVIDIA and Intel GPU support.

Ensure the NVIDIA Container Toolkit is installed on your host machine, then run:

```sh
docker compose --profile=gpu up
```

## User-Manual

The **User Manual** is available in the project wiki. You can access it [here](https://github.com/sessystems/live-cmaf-transcoder/wiki).

## Contributing

We welcome contributions! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting a pull request.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
