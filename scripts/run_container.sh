#!/usr/bin/env bash
#
# Created on Wed Sep 04 2024 18:05:06
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute
#
# Copyright Ⓒ 2024 Mukai (Tom Notch) Yu
#

. "$(dirname "$0")"/variables.sh

xhost +local:*

if [ ! -f "${XAUTH}" ]; then
	touch "${XAUTH}"
	xauth_list=$(xauth nlist "${DISPLAY}" | sed -e 's/^..../ffff/')
	if [ -n "${xauth_list}" ]; then
		echo "${xauth_list}" | xauth -f "${XAUTH}" nmerge -
	fi
	chmod a+r "${XAUTH}"
fi

if [ "$(docker ps -a -q -f name="${CONTAINER_NAME}")" ]; then
	echo "A container with name ""${CONTAINER_NAME}"" is running, force removing it"
	docker rm -f "${CONTAINER_NAME}"
	echo "Done"
fi

docker run \
	--name "${CONTAINER_NAME}" \
	--hostname "$(hostname)" \
	--privileged \
	--cpus "${AVAILABLE_CORES}" \
	--user root \
	--network host \
	--ipc host \
	--pid host \
	--ulimit core=-1 \
	--group-add audio \
	--group-add video \
	--volume=":" \
	-e DISPLAY="${DISPLAY}" \
	-e XAUTHORITY="${XAUTH}" \
	-e QT_X11_NO_MITSHM=1 \
	-v /var/lib/systemd/coredump/:/cores \
	-v "${XSOCK}":"${XSOCK}" \
	-v "${XAUTH}":"${XAUTH}" \
	-v "${HOME}"/.Xauthority:"${HOME_FOLDER}"/.Xauthority:rw \
	-v "${BASE_FOLDER}":"${HOME_FOLDER}"/"${CODE_FOLDER}" \
	-w "${HOME_FOLDER}"/"${CODE_FOLDER}" \
	--rm \
	-itd "${DOCKER_USER}"/"${IMAGE_NAME}":"${IMAGE_TAG}"
