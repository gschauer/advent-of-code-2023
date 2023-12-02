#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# part 1

function subst1 {
  # if a string contains 2 digits, print them
  # otherwise, print the digit twice
  # join the lines with "+", trim the trailing "+" if present and sum them up
  gsed -En \
    -e "s/^[^0-9]*([0-9]).*[^0-9]*([0-9])[^0-9]*$/\1\2/p" \
    -e "s/^[^0-9]*([0-9])[^0-9]*$/\1\1/p" "$1" |
    tr $'\n' "+" | sed -e "s/+$//" | bc
}

subst1 "${1:-input.txt}"

# part 2

declare -A words=([zero]=0 [one]=1 [two]=2 [three]=3 [four]=4 [five]=5 [six]=6 [seven]=7 [eight]=8 [nine]=9)

function subst2 {
  local in="$1"
  local prefix="$2"
  local postfix="$3"
  local pattern x
  # prepare a wildcard pattern in the form p1*|p2* or *p1|*p2
  pattern="$(echo -n "${prefix}${!words[*]}" | sed -E "s/ /${postfix}|${prefix}/g")${postfix}"

  if [[ "$1" == ${prefix}[0-9]${postfix} || -z "$1" ]]; then
    # if the first/last character is a digit, print it
    [[ "${postfix}" == "*" ]] || in="$(rev <<<"${in}")"
    echo "${in:0:1}"
  elif [[ "${prefix}" == "*" && "$in" == @(${pattern}) ]]; then
    # look for a number word at the end
    x="$(echo -n "$in" | sed -E "s/.*(${pattern//\*/})$/\1/")"
    echo -n "${words[$x]}" | cut -c 1 | ghead -c -1
  elif [[ "${prefix}" == "" && "${in}" == @(${pattern}) ]]; then
    # look for a number word at the beginning
    x="$(echo -n "${in}" | sed -E "s/^(${pattern//\*/}).*/\1/")"
    echo -n "${words[$x]}" | cut -c 1 | ghead -c -1
  elif [[ "${prefix}" == "" ]]; then
    # cut off the first character
    subst2 "${1:1}" "${prefix}" "${postfix}"
  else
    # cut off the last character
    subst2 "${1:0:-1}" "${prefix}" "${postfix}"
  fi
}

sum="0"
while read -r l; do
  # concatenate +xy+xy+xy for each first (x) and last (y) number
  sum+="+$(subst2 "$l" "" "*")$(subst2 "$l" "*" "")"
done <"${1:-input.txt}"
bc <<<"${sum}"
