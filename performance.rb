# frozen_string_literal: true

require "liquid"
require "liquid/c" if ARGV.shift == "c"

(script = ARGV.shift) || abort("unspecified performance script")
require_relative "performance/#{script}"