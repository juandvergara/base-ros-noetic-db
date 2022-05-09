# parameters
ARG REPO_NAME="move-duckie-robotarium"
ARG MAINTAINER="Juan D. Vergara (juan_dav.vergara@uao.edu.co)"
ARG DESCRIPTION="Base image containing common libraries and environment setup for ROS applications."
ARG ICON="square"

#ARG ARCH=arm32v7
#ARG DISTRO=daffy
#ARG BASE_TAG=${DISTRO}-${ARCH}
#ARG BASE_IMAGE=dt-commons
#ARG LAUNCHER=default

# define base image
FROM ros:noetic-ros-base

# recall all arguments
ARG REPO_NAME
ARG DESCRIPTION
ARG MAINTAINER
ARG ICON
ARG ARCH
ARG DISTRO
ARG ROS_DISTRO
ARG BASE_TAG
ARG BASE_IMAGE
ARG LAUNCHER

# configure environmenti
ENV SOURCE_DIR /code
ENV LAUNCH_DIR /launch
ENV CATKIN_WS_DIR "${SOURCE_DIR}/catkin_ws"
ENV ROS_LANG_DISABLE gennodejs:geneus:genlisp

# copy binaries
COPY ./assets/bin/. /usr/local/bin/


# define and create repository path
ARG REPO_PATH="${CATKIN_WS_DIR}/src/${REPO_NAME}"
ARG LAUNCH_PATH="${LAUNCH_DIR}/${REPO_NAME}"
RUN mkdir -p "${REPO_PATH}"
RUN mkdir -p "${LAUNCH_PATH}"
WORKDIR "${REPO_PATH}"

# create repo directory
RUN mkdir -p "${REPO_PATH}"

# install apt dependencies
COPY ./dependencies-apt.txt "${REPO_PATH}/"
RUN dt-apt-install "${REPO_PATH}/dependencies-apt.txt"

# install python dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
RUN echo PIP_INDEX_URL=${PIP_INDEX_URL}

# upgrade PIP
RUN python3 -m pip install -U pip

COPY ./dependencies-py3.* "${REPO_PATH}/"
RUN python3 -m pip install  -r ${REPO_PATH}/dependencies-py3.txt

# copy the source code
COPY ./packages "${REPO_PATH}/packages"

# build packages
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
   catkin build \
   --workspace ${CATKIN_WS_DIR}/

# install launcher scripts
COPY ./launchers/. "${LAUNCH_PATH}/"
# RUN dt-install-launchers "${LAUNCH_PATH}"

# define default command
# CMD ["bash", "-c", "dt-launcher-${DT_LAUNCHER}"]

# store module metadata
LABEL org.duckietown.label.module.type="${REPO_NAME}" \
    org.duckietown.label.module.description="${DESCRIPTION}" \
    org.duckietown.label.module.icon="${ICON}" \
    org.duckietown.label.architecture="${ARCH}" \
    org.duckietown.label.code.location="${REPO_PATH}" \
    org.duckietown.label.code.version.distro="${DISTRO}" \
    org.duckietown.label.base.image="${BASE_IMAGE}" \
    org.duckietown.label.base.tag="${BASE_TAG}" \
    org.duckietown.label.maintainer="${MAINTAINER}"

WORKDIR "${CATKIN_WS_DIR}"
