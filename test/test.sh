#!/bin/bash

# if ! vagrant box list | grep digital_ocean 1>/dev/null; then
#     vagrant box add digital_ocean box/digital_ocean.box
# fi

export PROVIDER=${PROVIDER:-digital_ocean}

if [ digital_ocean = "$PROVIDER" -a '(' -z "$DO_CLIENT_ID" -o -z "$DO_API_KEY" ')' ]; then
  echo "WARNING: env vars DO_CLIENT_ID and/or DO_API_KEY are not set!"
  echo "[these tests will fail if the client_id and api_key are not set in the global Vagrantfile]"
fi

cd test
set -x

distributions=${DISTRIBUTIONS:-ubuntu centos}

clear_provision_results()
{
  vagrant ssh $dist -c 'rm -f /tmp/folder/*' -- -n &&
  vagrant ssh $dist -c 'ls -la /tmp/folder' -- -n &&
  echo 'removed /tmp/folder/file file from VM'
}

pass()
{
    date
    echo "Passed $* for $dist"
}

fail()
{
    date
    echo "Failed $* for $dist, destroying VM"
    vagrant destroy $dist --force
    exit 1
}

check_provisioners_ran()
{
  shell_only=$1
  # shell MUST be able to run!
  test_cmd='test -s /tmp/folder/file_from_shell'
  case "$shell_only" in
  '')
    case "$EXCLUDE" in
    *ansible*)
      ;;
    *)
      test_cmd="$test_cmd -a -s /tmp/folder/file_from_ansible"
      ;;
    esac
    case "$EXCLUDE" in
    *chef*)
      ;;
    *)
      test_cmd="$test_cmd -a -s /tmp/folder/file_from_chef"
      ;;
    esac
    case "$EXCLUDE" in
    *file*)
      ;;
    *)
      test_cmd="$test_cmd -a -s /tmp/folder/file_from_file"
      ;;
    esac
    case "$EXCLUDE" in
    *puppet*)
      ;;
    *)
      test_cmd="$test_cmd -a -s /tmp/folder/file_from_puppet"
      ;;
    esac
    case "$EXCLUDE" in
    *salt*)
      ;;
    *)
      test_cmd="$test_cmd -a -s /tmp/folder/file_from_salt"
      ;;
    esac
    ;;
  esac

  echo "Files make by provisioners with EXCLUDE=$EXCLUDE"
  vagrant ssh $dist -c 'ls -la /tmp/folder' -- -n &&
  vagrant ssh $dist -c "$test_cmd" -- -n &&
  echo "$dist has /tmp/folder files" &&
  ! vagrant ssh $dist -c 'test -s /tmp/no-such-file' -- -n &&
  echo 'vagrant ssh is returning exit status'
}

bootstrap_rsync=
case "$INSTALL_RSYNC" in
?*)
  # rsync has to be bootstrapped for fedora
  bootstrap_rsync='env BOOTSTRAP_RSYNC=true'
  ;;
esac
for dist in $distributions; do

  export DISTRIBUTION=$dist
  echo TESTING $dist DISTRIBUTION
  if date &&
      $bootstrap_rsync vagrant up --provider=$PROVIDER $dist &&
      date &&
      vagrant ssh-config $dist &&
      date &&
      vagrant up $dist &&
      date &&
      check_provisioners_ran "$bootstrap_rsync" &&
      clear_provision_results 
  then
    pass initial tests
  else
    fail initial tests
  fi
  if [ -n "$RELOAD_BEFORE_PROVISION" ]; then
    if echo "Reloading before running provision" &&
      vagrant reload $dist
    then
      pass reload before provision
    else
      fail reload before provision
    fi
  fi
  if echo "Running provision" &&
      vagrant provision $dist &&
      date &&
      check_provisioners_ran &&
      clear_provision_results
  then
    pass provision
  else
    fail provision
  fi
  if [ digital_ocean = "$PROVIDER" ]; then
    if $bootstrap_rsync vagrant rebuild $dist &&
      date && 
      ( [ -z "$bootstrap_rsync" ] || vagrant provision $dist && date ) &&
      date && 
      check_provisioners_ran && 
      date
    then
      pass rebuild tests
    else
      fail rebuild tests
    fi
  fi
  if vagrant halt $dist &&
    date &&
    vagrant destroy $dist --force
  then
    pass halt and destroy
  else
    fail halt and destroy
  fi
done

cd ..
