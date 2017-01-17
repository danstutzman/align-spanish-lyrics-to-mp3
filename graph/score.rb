require 'pp'

words = File.read('SqWrliMzrW8.txt').split("\n").map { |line| line.strip }
$num_words = words.size

w2alignments = []
$num_words.times { w2alignments.push [] }
%w[long.out long-l.out long-r.out].each do |filename|
  w = 0
  File.read(filename).split("\n").each do |line|
    if match = line.match(/^^([ +-]) (.*?)( +\[([0-9]+):([0-9]+)\])?$/)
      if match[1] == '-' || match[1] == ' '
        word = match[2]
        word.gsub! 'pa´', 'pa'
        raise "Got word #{word} instead of #{words[w]}" if words[w] != word
        if match[3]
          new_alignment = [match[4].to_i / 1000.0, match[5].to_i / 1000.0, 1]
          added = false
          w2alignments[w].each_with_index do |alignment, a|
            if (alignment[0] - new_alignment[0]).abs < 0.1 &&
               (alignment[1] - new_alignment[1]).abs < 0.1
              alignment[0] = [alignment[0], new_alignment[0]].min
              alignment[1] = [alignment[1], new_alignment[1]].max
              alignment[2] += 1
              added = true
              break
            end
          end
          if !added
            w2alignments[w].push new_alignment
          end
        end
        w += 1
      end
    end
  end
end

path2score = {[] => 0}

def score_path path, w2alignments, new_path2score
  built = []
  path.each_with_index do |choice, w|
    if choice > -1
      built.push w2alignments[w][choice]
    end
  end
  print 'built: '
  p built

  score = 0
  built.each do |alignment|
    score += alignment[2]
  end
  new_path2score[path] = score
end

#8.times do |w1|
#  new_path2score = {}
#  path2score.keys.each do |path|
#    score_path path + [-1], w2alignments, new_path2score
#    w2alignments[w1].each_with_index do |alignment, a|
#      score_path path + [a], w2alignments, new_path2score
#    end
#  end
#  path2score = new_path2score
#  pp path2score
#end

new_w2alignments = []
w2alignments[0...220].each_with_index do |alignments, w|
  if alignments.size == 1 && alignments[0][2] >= 2
    print '  '
    print '%-12s' % words[w]
    p alignments
    new_w2alignments.push alignments[0]
  else
    print '* '
    print '%-12s' % words[w]
    p alignments
    #exit 1
  end
end
