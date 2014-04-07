#!/usr/bin/awk -f
# Read a list of newline-separated file names, a blank line, then a
# newline-separated list of path names on stdin and return the hash of
# a new git tree that excludes the listed files and paths from any
# subtree in addition to any files excluded by gitattribues
# export-ignore.
#
function check_attr(attr,file,  cmd) {
  cmd = "git check-attr -z " attr " -- " file " | tr '\\0' '\\n' | tail -n1"
  cmd | getline
  if ($1 == "set") {
    return 1
  } else {
    return 0
  }
  close(cmd)
}
function remktree(tree,parent,  r,w,mode,type,hash,name,excluded) {
  r = "git ls-tree " tree
  w = "ID=" tree " git mktree"
  while ((r | getline)) {
    mode = $1
    type = $2
    hash = $3
    name = $4
    excluded = 0
    if (check_attr("export-ignore",parent name)) {
      #print "excluding " parent name
      excluded++
    } else {
      for (x in wcexcludes) {
        if (name == wcexcludes[x]) {
          #print "excluding " parent name
          excluded++
          break
        }
      }
      for (x in excludes) {
        if (parent name == excludes[x]) {
          #print "excluding " parent name
          excluded++
          break
        }
      }
    }
    if (!excluded) {
      if (type == "tree") {
        ntree = remktree(hash,parent name "/")
        print mode " tree " ntree "\t" name |& w
      } else {
        print mode " " type " " hash "\t" name |& w
      }
    }
  }
  close(w,"to")
  w |& getline
  close(r)
  close(w)
  return $0
}
BEGIN {
  if (!ref)
    ref = "HEAD"
  xi = 0
  i = 0
  while ((getline)) {
    if ($0 == "") {
      xi++
      i = 0
      continue
    }
    if (xi == 0)
      wcexcludes[i] = $0
    else if (xi == 1)
      excludes[i] = $0
    i++
  }
}
END {
  print remktree(ref)
}
