#!/bin/bash
# nixwatch.sh
# Customise these to suit your environment
MINFREE=524288			# safe minimum free memory
PREFIX="/usr/local/bin"		# path to spectrecoind
DATADIR=~/.nix		# nix datadir

# Announce ourselves
echo "NIX watchdog script running at" `date`

# Start off by looking for running daemon
PID=$(pidof nixd)

# Start it if it's not running
if [[ $? -eq 1 ]]; then
  echo "NIX is not running. Removing any old flags and starting it."
  rm -f "${DATADIR}/nix.pid" "${DATADIR}/.lock"
  ${PREFIX}/nixd -daemon &

# Check free memory if it is running
else
  echo "nix is running with PID=${PID}. Checking free memory."
  TMP=$("mktemp")
  free > ${TMP}
  FREEMEM=$(awk '$1 ~ /Mem|Swap/ {sum += $4} END {print sum}' ${TMP})
  rm ${TMP}

# If free memory is getting low, pre-emptively stop the daemon
  if [[ ${FREEMEM} -lt ${MINFREE} ]]; then
    echo "Total free memory is less than minimum. Shutting down NIX."
    ${PREFIX}/nix-cli stop

# Allow up to 10 minutes for it to shutdown gracefully
    for ((i=0; i<10; i++)); do
      echo "...waiting..."
      sleep 60
      if  [[ $(ps -p ${PID} | wc -l) -lt 2 ]]; then
        break
      fi
    done

# If it still hasn't shutdown, terminate with extreme prejudice
    if [[ ${i} -eq 10 ]]; then
      echo "Shutdown still incomplete, killing the daemon."
      kill -9 ${PID}
      sleep 10
      rm -f "${DATADIR}/nix.pid" "${DATADIR}/.lock"
    fi

# Restart it if we stopped it
    echo "Starting nixd."
    ${PREFIX}/nixd -daemon &

# Nothing to do if there was enough free memory
  else
    echo "Total free memory is above safe minimum, doing nothing."
  fi
fi