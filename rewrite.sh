for file in $(git log --name-only --pretty=oneline --full-index HEAD^^..HEAD public | grep -vE '^[0-9a-f]{40} ' | sort | uniq); do
  sed -i "s#cse291.programming.systems#cseweb.ucsd.edu/~dstefan/cse291-fall16#" $file  &
done
