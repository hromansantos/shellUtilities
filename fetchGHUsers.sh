#!/bin/bash - 
#===============================================================================
#
#          FILE: fetchGHUsers.sh
# 
#         USAGE: ./fetchGHUsers.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Hugo Roman (HRS), $GITHUB_USER@redventures.com
#  ORGANIZATION: 
#       CREATED: 08/05/2019 14:13:47
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

GITHUB_USER=$1
GITHUB_MAX_RESULTS_PERPAGE=100

for org in `curl -u "$GITHUB_USER:$GITHUB_AUTH_TOKEN" "https://api.github.com/user/orgs"|jq -r '.[]|.login'`;do
  LAST_PAGE_CURL_COMMAND=$(curl -I -u "$GITHUB_USER:$GITHUB_AUTH_TOKEN" "https://api.github.com/orgs/${org}/members?per_page=$GITHUB_MAX_RESULTS_PERPAGE")
  LAST_PAGE=$(echo $LAST_PAGE_CURL_COMMAND|grep Link:|grep -Eo '&page=[0-9]'|sed -e 's/&page\=//g'|tail -1)

  [ -e "${org}.json" ] && rm "${org}.json"

  if [ -z "$LAST_PAGE" ]; then 
    curl -u "$GITHUB_USER:$GITHUB_AUTH_TOKEN" "https://api.github.com/orgs/${org}/members?per_page=$GITHUB_MAX_RESULTS_PERPAGE" >> ${org}.json
  else
    for (( i=1; i<=${LAST_PAGE}; i++)); do
      curl -u "$GITHUB_USER:$GITHUB_AUTH_TOKEN" "https://api.github.com/orgs/${org}/members?per_page=$GITHUB_MAX_RESULTS_PERPAGE&page=${i}" >> ${org}.json
    done
  fi
done
