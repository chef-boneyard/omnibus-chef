#!/bin/bash
#
# Setup Opscode Client
#

CONFIG_DIR=/etc/chef
USAGE="usage: $0 [-v validation_key] ([-h hosted_chef_org] || [-u url])"

validation_key=
organization=
chef_url=

while getopts o:u:v: opt
do
    case "$opt" in
      v)  validation_key="${OPTARG}";;
      h)  organization="${OPTARG}"; chef_url="https://api.opscode.com/organizations/${OPTARG}";;
      u)  chef_url="${OPTARG}";;
      \?)		# unknown flag
      	  echo >&2 ${USAGE}
	  exit 1;;
    esac
done
shift `expr ${OPTIND} - 1`

if [ "" != "$chef_url" ]; then
  mkdir -p ${CONFIG_DIR} || error_exit "Cannot create ${CONFIG_DIR}!"
  (
  cat <<'EOP'
log_level :info
log_location STDOUT
EOP
  ) > ${CONFIG_DIR}/client.rb
  if [ "" != "$chef_url" ]; then
    echo "chef_server_url '${chef_url}'" >> ${CONFIG_DIR}/client.rb
  fi
  if [ "" != "$organization" ]; then
    echo "validation_client_name '${organization}-validator'" >> ${CONFIG_DIR}/client.rb
  fi
  chmod 644 ${CONFIG_DIR}/client.rb
fi

if [ "" != "$validation_key" ]; then
  cp ${validation_key} ${CONFIG_DIR}/validation.pem || error_exit "Cannot copy the validation key!"
  chmod 600 ${CONFIG_DIR}/validation.pem
fi
