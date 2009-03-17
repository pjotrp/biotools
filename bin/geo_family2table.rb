#! /usr/bin/ruby
#
#  This script parses a GEO project MINiML (MIAME Notation in Markup Language)
#  family file and turns the array data into a single matrix file containing
#  a probe descriptor and the raw probe values, as described on
#
#      http://www.ncbi.nlm.nih.gov/projects/geo/info/MINiML.html
#
#  For example, download an unpack a family file from GEO (both experiments and
#  platforms are possible), like:
#
#      GPL3718_family.xml.tgz
#
#  into
#
#      GPL3718_family.xml
#      GPL3718-tbl-1.txt
#      GPL3718-tbl-2.txt
#      (etc)
#
#  And run this tool:
#
#      geo_family2table.rb GPL3718_family.xml > GPL3718_family.csv
#
#  (you will need Bioruby with microarray support and xmlsimple)
#
#  To get the raw values (which tend to have different names across data
#  sets) some heuristic is used. Also when values are missing they will 
#  be written as 'NA' (which often happens with controls).
#
#  Note: all values are loaded in memory before writing the matrix.
#
#  By Pjotr Prins (c) 2009
#

require 'optparse'
require 'ostruct'
require 'bio'

# A simple support class for handling rownames.

class RowNames

  def initialize
    @list = {}
  end

  def add name
    if not @list[name]
     @list[name] = @list.size
    end
  end

  def index name
    @list[name]
  end

  def each
    @list.each do | k, v |
      yield v,k
    end
  end

end

$stderr.print "geo_family2table.rb by Pjotr Prins (c) 2009\n"

options = OpenStruct.new()
opts = OptionParser.new() { |opts|
  opts.on_tail("-h", "--help", "Print this message") {
    print(opts)
    print <<EXAMPLE

Examples:

    geo_family2table.rb GPL3718_family.xml > GPL3718_family.csv

    geo_family2table.rb GSE10940_family.xml > GSE10940_family.csv

EXAMPLE
    exit()
  }
  
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options.verbose = v
    $VERBOSE = v
  end

  opts.on("-t", "--[no-]trace", "Debug") do |t|
    options.trace = t
  end

}
opts.parse!(ARGV)

ARGV.each do | fn |
  m = Bio::Microarray::MINiML::GEO_Family.new(fn)
  isTwoColor = m.platform.two_color?

  num = m.samples
  arrays = []
  colnames = []
  rownames = RowNames.new
  i=0
  m.each_sample do | sample |
    i += 1
    field_names = sample.field_names
    $stderr.print "#{(i*100.0/num).to_i}%\tReading #{sample.acc}, size #{sample.rows}, #{sample.title}\n" if options.verbose
    $stderr.print field_names.join(':'),"\n"
    next if sample.rows == 0
    array = []
    # Make rowname
    rn = sample.title.strip
    if rn and rn != ''
      rn = rn.gsub(/\t/,' ')
      rn = rn.gsub(/&/,'&amp;')
      rn = rn.gsub(/\</,'&lt;')
      rn = rn.gsub(/\>/,'&gt;')
      rn = rn.gsub(/\"/,'&quote;')
      rn = rn.gsub(/\'/,'&apos;')
    end

    if not isTwoColor
      if not field_names.include?('ID_REF') and not field_names.include?('VALUE')
        p field_names
        raise 'Problem with field names - missing value!'
      end
      columns = ['ID_REF']
      if field_names.include?('RAW_SIGNAL')
        columns.push 'RAW_SIGNAL'
      else
        columns.push 'VALUE'
      end
      $stderr.print 'Reading: ',columns.join(':'),"\n"
      colnames.push "#{sample.acc}:: #{rn}"
      sample.each_row(:columns => columns) do | data |
        rowname = data[0]
        rownames.add(rowname)
        array[rownames.index(rowname)] = data[1]
      end
      arrays.push array
    else
      raise 'Two color arrays not supported'
    end
  end

  nas = 0
  $stderr.print "Writing table..." if options.verbose
  arrays.each_with_index do | array, i |
    print "\t",colnames[i] if array.size > 1
  end
  rownames.each do | index, rowname |
    print "\n",rowname
    arrays.each do | array |
      if array.size > 1
        if array[index] == nil
          print "\tNA"
          nas += 1
        else
          print "\t",array[index]
        end
      end
    end
  end
  $stderr.print "Warning: #{nas} NA's written to table!" if nas>0
end

