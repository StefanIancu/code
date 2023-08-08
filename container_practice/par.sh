#!/usr/bin/env bash

start() {
  echo "Starting parity"
}

check_par() {
    read answer 
    if answer % 2 == 0
    then
        echo "Round number!"
    else
        echo "Not a round number!"
    fi
}

finish() {
    echo "Application finished"
}

start &&
    check_par &&
    finish
