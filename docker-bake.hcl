target "_common_labels" {
    labels = {
        "maintainer"="SES Engineering (Luxembourg)"
        # The date and time on which the image was built (string, RFC 3339 date-time).
        "org.opencontainers.image.created" = "${timestamp()}"
        # Contact details of the people or organization responsible for the image (freeform string).
        "org.opencontainers.image.authors" = "Yannick Poirier <yannick.poirier@ses.com>; Xavier Scholtes <xavier.scholtes@ses.com>"
        # URL to find more information on the image (string).
        "org.opencontainers.image.url" = ""
        # URL to get documentation on the image (string).
        "org.opencontainers.image.documentation" = ""
        # URL to the source code for building the image (string).
        "org.opencontainers.image.source" = ""
        # Version of the packaged software (string).
        "org.opencontainers.image.version" = "0.0.1"
        # Source control revision identifier for the image (string).
        "org.opencontainers.image.revision" = ""
        # Name of the distributing entity, organization, or individual (string).
        "org.opencontainers.image.vendor" = "SES Engineering (Luxembourg)"
        # License(s) under which contained software is distributed (string, SPDX License List).
        "org.opencontainers.image.licenses" = "Apache-2.0"
        # Name of the reference for a target (string).
        "org.opencontainers.image.ref.name" = ""
        # Human-readable title of the image (string).
        "org.opencontainers.image.title" = "live-cmaf-transcoder"
        # Human-readable description of the software packaged in the image (string).
        "org.opencontainers.image.description" = "Re-encode live streams into the Common Media Application Format (CMAF).\nOutput streams in both DASH and HLS.\nIt uses hardware acceleration (GPUs)."
    }
}

variable "REGISTRY_DOCKER" {
  default = "docker.io"
}

variable "REGISTRY_GITHUB" {
  default = "ghcr.io"
}

variable "ORGREPOS" {
  default = "sessystems"
}

variable "VERSION" {
  description = "The version tag for the Docker image"
  default = "" # Default is empty, we will set it in the workflow
}

group "default" {
    targets = [
        "live-cmaf-transcoder-nv-11-1-ffmpeg-7-0",
        #"live-cmaf-transcoder-demo-nv-11-1-ffmpeg-7-0",
    ]
}

group "all" {
    targets = [
        "live-cmaf-transcoder",
    ]
}

target "live-cmaf-transcoder-base-dev" {
    dockerfile = "docker/live-cmaf-transcoder-base-dev.Dockerfile"
    context = "."
    name="live-cmaf-transcoder-base-dev-nv-${item.nv-tag}"
    matrix = {
        item = [
            {
                nv-tag="12-0"
                nvidia-dev = "nvidia/cuda:12.4.1-devel-ubuntu22.04"
                nv-codec-headers = "sdk/12.0"
            },
            {
                nv-tag="11-1"
                nvidia-dev = "nvidia/cuda:12.4.1-devel-ubuntu22.04"
                nv-codec-headers = "sdk/11.1"
            }
        ]
    }
    contexts = {
        nvidia-dev = "docker-image://${item.nvidia-dev}"
    }
    args = {
        NV_CODEC_HEADERS_VERSION = "${item.nv-codec-headers}"
    }
    
}

target "ffmpeg" {
    dockerfile="docker/ffmpeg-${item.variant}.Dockerfile"
    name="ffmpeg-${item.variant}-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
    contexts = { 
        cmaf-dev = "target:live-cmaf-transcoder-base-dev-nv-${item.nv-tag}"
    }
    matrix = {
        item = [
            {
                variant = "gpl",
                ffmpeg-tag="7-0"
                nv-tag="12-0"
            },
            {
                variant = "non-free",
                ffmpeg-tag="7-0"
                nv-tag="12-0"
            },
            {
                variant = "gpl",
                ffmpeg-tag="7-0"
                nv-tag="11-1"
            },
            {
                variant = "non-free",
                ffmpeg-tag="7-0"
                nv-tag="11-1"
            }
        ]
    }
    args = {
        FFMEPG_BRANCH = replace("${item.ffmpeg-tag}", "-", ".")
    }
    
}

target "cmaf-frontend" {
    dockerfile="docker/frontend.Dockerfile"
}

target "backend" {
    dockerfile="docker/backend.Dockerfile"
    name="backend-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
    contexts = {
        cmaf-dev = "target:live-cmaf-transcoder-base-dev-nv-${item.nv-tag}"
        cmaf-frontend = "target:cmaf-frontend"
    }
    matrix = {
        item = [
            {
                nv-tag="12-0"
                ffmpeg-tag="7-0"
            },
            {
                nv-tag="11-1"
                ffmpeg-tag="7-0"
            }
        ]
    }
    
}

target "live-cmaf-transcoder" {
    inherits = ["_common_labels"]
    dockerfile="docker/live-cmaf-transcoder.Dockerfile"
    name="live-cmaf-transcoder-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
    contexts = {
        backend = "target:backend-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
        ffmpeg-gpl = "target:ffmpeg-gpl-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
        ffmpeg-non-free = "target:ffmpeg-non-free-nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}"
        nvidia-runtime = "docker-image://${item.nvidia-runtime}"
    }
    tags = [
        "${REGISTRY_GITHUB}/${ORGREPOS}/live-cmaf-transcoder:nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}",
        notequal("",VERSION) ? "${REGISTRY_GITHUB}/${ORGREPOS}/live-cmaf-transcoder:nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}-v${VERSION}": "",
        equal("latest","${item.tag}") ? "${REGISTRY_GITHUB}/${ORGREPOS}/live-cmaf-transcoder:${item.tag}": "",
        notequal("",VERSION) && equal("latest","${item.tag}") ? "${REGISTRY_GITHUB}/${ORGREPOS}/live-cmaf-transcoder:${VERSION}": "",
        "${REGISTRY_DOCKER}/${ORGREPOS}/live-cmaf-transcoder:nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}",
        notequal("",VERSION) ? "${REGISTRY_DOCKER}/${ORGREPOS}/live-cmaf-transcoder:nv-${item.nv-tag}-ffmpeg-${item.ffmpeg-tag}-v${VERSION}": "",
        equal("latest","${item.tag}") ? "${REGISTRY_DOCKER}/${ORGREPOS}/live-cmaf-transcoder:${item.tag}": "",
        notequal("",VERSION) && equal("latest","${item.tag}") ? "${REGISTRY_DOCKER}/${ORGREPOS}/live-cmaf-transcoder:${VERSION}": "",
    ] 
    matrix = {
        item = [
            {
                nv-tag="12-0"
                ffmpeg-tag="7-0"
                nvidia-runtime = "nvidia/cuda:12.4.1-runtime-ubuntu22.04"
                tag = "latest"
            },
            {
                nv-tag="11-1"
                ffmpeg-tag="7-0"
                nvidia-runtime = "nvidia/cuda:12.4.1-runtime-ubuntu22.04"
                tag = ""
            }
        ]
    }
    
}


