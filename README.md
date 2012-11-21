log_rotate
==========

After running the program, the specified directory should contain logs which
cover:

  1) Last 7 days
  2) Last 4 Sundays
  3) Last 3 first of month
  4) Any files that do not have a date time stamp


Purge

## Constraints

At most one log file per day.


## Basic Process

  1) Establish start date (default is current date)
  2) Get the list of filenames
  3) Go through each constraint and mark those files
  4) Delete unmarked files


## Usage

This is a command line based application.

    $ purge_logs DIRECTORY
    5 logs purged

