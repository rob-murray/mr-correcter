## mr-correcter

[![Build Status](https://travis-ci.org/rob-murray/mr-correcter.png?branch=master)](https://travis-ci.org/rob-murray/mr-correcter)
[![Code Climate](https://codeclimate.com/github/rob-murray/mr-correcter.png)](https://codeclimate.com/github/rob-murray/mr-correcter)
[![Coverage Status](https://coveralls.io/repos/rob-murray/mr-correcter/badge.png)](https://coveralls.io/r/rob-murray/mr-correcter)
[![Haz Commitz Status](http://haz-commitz.herokuapp.com/repos/rob-murray/mr-correcter.svg)](http://haz-commitz.herokuapp.com/repos/rob-murray/mr-correcter)

### Description

MrCorrecter is a friendly guy, he searches Twitter for spelling mistakes and replies to the tweets pointing out to the tweeters that they have misspelled a word.

[Mr_Correcter](https://twitter.com/Mr_Correcter)

#### Apology

First off, if **mr-correcter** has offended or annoyed anyone in particular I must apologise for him; he means no harm and is just trying to help the world's spelling.

#### mr-correcter

**mr-correcter** is mainly a development exercise, a little play thing; he is just a few lines of code to play around with the Twitter gem. This app searches Twitter using the Twitter API for spelling mistakes, these actually being a common misspelling of a particular word as opposed to any dictionary based testing. The code then creates a reply and again using the Twitter API will `reply_to` the Tweet with the correct spelling of the word.

It appears that not many people enjoy being corrected and reply back to **mr-correcter** and he receives a fair amount of abuse back from the mispellers, have a look at [some of the replies to him](http://robertomurray.co.uk/blog/2012/the-twitter-account-mr-correcter/).

### Getting started

In order to use this code you will have to checkout this repo and change the Twitter API credentials used.

1. `bundle install`.
2. Create and edit `config.yml` (see `config.example.yml` for details) or amend the configuration block in `Rakefile`. Alter parameters and add Twitter API credentials. Also edit corrections if necessary.
3. Ready to go.


### Usage

#### Run

To run **mr-correcter**, after editing any configuration, just run the rake task then sit back and enjoy mayhem.

```bash
$ rake run
````

#### Spec

Verify **mr-correcter** spec.

```bash
$ rake spec
````

### License

This project is available for use under the MIT software license.
See LICENSE
