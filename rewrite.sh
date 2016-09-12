for file in $(git log --name-only --pretty=oneline --full-index HEAD^^..HEAD | grep -vE '^[0-9a-f]{40} ' | sort | uniq); do
  echo $file
  sed -i "s#cse291.programming.systems#plsyssec.github.io/cse291-fall16#" $file 
done
