#!/usr/bin/env bash

start() {
  echo "Starting parity"
}

middle() {
    echo "Hello from shell!"
}

finish() {
    echo "Application finished"
}

start &&
    middle &&
    finish
