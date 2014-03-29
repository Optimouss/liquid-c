# Liquid::C
[![Build Status](https://api.travis-ci.org/Shopify/liquid-c.png?branch=master)](https://travis-ci.org/Shopify/liquid-c)

Partial native implementation of the liquid ruby gem in C.

## Installation

Add these lines to your application's Gemfile:

    gem 'liquid', github: 'Shopify/liquid', branch: 'master'
    gem 'liquid-c', github: 'Shopify/liquid-c', branch: 'master'

And then execute:

    $ bundle

## Usage

    require 'liquid/c'

then just use the documented API for the liquid Gem.

## Restrictions

* Input strings are assumed to be UTF-8 encoded strings
* Tag#parse(tokens) is given a Liquid::Tokenizer object, instead
  of an array of strings, which only implements the shift method
  to get the next token.

## Contributing

1. Fork it ( http://github.com/Shopify/liquid-c/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
