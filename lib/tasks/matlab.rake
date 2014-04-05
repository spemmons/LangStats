namespace :matlab do

  desc 'build matlab files'
  task counts: :environment do

    #puts 'words...'
    #File.open('matlab/count_words.tsv','w') do |file|
    #  Element.words.order('count desc').each{|element| file.puts [element.count,DocumentElement.words.where(element_id: element.id).count,IntervalElement.words.where(element_id: element.id).count,element.id,element.name].join("\t")}
    #end
    #
    #puts 'alphanumerics...'
    #File.open('matlab/count_alphanumerics.tsv','w') do |file|
    #  Element.alphanumerics.order('count desc').each{|element| file.puts [element.count,DocumentElement.alphanumerics.where(element_id: element.id).count,IntervalElement.alphanumerics.where(element_id: element.id).count,element.id,element.name].join("\t")}
    #end
    #
    #puts 'punctuation...'
    #File.open('matlab/count_punctuation.tsv','w') do |file|
    #  Element.punctuation.order('count desc').each{|element| file.puts [element.count,DocumentElement.punctuation.where(element_id: element.id).count,IntervalElement.punctuation.where(element_id: element.id).count,element.id,element.name].join("\t")}
    #end

    [
        ['ngram1',Category::ALPHANUMERIC_ID,Category::PUNCTUATION_ID],
        ['ngram2',Category::NGRAM2_ID],
        ['ngram3',Category::NGRAM3_ID],
    ].each do |tuple|
      label = tuple.shift
      puts "#{label}..."
      File.open("matlab/count_#{label}.tsv",'w') do |file|
        Element.where(category_id: tuple).order('count desc').each{|element| file.puts [element.count,DocumentElement.where(element_id: element.id,category_id: tuple).count,IntervalElement.where(element_id: element.id,category_id: tuple).count,element.id,element.name].join("\t")}
      end
    end

  end

  desc 'build matlab datsets'
  task datasets: :environment do
    [
        ['ngram1',Category::ALPHANUMERIC_ID,Category::PUNCTUATION_ID],
        ['ngram2',Category::NGRAM2_ID],
        ['ngram3',Category::NGRAM3_ID],
    ].each do |tuple|
      label = tuple.shift
      columns = {}
      Element.where(category_id: tuple).order('count desc').each_with_index{|element,index| columns[element.id] = index}

      puts "#{label} documents..."
      File.open("matlab/document_#{label}.tsv",'w') do |file|
        Document.all.each do |document|
          row = [document.id]
          document.elements.where(category_id: tuple).each do |element|
            next unless index = columns[element.element_id]
            row[index + 1] = element.count
          end
          file.puts row.join("\t")
        end
      end

      puts "#{label} intervals..."
      File.open("matlab/interval_#{label}.tsv",'w') do |file|
        Interval.all.each do |interval|
          row = [interval.document_id,interval.interval_number,interval.interval_size]
          interval.elements.where(category_id: tuple).each do |element|
            next unless index = columns[element.element_id]
            row[index + 3] = element.count
          end
          file.puts row.join("\t")
        end
      end
    end
  end

end