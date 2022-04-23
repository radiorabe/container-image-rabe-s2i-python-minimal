# RaBe S2I Python Minimal Image

The RaBe S2I Python Minimal Image resembles a classic [sclorg/s2i-python](https://github.com/sclorg/s2i-python-container/)
image with the main difference being that it is based on the RaBe UBI8 Minimal Image. It's main use if as a build
container for building wheels. 

The image is based on the [RaBe S2I Base Image](https://github.com/radiorabe/container-image-rabe-s2i-base-minimal) and
[RaBe S2I Core Image](https://github.com/radiorabe/container-image-rabe-s2i-core-minimal) which is in turn based on the
[Red Hat Universal Base Image 8 Minimal](https://catalog.redhat.com/software/containers/ubi8/ubi-minimal/5c359a62bed8bd75a2c3fba8)
container provided by Red Hat via [RaBe Universal Base Image 8 Minimal](https://github.com/radiorabe/container-image-ubi8-minimal).

## Features

- Based on RaBe Universal Base Image 8 Minimal
- Contains the latest python and a pip with wheels support
- Build wheels for installing into [RaBe Python Base Image Minimal](https://github.com/radiorabe/container-image-python-minimal)

## Usage

Create a multistage Dockerfile using both `s2i-python` and `python-minimal` as bases. Replace `latest` with exact versions in the following example.

```Dockerfile
FROM ghcr.io/radiorabe/s2i-python:latest AS build

COPY ./ /opt/app-root/src

RUN python3 setup.py bdist_wheel


FROM gchr.io/radiorabe/python-minimal:latest AS app

COPY --from=build /opt/app-root/src/dist/*.whl /tmp/dist/

RUN    python3 -mpip --no-cache-dir install /tmp/dist/*.whl \
    && rm -rf /tmp/dist/

USER nobody

CMD ["python3", "-mapp"]
```

## Release Management

The CI/CD setup uses semantic commit messages following the [conventional commits standard](https://www.conventionalcommits.org/en/v1.0.0/).
There is a GitHub Action in [.github/workflows/semantic-release.yaml](./.github/workflows/semantic-release.yaml)
that uses [go-semantic-commit](https://go-semantic-release.xyz/) to create new
releases.

The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. **fix:** a commit of the type `fix` patches gets released with a PATCH version bump
1. **feat:** a commit of the type `feat` gets released as a MINOR version bump
1. **BREAKING CHANGE:** a commit that has a footer `BREAKING CHANGE:` gets released as a MAJOR version bump
1. types other than `fix:` and `feat:` are allowed and don't trigger a release

If a commit does not contain a conventional commit style message you can fix
it during the squash and merge operation on the PR.

## Build Process

The CI/CD setup uses the [Docker build-push Action](https://github.com/docker/build-push-action) to publish container images. This is managed in [.github/workflows/release.yaml](./.github/workflows/release.yaml).

## License

This application is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, version 3 of the License.

## Copyright

Copyright (c) 2022 [Radio Bern RaBe](http://www.rabe.ch)
