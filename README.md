# LogAnalyzer

A log analyzing program to satisfy the Datadog code challenge.

## Setup

Bundler is required. If it is not installed, `gem install bundler`.

`bin/setup`

## Usage

`bin/log_analyzer file.txt`

`cat file.txt | bin/log_analyzer`

## Running tests

`bundle exec rake`

## Design Decisions

We have two different criteria for evaluating groups of log lines. The first is
to check "every 10 seconds of log lines." Given that we are outputting
statistics like traffic per section, we probably want to assess this in such a
way that groupings of lines can be compared and aggregated. To me, this sounds
like bucketing.

Our second criterion is to alert if the total traffic for the past 2 minutes
ever exceeds a threshold. Basically we want to be regularly checking for the
most recent 2 minutes, which sounds more like a rolling window than a bucket.

It's nice to have an easy interface to access relevant information from log
lines.  We could create a `Log` class that is initialized from a `CSV::Row`,
but we are likely ingesting a large number of log lines and don't want to
instantiate an object for each one (this would put a lot of work on the GC).
Instead, `LogAnalyzer::LogParser` provides class methods that take a csv row
and provide an interface to the various data we want.

* metric point: 1 second resolution
* bucket/rollup
* Datadog tries to return about 150 points for any given time window.
* timestamps are not strictly increasing

* for every 10 seconds of log lines, display about the traffic during those 10s
  * so, print once every 10 seconds
  * sections of site with most hits
* keep track of rolling total traffic on average


Figure out rolling window first, then tackle outputting.



