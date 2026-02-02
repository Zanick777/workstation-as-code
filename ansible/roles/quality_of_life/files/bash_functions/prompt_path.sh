#!/usr/bin/env bash

short_pwd() {
  local pwd="${PWD/#$HOME/~}"
  local IFS='/'
  read -ra parts <<< "$pwd"

  local count=${#parts[@]}
  if (( count > 3 )); then
    echo "${parts[0]}/../${parts[count-2]}/${parts[count-1]}"
  else
    echo "$pwd"
  fi
}
