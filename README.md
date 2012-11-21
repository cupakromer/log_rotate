log_rotate
==========

After running the program, the specified directory should contain logs which
cover:

  1. Last 7 most recent days that there are logs for
  2. Last 4 most recent Sundays that there are logs for
  3. Last 3 most recent first of month that there are logs for
  4. Any files that do not have a date time stamp

`Last` is defined as, keep going until the quota is filled, or there are no
more files.


## Constraints

At most one log file per day.


## Basic Process

  1. Establish start date (default is current date)
  2. Get the list of filenames
  3. Go through each constraint and mark those files
  4. Delete unmarked files


## Usage

This is a command line based application.

    $ purge_logs DIRECTORY
    5 logs purged

