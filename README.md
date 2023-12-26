# Doris Docker Builder

## Prerequisites

- The build script only works on **x64** Linux platform with docker installed.
- `vm.max_map_count` on host machine should be 2000000: `sysctl -w vm.max_map_count=2000000`.
- The swap should be disabled on host machine: `swapoff -a`.
- To prevent doris image from using a proxy setting, docker should has no proxy setting. Make sure there is no proxy setting in `~/.docker/config.json`.

## Build

Modify the doris version in `build_images.sh` as needed:

```bash
DORIS_VERSION="2.0.3"
```

Then run the script:

```bash
./build_images.sh
```

Alternatively, you can prepare an uncompressed folder in advance and run:

```bash
# You still need to specify the version in the script first.
./build_images.sh --skip-download 
```

## Run

Replace the docker image names of FE and BE in the `dokcer-compose.yaml` file to the names of images you just built. Then you can run the cluster using `docker compose up` command (see files under `docker-compose-demo/docker-compose` folder).

## Other

To clean doris data on host machine, run:

```bash
./clean_data.sh
```
