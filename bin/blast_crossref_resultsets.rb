#! /usr/bin/ruby
#
#  List the results of a BLAST XML file (-m7) by hits. The BLAST file is post-
#  processed to find all hits with their original searches. All results are
#  parsed and each sequence that is hit is listed with the original search
#  sequences it matches (cross-referencing hits).
#
#  So if BLAST queries with sequence Q1, Q2 and Q3 are executed each of these
#  returns a result set containing hits. If a hit H is shared between queries
#  Q2 and Q3 it will be listed like:
#
#  H: Q2 Q3
#
#  and so on for all hits.
#
#  This can be useful when BLASTing datasets against themselves. Rather then
#  having to BLAST all hits again to find their homologues.
#
#  Usage:
#
#

require 'bio'

for fn in ARGV do 
  if !File.exist? fn
    print "\nFile #{fn} does not exist"
    next
  end
  $stderr.print "\nParsing #{fn}..."

  crossref = {}
  program = version = db = nil
  Bio::Blast.reports(File.new(fn)).each do |rep| # for multiple xml reports
    program = rep.program
    version = rep.version
    db = rep.db
    rep.iterations.each do |itr|
      search_id = itr.query_def
      itr.hits.each do |hit|
        # print hit.target_id, "\t", hit.evalue, "\n" if hit.evalue < 0.001
        id = hit.target_id
        crossref[id] = [] if crossref[id] == nil
        crossref[id].push search_id
      end
    end
  end
  print program,"\n"
  print version,"\n"
  print db,"\n"
  crossref.sort.each do | k, set |
    print '"',k,'",'
    set.each do | item |
      # print '"',item.split[0],'",'
      print '"',item,'",'
    end
    print "\n"
  end
end


