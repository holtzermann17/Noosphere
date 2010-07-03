# NooSphere module timing benchmark routines (for profiling?)
package benchmarks;

use strict;
use Time::HiRes qw(gettimeofday);

sub bm_gettime {
  # return (times)[0];
  return gettimeofday();
}

$benchmarks::__benmarks_pl_DATA_repository = '';
$benchmarks::__benmarks_pl_DATA_last_time = -1;
$benchmarks::__benmarks_pl_FLAG_isInactive = 1;
$benchmarks::__benmarks_pl_DATA_steps = 0;
$benchmarks::__benmarks_pl_DATA_maxdiff = 0;
$benchmarks::__benmarks_pl_DATA_maxdiffpos = -1;


sub bm_clear {
  $benchmarks::__benmarks_pl_DATA_repository = '';
  $benchmarks::__benmarks_pl_DATA_last_time = -1;
  $benchmarks::__benmarks_pl_DATA_first_time = benchmarks::bm_gettime();
  $benchmarks::__benmarks_pl_DATA_steps = 0;
  $benchmarks::__benmarks_pl_DATA_maxdiff = 0;
  $benchmarks::__benmarks_pl_DATA_maxdiffpos = -1;
}


sub bm_addmsg {
  my ($msgstr) = @_;

  if ($benchmarks::__benmarks_pl_FLAG_isInactive) { return; }
  my ($nustr, $curtime, $timedif);

  $benchmarks::__benmarks_pl_DATA_steps++;
  $curtime = benchmarks::bm_gettime();
  if ($benchmarks::__benmarks_pl_DATA_last_time != -1) {
    $timedif = $curtime - $benchmarks::__benmarks_pl_DATA_last_time;
  } else {
    $timedif = 0;
  }
  if ($timedif < 0.0001) {
    $timedif = 0;
  }
#  $nustr = "-- '$msgstr',  at $curtime. ($timedif sec. ellapsed since last msg.)\n";
  if ($timedif > $benchmarks::__benmarks_pl_DATA_maxdiff) {
    $benchmarks::__benmarks_pl_DATA_maxdiff = $timedif;
    $benchmarks::__benmarks_pl_DATA_maxdiffpos = $benchmarks::__benmarks_pl_DATA_steps;
  }
  $nustr = "($curtime) [diff=$timedif sec.] " . $benchmarks::__benmarks_pl_DATA_steps . ". '$msgstr'\n";
  $benchmarks::__benmarks_pl_DATA_last_time = $curtime;
  $benchmarks::__benmarks_pl_DATA_repository = $benchmarks::__benmarks_pl_DATA_repository . $nustr;
}

sub bm_getreport {
  if ($benchmarks::__benmarks_pl_FLAG_isInactive) { return ''; }
  benchmarks::bm_addmsg ("Generating Benchmark Report.");
  benchmarks::bm_addmsg ("Total running time is : " . (benchmarks::bm_gettime() - $benchmarks::__benmarks_pl_DATA_first_time)
    . "sec. in " . $benchmarks::__benmarks_pl_DATA_steps . " steps.");
  benchmarks::bm_addmsg ("Largest time gap: " . $benchmarks::__benmarks_pl_DATA_maxdiff . " in step "
    . $benchmarks::__benmarks_pl_DATA_maxdiffpos . ".");
  return  "\n<!-- \n\n" . $benchmarks::__benmarks_pl_DATA_repository . "\n--\>  \n\n";
}

# images unfortunately may fail if extra information is added (I will need to
# check with the PNG format spec to see if there's a way around this.)
# so for now, when an image is requested the benchmarks are temporarily disabled.

sub bm_handleimage {
  benchmarks::bm_clear;
  $benchmarks::__benmarks_pl_FLAG_isInactive = 1;
}

1;

