#!/usr/local/bin/bash

COLOR='\e[44m'
NC='\e[49m' # No Color

PWD="$( cd ${0%/*}/.. && pwd -P )"

cd $PWD;

# Declare the variables
distributions="ubuntu debian"
ubuntu_versions="14.04 16.04"
debian_versions="8 9"
php_versions="5.6 7.0 7.1"
#php_versions="7.0" # For testing
force_build="false"
dry_run="false"
no_cache="false"
keep_container="false"
interactive="false"

# Check the options and override variables
while getopts d:v:p:tfcki option
do
 case "${option}"
 in
 d) distributions=${OPTARG};;
 v) VERSION=${OPTARG};;
 p) php_versions=${OPTARG};;
 t) dry_run="true";;
 f) force_build="true";;
 c) no_cache="true";;
 k) keep_container="true";;
 i) interactive="true";;
 esac
done

# Function that runs the test inside Docker
run_test() {
    # Declare function arguments
    local container_id=$(mktemp)
    local distribution=$1
    local version=$2
    local php_version=$3

    # Declare extra variables
    local extra_vars="php_fpm_version=${php_version}"
    local run_opts="--privileged"
    local init=/sbin/init
    local additional_packages=""

    local image=${distribution}:${version}
    local tag=${distribution}-${version}:ansible
    local role_path="/etc/ansible/roles/role_under_test/tests/test.yml"

    # Declare Docker build arguments
    local build_args="--build-arg image=${image}"

    # We need to install systemd-sysv on Debian 9 for Ansible service module to work
    if [ ${image} = "debian:9" ];
    then
        build_args="${build_args} --build-arg additional_packages=systemd-sysv"
    fi

    if [ ${no_cache} = "true" ];
    then
        build_args="--no-cache ${build_args}"
    fi

    printf "${COLOR}Start testing PHP ${php_version} on ${image}${NC}\n"

    # Check if we already have a built image or forced option
    local require_build=$(docker images ${tag} -q)
    if [ -z "${require_build}" ] || [ ${force_build} = "true" ]; then
        printf "${COLOR}Pull container ${image}${NC}\n"
        docker pull ${image}

        printf "${COLOR}Customize container${NC}\n"

        docker build --rm=true --file=tests/Dockerfile ${build_args} --tag=${tag} tests
    fi

    # Check if it is a dry run only for building the image
    if [ ${dry_run} = "true" ]; then
        return
    fi

    printf "${COLOR}Run container in detached state (${image})${NC}\n"
    docker run --detach --volume="${PWD}":/etc/ansible/roles/role_under_test:rw ${run_opts} ${tag} "${init}" >> "${container_id}"

    printf "${COLOR}Syntax check${NC}\n"
    docker exec --tty "$(cat ${container_id})" env TERM=xterm ansible-playbook ${role_path} --extra-vars "${extra_vars}" --syntax-check

    printf "${COLOR}Test role (${image})${NC}\n"
    docker exec --tty "$(cat ${container_id})" env TERM=xterm ansible-playbook ${role_path} --extra-vars "${extra_vars}"

    printf "${COLOR}Idempotence test (${image})${NC}\n"
    docker exec "$(cat ${container_id})" ansible-playbook ${role_path} --extra-vars "${extra_vars}" \
    | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)

    if [ ${interactive} = "true" ]; then
        docker exec -it "$(cat ${container_id})" bash
    fi

    if [ ${keep_container} = "true" ]; then
        cat ${container_id}
    else
        printf "${COLOR}Clean up (${image})${NC}\n"
        docker stop "$(cat ${container_id})"
        docker rm "$(cat ${container_id})"
    fi
}

# Loop to run the test on each defined distribution, os version and PHP version
for distribution in $distributions; do
    os_version_var_name=${distribution}_versions

    # Check if we define the
    if [ -n "${VERSION}" ]
    then
        os_versions="${VERSION}"
    else
        os_versions=${!os_version_var_name}
    fi

    for os_version in ${os_versions}; do
        for php_version in ${php_versions}; do
            run_test ${distribution} ${os_version} ${php_version}
        done
    done
done
