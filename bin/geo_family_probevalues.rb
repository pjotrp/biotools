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
  raise 'Two-color not supported (yet)' if m.platform.two_color?

  # Create array of probe names
  probenames = m.platform.ids
  num = m.samples
  $stderr.print "Number of probes is #{probenames.size} over #{num} samples\n"

  m.each_sample do | sample |
    field_names = sample.field_names
    $stderr.print 'Contains: ',field_names.join(':'),"\n"
    next if sample.rows == 0
    # load values in a hash to locate missing values
    values = {}
    field_id = sample.field_id
    field_raw = sample.field_raw
    sample.each_row(:columns => [field_id,field_raw]) do | data |
      values[data[0]] = data[1]
    end
    nas = 0
    File.open(sample.external_data_filename+'.csv','w') do | f |
      probenames.each do | id |
        value = values[id]
        if value == nil or value == ''
          value = 'NA'
          nas += 1
        end
        f.print id,"\t",value,"\n"
      end
    end
    $stderr.print "Warning: #{nas} NA's written to table!\n" if nas>0
  end

end

