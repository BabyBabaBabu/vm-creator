Function to sanitize the Conf file
  sample code
  How about using whitelisting instead and rejecting the file if something turns out wrong:
  https://wiki.bash-hackers.org/howto/conffile#secure_it User sirat

  #!/bin/bash
  CONFIG_PATH='./bashconfig.conf'
  # commented lines, empty lines und lines of the from choose_ANYNAME='any.:Value' are valid
  CONFIG_SYNTAX="^\s*#|^\s*$|^[a-zA-Z_]+='[^']*'$"
  # check if the file contains something we don't want
  if egrep -q -v "${CONFIG_SYNTAX}" "$CONFIG_PATH"; then
    echo "Error parsing config file ${CONFIG_PATH}." >&2
    echo "The following lines in the configfile do not fit the syntax:" >&2
    egrep -vn "${CONFIG_SYNTAX}" "$CONFIG_PATH"
    exit 5
  fi
  # otherwise go on and source it:
  source "${CONFIG_PATH}"

Check if VBox is install
  Function to check OS type
  if debian
    checkDebDeps
  elif Ubuntu
    checkDebDeps
  elif Arch
    checkArchDeps
  else
    echo -e "Unknown OS Type Try checking their Official Docs for support"
  fi

  Function to Check Debian/Ubuntu Dependencies
  if [[ dpkg -s virtualbox-dkms  && dpkg -s virtualbox-ext-pack  && dpkg -s virtualbox-qt ]]
    return true
  else
    echo -e "Dependencies are not met; Would you like installing them"
  fi  

  Function to Check Arch Dependencies
  if [[ pacman?? -s virtualbox-dkms  && dpkg -s virtualbox-ext-pack  && dpkg -s virtualbox-qt ]]
    return true
  else
    echo -e "Dependencies are not met; Would you like installing them"
  fi

Script to apply patches
 locate debian_postinstall.sh && ubuntu_preseed.cfg
  check diff with fixed files from repo
  prompt user to run patch
  run patch