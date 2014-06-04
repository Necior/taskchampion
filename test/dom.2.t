#! /usr/bin/env perl
################################################################################
##
## Copyright 2006 - 2014, Paul Beckingham, Federico Hernandez.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included
## in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##
## http://www.opensource.org/licenses/mit-license.php
##
################################################################################

use strict;
use warnings;
use Test::More tests => 5;

# Ensure environment has no influence.
delete $ENV{'TASKDATA'};
delete $ENV{'TASKRC'};

# Create the rc file.
if (open my $fh, '>', 'dom.rc')
{
  print $fh "data.location=.\n",
            "dateformat=YMD\n",
            "dateformat.info=YMD\n";
  close $fh;
}

# DOM reference to other task.
qx{../src/task rc:dom.rc add one due:20110901 2>&1};
qx{../src/task rc:dom.rc add two due:1.due 2>&1};
my $output = qx{../src/task rc:dom.rc 2 info 2>&1};
like ($output, qr/Due\s+20110901/, 'Found due date duplicated via dom');

# DOM reference to the current task.
qx{../src/task rc:dom.rc add three due:20110901 wait:due 2>&1};
$output = qx{../src/task rc:dom.rc 3 info 2>&1};
like ($output, qr/Waiting until\s+20110901/, 'Found wait date duplicated from due date');

# ID <--> UUID <--> ID round trip via DOM.
$output = qx{../src/task rc:dom.rc _get 1.uuid 2>&1};
like ($output, qr/^.{36}$/, 'DOM id --> uuid');
my $uuid = chomp $output;
$output = qx{../src/task rc:dom.rc _get ${uuid}.id 2>&1};
like ($output, qr/^1$/, 'DOM uuid --> id');

# Failed DOM lookup returns blank.
$output = qx{../src/task rc:dom.rc _get 4.description 2>&1};
like ($output, qr/^$/, "DOM 4.description --> ''");

# Cleanup.
unlink qw(pending.data completed.data undo.data backlog.data dom.rc);
exit 0;

