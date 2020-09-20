# LogAnalyzer

A log analyzing program to satisfy the Datadog code challenge.

## Setup

Bundler is required. If it is not installed, `gem install bundler`.

`bin/setup`

## Usage

`bin/log_analyzer file.txt`

`cat file.txt | bin/log_analyzer`

The default alerting threshold is 10 requests per second; this can be overridden
by setting the `ALERT_THRESHOLD` environment variable.

`ALERT_THRESHOLD=20 bin/log_analyzer file.txt # sets threshold to 20 requests/sec`

For additional output, run in debug mode by setting the `DEBUG` environment variable.

`DEBUG=true bin/log_analyzer file.txt`

## Running tests

`bundle exec rake`

## Design Decisions

The `LogAnalyzer::Bucket` class exists so that we can calculate statistics for
each 10 second period. At the same time, we have a separate
`LogAnalyzer::RollingWindowTrafficCheck` class to check hit rates for the most
recent 2 minutes. Both classes are concerned with tracking events through the
log's timeline; they share an instance of `LogAnalyzer::LogClock` to do so. The
log clock is a simple construct that essentially just keeps track of the most
recent timestamp that has been seen in the logs. This becomes extremely
valuable when considering the fact that log events are not necessarily in
chronological order.

It's nice to have an easy interface to access relevant information from log
lines.  We could create a `Log` class that is initialized from a `CSV::Row`,
but we are likely ingesting a large number of log lines and don't want to
instantiate an object for each one (this would put a lot of work on the GC).
Instead, `LogAnalyzer::LogParser` provides class methods that take a csv row
and provide an interface to the various data we want.

Hit counts are stored as a time-ordered linked list to make it easy to roll
expired hits (i.e. hits outside of the check window). Indexing new hits takes
O(n) time, but this is considered acceptable because we traverse all hits in
the window to determine traffic in the window anyways. For comparison, the
other implementation that was considered was to index hits by timestamp in a
Hash.  This would allow new hits to be indexed in constant time, but we would
still have to traverse all keys in the hash to calculate the in-window traffic,
leading to the same O(n) time complexity as the linked list approach.

The window size is not specified to be configurable, so it is defined as a constant
in `LogAnalyzer::RollingWindowTrafficCheck`. This could be easily modified to be
configured via an environment variable (similar to the alert threshold).

## Areas for Improvement

The `LogClock` is a useful abstraction for this problem, where alerting is
based on log time and we have a constant stream of logs. However, this would
not be a great approach for a real world application, as an interruption in the
log stream would stall the clock. If we had a requirement to track
conspicuously _low_ levels of traffic, this approach would need to be
revisited.

Currently, it can be cumbersome to establish state in tests (e.g. establishing
a clock time). If developing this project further, I would definitely invest in
adding factories and spec helpers to address this.

## Time Spent

10-12 hours.
