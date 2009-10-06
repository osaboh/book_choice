#!/usr/bin/ruby1.9 -Ku
# -*- coding: utf-8 -*-

require 'open-uri'
require 'digest/md5'
require 'cgi'

sm = 'http://www.amazon.co.jp/dp/4797329734/'	# Math for programer
km1 = 'http://www.amazon.co.jp/dp/4797341378/'	# Math girl set <-- Math girl
km2 = 'http://www.amazon.co.jp/dp/4797352965/'	# Real world Haskell <-- Math girl incompleteness theorem
km3 = 'http://www.amazon.co.jp/dp/4797337958/'	# Usual compiler
#km4 = 'http://www.amazon.co.jp/dp/4873114233'	# Real world Haskell (empty page)
ir = 'http://www.amazon.co.jp/dp/4873113636/'	# Beautiful code
urls = [sm, km1, km2, km3, km2, ir]

class Amazon
  attr_accessor :title, :isbn

  def initialize(url)
    source =  open(url)
    @html = charref(source.read)
    @title = scrape_title
    @isbn = scrape_isbn
  end

  def scrape_title
    slice_regex(%r{<title>Amazon.co.jp： }mu, %r{:.*</title>}mu, @html)
  end

  def scrape_isbn
    slice_regex(%r{<li><b>ISBN-13:</b> }m, %r{</li>}m, @html)
  end

  def charref(url)
    CGI.unescapeHTML(url)
  end

  def slice_regex(head, tail, source)
    head =~ source
    $' =~ tail;
    return $`
  end

end

class Onewayhash
  def md5(source)
    Digest::MD5.hexdigest(source)
  end
end

owh = Onewayhash.new
booklist = Hash::new

urls.each do | url |
  amazon = Amazon.new(url)
  booklist[amazon.title] = owh.md5(amazon.isbn)
end

booklist.to_a.sort{|a, b|
  (b[1] <=> a[1]) * 2 + (a[0] <=> b[0])
}.each  {|title, md5|
  puts "#{md5} #{title}"
}

