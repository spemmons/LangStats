class DatafileReader

  attr_reader :source

  def initialize(source = {})
    @source = source

    # TODO remove after old style no longer exists...
    start_after = @source.delete('start_after')
    end_before =  @source.delete('end_before')
    @source['first_line'] = find_line_number(file_lines,/\w/,skip_to_line(file_lines,start_after,0,1)) if start_after.kind_of?(String)
    @source['last_line']  = skip_to_line(file_lines,end_before,@source['first_line'],-1)                if end_before.kind_of?(String)
  end

  def file_lines
    @file_lines ||= (@source['filename'] && read_datafile(@source['filename'])) || []
  end

  def content_lines
    @content_lines ||= file_lines[(@source['first_line'] || 0)..(@source['last_line'] || -1)]
  end

  def enhance_source
    while !(answer = prompt("#{source}\nAuthor,Title,Start,End,Capture,Finish? ")).blank?
      case answer[0].downcase
        when 'a'
          @source['author'] = verify(match_author(file_lines) || find_best_author(file_lines,@source['first_line'])) || @source['author']
        when 't'
          @source['title'] = verify(match_title(file_lines) || find_best_title(file_lines,@source['first_line'])) || @source['title']
        when 's'
          @source['first_line'] = choose_line_number(file_lines,@source['first_line'],/(start|\*end)/i,nil)
          @content_lines = nil
        when 'e'
          @source['last_line'] = choose_line_number(file_lines,@source['last_line'],/gutenberg/i,@source['first_line'])
          @content_lines = nil
        when 'c'
          capture_url(@source['url']) if @source['url']
        when 'f'
          return false
        else
          puts "unknown answer: #{answer}"
      end

      puts 'no file lines found' unless file_lines
    end

    true
  end

  def read_datafile(filename)
    File.readlines(filename).collect{|line| condition_line(line)}
  end

  def capture_url(url)
    @file_lines = read_lines_from_url(url)
    @source['url'] = url
    @source['title'] = match_line(@file_lines,/title: (.*)\Z/i)
    @source['author'] = match_line(@file_lines,/author: (.*)\Z/i)
    @source['filename'] = "datafiles/#{(@source['title'] || URI.parse(url).path.gsub(/\.txt\Z/,'').gsub(/\A\//,'')).gsub(/\W/,' ').strip.downcase.gsub(/\s/,'_')}.txt"
    File.open(@source['filename'],'w'){|file| file.puts @file_lines}
  end

  def read_lines_from_url(url)
    if (response = HTTParty.get(url)).nil?
      log_warning("NO RESPONSE #{url}")
      []
    elsif response.code != 200
      log_warning("BAD RESPONSE #{url} - #{response.code} - #{response.parsed_response}")
      []
    else
      response.parsed_response.split("\n").collect{|line| condition_line(line)}
    end
  end

  def condition_line(line)
    line.unpack('C*').pack('U*').chomp.split('').collect{|c| c.encode('ASCII-8BIT') rescue ' '}.join.encode('UTF-8')
  end

  def find_best_author(lines,start)
    return unless line_number = find_line_number(lines,/\w/,start)

    result = [match_line(lines[line_number..-1],/(^by| by) (.*)/i,1)].compact

    line_number = 0 if start
    while result.length < 10 && (line = lines[line_number])
      result << $2 if line =~ /(^by| by) (.*)/i
      line_number += 1
    end

    result
  end

  def find_best_title(lines,start)
    return if (line = lines[find_line_number(lines,/\w/,start)].to_s.strip).blank?

    result = [line]
    result << $1.strip if line =~ /^(.*) by /

    result
  end

  def match_author(lines)
    match_line(lines,/author: (.*)S/i)
  end

  def match_title(lines)
    match_line(lines,/title: (.*)S/i)
  end

  def match_line(lines,regex,index = 0)
    lines.each{|line| return [$1,$2,$3][index] if line =~ regex} if lines
    nil
  end

  def skip_to_line(lines,match,start,offset)
puts "FIXUP - #{match}:#{start}:#{offset}"
    lines[[start,0].max..-1].each_with_index{|line,index| return start + index + offset if line.index(match)}
    nil
  end

  def choose_line_number(lines,current,hint,start)
    return unless lines

    line_number = current || find_line_number(lines,hint,start)

    while true
      ((line_number - 5)..(line_number + 5)).each do |target_number|
        next if target_number < 0 or (line = lines[target_number]).nil?
        puts "#{(offset = target_number - line_number) == 0 ? '**' : format('%02d',offset)}:#{target_number}:#{line}"
      end

      case answer = prompt("Up,Down,**,#,Next(#{hint},Hint,Restart,Clear? ")
        when /^u/i
          line_number -= 10
        when /^d/i
          line_number += 10
        when /^\*/
          return line_number
        when /^(\-|)\d+$/
          line_number += answer.to_i
        when /^n/i
          line_number += 1
          line_number += 1 until (line = lines[line_number]).nil? or line =~ hint
          line_number = lines.length - 1 unless line
        when /^h/i
          begin
            hint = Regexp.new(answer[1..-1],Regexp::IGNORECASE)
            line_number += 1 until (line = lines[line_number]).nil? or line =~ hint
            line_number = lines.length - 1 unless line
          rescue
            puts "BAD HINT: #{answer[1..-1]}"
          end
        when /^r/
          line_number = find_line_number(lines,hint,start)
        when /^c/
          return nil
      end
    end

  end

  def find_line_number(lines,hint,start = nil)
    line_number = start || 0
    line_number += 1 until (line = lines[line_number]).nil? or line =~ hint
    line_number = lines.length - 1 unless line

    line_number
  end

  def verify(choice)
    return unless (choice = Array(choice)).any?

    choice = choice.first if choice.length == 1
    while true
      case choice
        when String
          case prompt("#{choice} - (y/N)? ")
            when /^\s*$/,/^\s*y/i then return choice
            when /^\s*n/i         then return nil
          end
        when Array
          choice.each_with_index{|value,index| puts "#{index}:#{value}"}
          case prompt("0-#{choice.length - 1} or x? ")
            when /^(\d*)$/  then return choice[$1.to_i]
            when /^\s*x/i   then return nil
          end
        else
          raise "invalid choice: #{choice} (#{choice.class})"
      end
    end
  end

  def prompt(string)
    print string
    STDIN.gets.chomp
  end

end