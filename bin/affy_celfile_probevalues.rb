#! /usr/bin/ruby
#
#  Read an Affymetrix CEL file and write all CEL values to a tab delimited
#  file (using the Biolib Affyio module).
#
#  By Pjotr Prins (c) 2009
#
#  See http://github.com/pjotrp/biotools/blob/master/LICENSE
#

require 'optparse'
require 'ostruct'
require 'biolib/affyio'

$stderr.print "affy_celfile_probevalues.rb by Pjotr Prins (c) 2009\n\n"

options = OpenStruct.new()
opts = OptionParser.new() { |opts|

  opts.on_tail("-h", "--help", "Print this message") {
    print(opts)
    print <<EXAMPLE



Examples:

    affy_celfile_probevalues.rb celfile(s)

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
  outfn = File.basename(fn)+'.tab'
  print "Writing #{outfn}...\n"
  File.open(outfn,'w') do | outf |
    cel = Biolib::Affyio.open_celfile(fn)
    num = Biolib::Affyio.cel_num_intensities(cel)
    (0..num-1).each do | probe |
      probe_value = Biolib::Affyio.cel_intensity(cel,probe)
      outf.printf "%d\t%.1f\n",probe,probe_value
    end
  end
end

