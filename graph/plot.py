#!/usr/bin/env python
#coding: utf-8

import math
import png
import re

words = []
with open('SqWrliMzrW8.txt') as f:
  for word in f:
    words.append(word.strip())
if words[-1] == '':
  words.pop()

rows = []
for t in range(1200):
  rows.append([255] * len(words))

for filename in ['long.out', 'long-l.out', 'long-r.out', 'long-oops.out']:
  num_word_in_song = 0
  with open(filename) as f:
    for line in f:
      match = re.match(r'^([ +-]) (.*?)( +\[([0-9]+):([0-9]+)\])?$', line)
      if match:
        symbol       = match.group(1)
        word         = match.group(2)
        word = re.sub(r'´$', '', word)
        begin_millis = match.group(4) and int(match.group(4))
        end_millis   = match.group(5) and int(match.group(5))
        if begin_millis:
          begin_t = int(math.floor(begin_millis / 200))
          end_t   = int(math.ceil(end_millis / 200))
          for t in xrange(begin_t, end_t):
            rows[t][num_word_in_song] = 0
        if symbol == ' ' or symbol == '-':
          if words[num_word_in_song] != word:
            raise Exception("Expected %s but got %s" % (words[num_word_in_song], word))
          num_word_in_song += 1

  with open(filename) as f:
    for line in f:
      match = re.match(r'^INFO: Utterance result \[(.*)\]$', line)
      if match:
        for word_tuple in match.group(1).split('}, {'):
          match2 = re.match('^{?([^,]+), 1.000, \[(-?[0-9]+):(-?[0-9]+)\]}?$',
              word_tuple)
          if not match2:
            raise Exception("Couldn't parse %s" % word)
          word         = match2.group(1)
          begin_millis = int(match2.group(2))
          end_millis   = int(match2.group(3))
          if word != '<sil>' and word != '</s>' and (end_millis - begin_millis < 3000):
            for w in range(len(words)):
              if words[w] == word:
                #if w > 310 and w < 325 and t > 600 and t < 680:
                #  print word_tuple
                begin_t = int(math.floor(begin_millis / 200))
                end_t   = int(math.ceil(end_millis / 200))
                for t in xrange(begin_t, end_t):
                  if rows[t][w] == 255:
                    rows[t][w] = 180
                    if word == 'bonita' and begin_millis == 128320:
                      rows[t][w] = 0
            

f = open('png.png', 'wb')
w = png.Writer(len(rows[0]), len(rows), greyscale=True, bitdepth=8)
w.write(f, rows)
f.close()
