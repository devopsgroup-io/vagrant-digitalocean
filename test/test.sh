# if ! vagrant box list | grep digital_ocean 1>/dev/null; then
#     vagrant box add digital_ocean box/digital_ocean.box
# fi

if [ -z "$DO_CLIENT_ID" -o -z "$DO_API_KEY" ]; then
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
export PROVIDER=${PROVIDER:-digital_ocean}
orig_EXCLUDE=$EXCLUDE
for dist in $distributions; do

  export DISTRIBUTION=$dist
  export EXCLUDE=$orig_EXCLUDE
  echo TESTING $dist DISTRIBUTION
  if date &&
      $bootstrap_rsync vagrant up --provider=$PROVIDER $dist &&
      date &&
      vagrant ssh-config $dist &&
      date &&
      vagrant up $dist &&
      date &&
      check_provisioners_ran "$bootstrap_rsync" &&
      clear_provision_results &&
      vagrant provision $dist &&
      date &&
      check_provisioners_ran &&
      clear_provision_results &&
      date
  then
    echo "Passed initial tests for $dist"
    if [ -n "$EXCLUDE_ANSIBLE_AFTER_REBUILD" ]; then
      echo "Excluding ansible because it doesn't work after a rebuild"
      export EXCLUDE=$orig_EXCLUDE,ansible
    fi
    if $bootstrap_rsync vagrant rebuild $dist &&
      date && 
      ( [ -z "$bootstrap_rsync" ] || vagrant provision $dist && date ) &&
      date && 
      check_provisioners_ran && 
      date &&
      vagrant halt $dist &&
      date &&
      vagrant destroy $dist --force
    then
      echo Passed rebuild tests for $dist
    else
      echo "Failed initial tests for $dist, destroying VM"
      # Have to specify VMs otherwise vagrant complains if VirtualBox is missing
      vagrant destroy $dist --force
      exit 1
    fi
  else
    echo "Failed tests for $dist, destroying VM"
    # Have to specify VMs otherwise vagrant complains if VirtualBox is missing
    vagrant destroy $dist --force
    exit 1
  fi
done

cd ..
