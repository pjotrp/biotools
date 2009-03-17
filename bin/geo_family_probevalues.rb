#! /usr/bin/ruby
#
#  This script parses a GEO project MINiML (MIAME Notation in Markup Language)
#  family file and fetches the raw probe values for each array and writes these
#  to simple array files containing just the probe name and value. Information
#  on MINiML can be found here:
#
#      http://www.ncbi.nlm.nih.gov/projects/geo/info/MINiML.html
#
#  For example, download and unpack a family file from GEO (both experiments and
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
#      geo_family_probevalues.rb GPL3718_family.xml
#
#  creates for each array a two column file containing probe name (ID_REF)
#  and value (VALUE).
#
#  (you will need Bioruby with microarray support and xmlsimple)
#
#  To get the raw values (which tend to have different names across data
#  sets) some heuristic is used. Also when values are missing they will 
#  be written as 'NA' (which often happens with controls).
#
#  Note: this tool is memory efficient as it writes out new files on
#  the fly.
#
#  By Pjotr Prins (c) 2009
#
#  See http://github.com/pjotrp/biotools/blob/master/LICENSE
#

require 'optparse'
require 'ostruct'
require 'bio'

$stderr.print "geo_family_probevalues.rb by Pjotr Prins (c) 2009\n"

options = OpenStruct.new()
opts = OptionParser.new() { |opts|
  opts.on_tail("-h", "--help", "Print this message") {
    print(opts)
    print <<EXAMPLE

Examples:

    geo_family_probevalues.rb GPL3718_family.xml

    geo_family_probevalues.rb GSE10940_family.xml 

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

  # Create array of probe names
  probenames = []
  m.platform.each_probe do | probe |
    raise 'Probename not defined at line #{probenames.size}' if probe['ID']==nil or probe['ID']==''
    probenames.push probe['ID']
    # print probe['ID']
  end

  num = m.samples
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

  # $stderr.print "Writing table..." if options.verbose
  $stderr.print "Warning: #{nas} NA's written to table!" if nas>0
end

