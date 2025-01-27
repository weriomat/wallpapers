#!/usr/bin/env bash

for i in ./wallpapers/*; do
  echo "$i"
  kitty +kitten icat "$i"
  read -r -p "Continue (y/n) or remove (r)?" choice
  case "$choice" in 
    y|Y ) continue;;
    n|N ) exit;;
    r|R ) rm -v "$i";;
    * ) echo "invalid";;
  esac

done
