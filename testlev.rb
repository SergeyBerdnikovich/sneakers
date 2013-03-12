# -*- encoding : utf-8 -*-
#!/usr/bin/env ruby
# coding: utf-8
require "rubygems"
require "eventmachine"
#require "em-http"
require "uri"
require "em-synchrony"
require "em-synchrony/em-http"
require "levenshtein"
product_object = Hash.new

product_object['id'] = 111

product_id = 0
what = "Kobe 8 System"
product_object['title'] = " Kobe 8 System"

product_title = product_object['title'].gsub(/[^a-zA-Z0-9]/mi,"").downcase
what = what.gsub(/[^a-zA-Z0-9]/mi,"").downcase

p product_title
p what
p Levenshtein.distance(what,product_title)

              if product_title.strip.index(what) != nil
                product_id = product_object['id']
              end

              if what.strip.index(product_title) != nil
                product_id = product_object['id']
              end
p product_id