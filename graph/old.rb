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
          w2alignments[w].push [match[4].to_i / 1000.0, match[5].to_i / 1000.0]
        end
        w += 1
      end
    end
  end
end

class Segment
  attr :w0, true
  attr :w1, true
  attr :t0, true
  attr :t1, true
  attr :next, true
  def to_s
    "#{@t0}-#{@t1}"
  end
end

segment01 = Segment.new
segment01.w0 = -1
segment01.w1 = $num_words
segment01.t0 = 0
segment01.t1 = 240
segment01.next = []

segment0 = Segment.new
segment0.w0 = -1
segment0.w1 = -1
segment0.t0 = 0
segment0.t1 = 0
segment0.next = [segment01]

#def update_segments segment, w, alignment, indentation
#  puts "#{' ' * indentation}Updating #{segment} with #{alignment}"
#  if w >= segment.w1
#    (segment.next || []).each do |next_segment|
#      p "Should I update #{next_segment} with #{w}? #{w >= next_segment.w1}"
#      if w >= next_segment.w1
#        update_segments next_segment, w, alignment, indentation + 1
#      end
#    end
#
#    after = Segment.new
#    after.w0 = w + 1
#    after.w1 = $num_words
#    after.t0 = alignment[1]
#    after.t1 = 240
#    after.next = nil
#
#    during = Segment.new
#    during.w0 = w
#    during.w1 = w
#    during.t0 = alignment[0]
#    during.t1 = alignment[1]
#    during.next = [after]
#
#    before = Segment.new
#    before.w0 = segment.w1
#    before.w1 = w
#    before.t0 = segment.t1
#    before.t1 = alignment[0]
#    before.next = [during]
#    
#    segment.next.push before
#  end
#end

def update_segments segment, w, alignment, indentation
  puts "#{' ' * indentation}Updating #{segment} with #{alignment}"
  if alignment[0] >= segment.t1
    after_all = true
    segment.next.each do |next_segment|
      p "Does #{alignment} come after #{next_segment}?"
      if alignment[0] >= next_segment.t1
        #update_segments next_segment, w, alignment, indentation + 1
      else
        puts "NO: #{[alignment[0], next_segment.t1]}"
        after_all = false
      end
    end
    puts "after_all: #{after_all}"

    unless after_all
      after = Segment.new
      after.w0 = w + 1
      after.w1 = $num_words
      after.t0 = alignment[1]
      after.t1 = 240
      after.next = []

      during = Segment.new
      during.w0 = w
      during.w1 = w
      during.t0 = alignment[0]
      during.t1 = alignment[1]
      during.next = [after]

      before = Segment.new
      before.w0 = segment.w1
      before.w1 = w
      before.t0 = segment.t1
      before.t1 = alignment[0]
      before.next = [during]

      segment.next.push before
    end
  end
end

def print_segment segment, indentation
  puts "#{'  ' * indentation}#{segment.t0}-#{segment.t1}"
  segment.next.each do |next_segment|
    print_segment next_segment, indentation + 1
  end
end

w2alignments.each_with_index do |alignments, w|
  alignments.each_with_index do |alignment, i|
    update_segments segment0, w, alignment, 0
    break if i == 1
  end
  break
end
print_segment segment0, 0
