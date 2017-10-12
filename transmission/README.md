Shows only Torrent number and name:

```transmission-remote -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p'```

Shows only Torrent number of the first file with the $name:

```transmission-remote -l | grep -i $name | sed -n 's/ *\([0-9]\+\).*/\1/p'```
