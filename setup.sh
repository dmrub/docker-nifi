#!/bin/bash

set -eo pipefail

scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

prop_replace 'nifi.flow.configuration.file' "${NIFI_FLOW_CONFIG_FILE:=./conf/flow.xml.gz}"
prop_replace 'nifi.flow.configuration.archive.enabled' "${NIFI_FLOW_CONFIG_ARCHIVE_ENABLED:=true}"
prop_replace 'nifi.flow.configuration.archive.dir' "${NIFI_FLOW_CONFIG_ARCHIVE_DIR:=./conf/archive/}"
prop_replace 'nifi.flow.configuration.archive.max.time' "${NIFI_FLOW_CONFIG_ARCHIVE_MAX_TIME:=30 days}"
prop_replace 'nifi.flow.configuration.archive.max.storage' "${NIFI_FLOW_CONFIG_ARCHIVE_MAX_STORAGE:=500 MB}"
prop_replace 'nifi.flow.configuration.archive.max.count' "${NIFI_FLOW_CONFIG_ARCHIVE_MAX_COUNT:=}"
prop_replace 'nifi.authorizer.configuration.file' "${NIFI_AUTHORIZER_CONFIG_FILE:=./conf/authorizers.xml}"
prop_replace 'nifi.login.identity.provider.configuration.file' "${NIFI_LOGIN_IDENTITY_PROVIDER_CONFIG_FILE:=./conf/login-identity-providers.xml}"
prop_replace 'nifi.state.management.configuration.file' "${NIFI_STATE_MANAGEMENT_CONFIG_FILE:=./conf/state-management.xml}"

prop_replace 'nifi.templates.directory' "${NIFI_TEMPLATES_DIR:=./conf/templates}"
prop_replace 'nifi.nar.library.directory' "${NIFI_NAR_LIBRARY_DIR:=./lib}"
prop_replace 'nifi.nar.working.directory' "${NIFI_NAR_WORKING_DIR:=./work/nar/}"
prop_replace 'nifi.documentation.working.directory' "${NIFI_DOCUMENTATION_WORKING_DIR:=./work/docs/components}"
prop_replace 'nifi.database.directory' "${NIFI_DATABASE_DIR:=./database_repository}"
prop_replace 'nifi.flowfile.repository.directory' "${NIFI_FLOWFILE_REPOSITORY_DIR:=./flowfile_repository}"
prop_replace 'nifi.content.repository.directory.default' "${NIFI_CONTENT_REPOSITORY_DIR_DEFAULT:=./content_repository}"
prop_replace 'nifi.provenance.repository.directory.default' "${NIFI_PROVENANCE_REPOSITORY_DIR_DEFAULT:=./provenance_repository}"
prop_replace 'nifi.web.war.directory' "${NIFI_WEB_WAR_DIR:=./lib}"
prop_replace 'nifi.web.jetty.working.directory' "${NIFI_WEB_JETTY_WORKING_DIR:=./work/jetty}"

nifi_fn() {
    if [[ "$1" == /* ]]; then
        echo "$1"
    else
        echo "${NIFI_HOME}/$1"
    fi
}

nifi_fix_dir_perm() {
    local d
    d=$1
    echo "Fix permission for $d"
    chown -R nifi:nifi "$d"
    while [[ -n "$d" && "$d" != / ]]; do
        chmod go+rx,u+rwx "$d"
        d=$(dirname "$d")
    done
}

nifi_file() {
    local dn
    dn=$(dirname "$(nifi_fn "$1")")
    echo "Create directory $dn"
    mkdir -p "$dn" && nifi_fix_dir_perm "$dn"
    if [[ -n "$2" ]]; then
        local src_file
        src_file=$(nifi_fn "$2")
        if [[ ! -e "$1" && -e "$src_file" ]]; then
            echo "Copy $src_file to $1"
            cp "$src_file" "$1"
            chown nifi:nifi "$1"
        fi
    fi
}

nifi_dir() {
    local dn
    dn=$(nifi_fn "$1")
    echo "Create directory $dn"
    mkdir -p "$dn" && nifi_fix_dir_perm "$dn"
}

nifi_file "${NIFI_FLOW_CONFIG_FILE}" './conf/flow.xml.gz'
nifi_dir "${NIFI_FLOW_CONFIG_ARCHIVE_DIR}"
nifi_file "${NIFI_AUTHORIZER_CONFIG_FILE}" './conf/authorizers.xml'
nifi_file "${NIFI_LOGIN_IDENTITY_PROVIDER_CONFIG_FILE}" './conf/login-identity-providers.xml'
nifi_file "${NIFI_STATE_MANAGEMENT_CONFIG_FILE}" './conf/state-management.xml'
nifi_dir "${NIFI_TEMPLATES_DIR}"
nifi_dir "${NIFI_NAR_LIBRARY_DIR}"
nifi_dir "${NIFI_NAR_WORKING_DIR}"
nifi_dir "${NIFI_DOCUMENTATION_WORKING_DIR}"
nifi_dir "${NIFI_DATABASE_DIR}"
nifi_dir "${NIFI_FLOWFILE_REPOSITORY_DIR}"
nifi_dir "${NIFI_CONTENT_REPOSITORY_DIR_DEFAULT}"
nifi_dir "${NIFI_PROVENANCE_REPOSITORY_DIR_DEFAULT}"
nifi_dir "${NIFI_WEB_WAR_DIR}"
nifi_dir "${NIFI_WEB_JETTY_WORKING_DIR}"

set -x
mkdir -p "${NIFI_HOME}/logs"
touch "${NIFI_HOME}/logs/nifi-app.log"
chown -R nifi:nifi \
      "${NIFI_LOG_DIR}" \
      "${NIFI_HOME}/conf" \
      "${NIFI_HOME}/database_repository" \
      "${NIFI_HOME}/flowfile_repository" \
      "${NIFI_HOME}/content_repository" \
      "${NIFI_HOME}/provenance_repository" \
      "${NIFI_HOME}/state" \

exec gosu nifi "${NIFI_HOME}/../scripts/start.sh"
