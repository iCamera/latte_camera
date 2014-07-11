#!/usr/bin/python

import sys
import re

source = open(sys.argv[1], "r")
dest = open(sys.argv[2], "r")

lines_source = source.read().split('\n')
lines_dest = dest.read().split('\n')

source.close()
dest.close()

idx = 0
for line_dest in lines_dest:
  m_dest = re.search('ObjectID = "(.*)";', line_dest)
  if m_dest:
    for line_source in lines_source:
      m_source = re.search('ObjectID = "(.*)";', line_source)
      if m_source:
        if m_source.group(0) == m_dest.group(0):
          lines_dest[idx] = line_source
  idx += 1

dest = open(sys.argv[2], "w")
dest.write('\n'.join(lines_dest))
dest.close()