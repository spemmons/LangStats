namespace :datafile do

  require 'httparty'

  desc 'characterize datafiles'
  task characterize: :environment do
    update_datafiles_yml do |sources|
      sources.each do |source|

        next if source.slice(*%w(filename title author first_line last_line)).values.compact.length >= 5

        break unless DatafileReader.new(source).enhance_source

      end
    end
  end

  desc 'add remove datafile'
  task :capture,[:url] => :environment do |t, args|
    args.with_defaults(url: nil)
    raise 'no URL given' unless url = args[:url]

    update_datafiles_yml do |sources|
      reader = DatafileReader.new
      reader.capture_url(url)
      reader.enhance_source
      sources << reader.source
    end
  end

  desc 'process data files'
  task process: :environment do
    update_datafiles_yml do |sources|

      sources.each do |source|

        next unless source['filename']

        print "#{start_time = Time.now} - FILENAME: #{source['filename']}"
        if Document.find_by_filename(source['filename'])
          puts ' ALREADY PROCESSED'
        else
          (builder = DocumentBuilder.new(DatafileReader.new(source))).process
          if builder.last_error
            puts "ERROR: #{builder.last_error}"
          else
            document = builder.document
            puts " LINES:#{document.line_count} WORDS:#{document.word_count} ALPHA:#{document.alphanumeric_count} PUNCT:#{document.punctuation_count} CHARS:#{document.char_count} TIME:#{(Time.now - start_time).to_i}s"
          end
        end

      end

    end
  end

  def update_datafiles_yml(&block)
    original = YAML.load_file(Rails.root + 'datafiles.yml')
    block.call(modified = original.collect(&:dup))

    if original != modified
      `mv datafiles.yml datafiles.yml.bak`
      File.open('datafiles.yml','w'){|file| file.write modified.to_yaml}
    end

  rescue
    STDERR.puts "ERROR:#{$!}"
    STDERR.puts $@.join("\n")
  end

end
