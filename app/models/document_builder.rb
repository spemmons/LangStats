class DocumentBuilder

  attr_reader :reader,:document,:line_number,:last_error
  attr_accessor :break_on_warnings

  def initialize(params)
    case params
      when DatafileReader
        @reader = params
        @reset = true
      when Document
        @target = params
        @reader = DatafileReader.new(@target.attributes)
        @reset = false
      else
        raise "invalid params: #{params}"
    end
  end

  INTERVAL_SIZE = 200

  def process_intervals
    raise 'document not found' unless @document ||= Document.find_by_filename(@reader.source['filename'])

    @reset = true
    lines = @reader.content_lines
    interval_number,interval_offset = 0,0
    while interval_offset < lines.length
      @target = @document.intervals.create!(interval_number: interval_number,interval_size: INTERVAL_SIZE)
      process_lines(lines[interval_offset,INTERVAL_SIZE])
      interval_number += 1
      interval_offset += INTERVAL_SIZE
    end

  end

  def process_document
    raise "The target is a #{@target.class} instead of a Document" if @target and not @target.kind_of?(Document)

    @document = @target ||= Document.new(@reader.source.slice(*%w(url filename title first_line last_line)))

    if author_name = @reader.source['author']
      @target.author = Author.find_by_name(author_name) || Author.create!(name: author_name)
    end

    @document.save! && process_lines(@reader.content_lines)
  end

  def process_lines(lines)
    @last_error = nil

    if @reset
      @target.line_count          = 0
      @target.word_count          = 0
      @target.char_count          = 0
      @target.alphanumeric_count  = 0
      @target.punctuation_count   = 0
      @target.elements.delete_all if @target.persisted?
    end

    @element_cache = {}

    lines.each_with_index{|line,index| @line_number = index; decompose_line(line)}

    @element_cache.values.each(&:save!)
    @target.save!

  rescue
    Rails.logger.info "ERROR: #{@last_error = $!}"
    Rails.logger.info $@.join("\n")
    false
  end

  def decompose_line(line)
    if @reset
      @target.line_count += 1
      @target.char_count += line.length
    end

    Rails.logger.info "#{@line_number}: FULL LINE [#{line.chomp.downcase}]"
    line.downcase.gsub(/\[[a-z0-9\.\-]*\]/,' ').split(/\s+/).each do |proto_word|
      Rails.logger.info "#{@line_number}: PROTO WORD [#{proto_word}]"
      hyphenated_proto_words = proto_word.gsub(/&mdash;/,'--').split('--').each{|interior_word| note_word(remove_enclosing_punctuation(interior_word))}
      (hyphenated_proto_words.length - 1).times{note_punctuation('-')} if @reset
    end
  end

  def remove_enclosing_punctuation(proto_word)
    word_chars = proto_word.split('')
    2.times do
      word_chars.reverse!
      while (target_char = word_chars[0]) =~ /[^a-z0-9]/
        raise "CHAR != '#{target_char}'" unless word_chars.shift == target_char
        note_punctuation(target_char) if @reset
      end
    end

    return if word_chars.empty?

    ngram2 = [' ']
    ngram3 = [' ']
    word_chars.each do |char|
      char =~ /[a-z0-9]/ ? note_alphanumeric(char) : note_punctuation(char) if @reset

      note_ngram(Category::NGRAM2_ID,ngram2,char,2)
      note_ngram(Category::NGRAM3_ID,ngram3,char,3)
    end
    note_ngram(Category::NGRAM2_ID,ngram2,' ',2)
    note_ngram(Category::NGRAM3_ID,ngram3,' ',3)

    word_chars.join if @reset
  end

  def note_ngram(category_id,ngram,char,max_length)
    ngram.shift if (ngram << char).length > max_length

    return unless ngram.length == max_length

    Rails.logger.info "...NOTE NGRAM#{max_length} [#{ngram.join}]"
    note_element(category_id,ngram.join)
  end

  def note_alphanumeric(alphanumeric)
    Rails.logger.info "...NOTE ALPHANUMERIC [#{alphanumeric}]"
    @target.alphanumeric_count += 1
    note_element(Category::ALPHANUMERIC_ID,alphanumeric)
  end

  def note_punctuation(punctuation)
    Rails.logger.info "...NOTE PUNCTUATION [#{punctuation}]"
    punctuation.to_s.split('').each do |key|
      @target.punctuation_count += 1
      note_element(Category::PUNCTUATION_ID,key)
    end
  end

  def note_word(word)
    return unless word

    word.gsub!(/_/,'')
    return if word.blank?

    Rails.logger.info "...NOTE WORD [#{word}]"
    @target.word_count += 1
    note_element(Category::WORD_ID,word)
  end

  def note_element(category_id,name)
    element = Element.find_or_create(category_id,name)
    (@element_cache[element.id] ||= @target.elements.new(category_id: category_id,element_id: element.id)).count += 1
  end

  def log_warning(message)
    Rails.logger.info(message = "WARNING: #{message}")
    raise message if @break_on_warnings
  end

end