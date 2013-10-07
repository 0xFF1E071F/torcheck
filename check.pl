#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;

my %config = (
    local   => 0,
    url     => 'http://kpvz7ki2v5agwt35.onion/wiki/index.php/Main_Page',
    get     => 'curl -s --socks5-hostname 127.0.0.1:9050 ',
    check   => 'curl -sI --socks5-hostname 127.0.0.1:9050 ',
    regex   => {
       format => '^http://.*\.onion',
       list   => '<a rel="nofollow" class="external text" href="(.*)">.*</a>',
    },
);

GetOptions(
    'local=s' => \$config{local},
    'url=s'   => \$config{url},
    'get=s'   => \$config{get},
    'check=s' => \$config{check},
    'format=s'=> \$config{regex}{format},
    'list=s'  => \$config{regex}{list},
);

my @urls;
if ($config{local}) {
    print "Using local copy\n";
    @urls = `cat $config{local}` =~ /$config{regex}{list}/g

} else {
    print "Getting Hidden services list from $config{url}...\n";
    @urls = `$config{get} $config{url}` =~ /$config{regex}{list}/g
}

for my $url(@urls) {
    $url =~ s/\".*//g;
    next unless $url =~ $config{regex}{format} || $url =~ '\?';

    print "$url - ";
    if (`$config{check} $url`) {
        print 'Up';
    } else {
        print 'Down';
    }

    print "\n";
}

