package Ivacuum::Utils::BitTorrent;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Exporter qw(import);
use Ivacuum::Utils qw(close_connection);

our $VERSION = v1.0.5;
our @EXPORT = qw(btt_msg btt_msg_die ip2long);
our @EXPORT_OK = @EXPORT;

sub _dechunk {
  my $chunks = shift;
  my $item   = shift(@{$chunks});

  # Словари
  if ($item eq 'd') {
    $item = shift(@{$chunks});
    my %hash;

    while ($item ne 'e') {
      unshift(@{$chunks}, $item);
      my $key = _dechunk($chunks);
      $hash{$key} = _dechunk($chunks);
      $item = shift(@{$chunks});
    }

    return \%hash;
  }

  # Списки
  if ($item eq 'l') {
    $item = shift(@{$chunks});
    my @list;

    while ($item ne 'e') {
      unshift(@{$chunks}, $item);
      push(@list, _dechunk($chunks));
      $item = shift(@{$chunks});
    }

    return \@list;
  }

  # Числа
  if ($item eq 'i') {
    my $num;
    $item = shift(@{$chunks});

    while ($item ne 'e') {
      $num .= $item;
      $item = shift(@{$chunks});
    }

    return $num;
  }

  # Строки
  if ($item =~ /\d/) {
    my $num;

    while ($item =~ /\d/) {
      $num .= $item;
      $item = shift(@{$chunks});
    }

    my $line = '';

    for (1 .. $num) {
      $line .= shift(@{$chunks});
    }

    return $line;
  }

  return $chunks;
}

sub bencode {
  no locale;
  my $s    = shift;
  my $line = '';

  # Словари
  if (ref $s eq 'HASH') {
    $line = 'd';

    foreach my $key (sort keys %{$s}) {
      $line .= bencode($key);
      $line .= bencode(${$s}{$key});
    }

    $line .= 'e';
    return $line;
  }

  # Списки
  if (ref $s eq 'ARRAY') {
    $line = 'l';

    foreach my $l (@{$s}) {
      $line .= bencode($l);
    }

    $line .= 'e';
    return $line;
  }

  # Числа
  if ($s =~ /^\d+$/) {
    return sprintf('i%de', $s);
  }

  # Строки
  return sprintf('%d:%s', length($s), $s);
}

sub bdecode {
  my $s      = shift;
  my @chunks = split //, $s;
  my $root   = _dechunk(\@chunks);
  return $root;
}

#
# Сообщение трекера
#
sub btt_msg {
  my($session, $msg) = @_;

  print $session <<HTML;
HTTP/1.1 200 OK
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Content-type: text/plain

{bencode($msg)}
HTML

  return &close_connection($session);
}

#
# Ошибка трекера
# Используются $main::event и $main::g_announce_interval
#
sub btt_msg_die {
  my($session, $msg) = @_;

  return &close_connection($session) if $main::event eq 'stopped';
  
  $params = {
    'min interval'   => $main::g_announce_interval,
    'failure reason' => $msg,
    'warning reason' => $msg,
  };

  print $session <<HTML;
HTTP/1.1 200 OK
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Content-type: text/plain

{bencode($params)}
HTML

  return &close_connection($session);
}

#
# converts an IP address x.x.x.x into a long IP number as used by ulog
#
sub ip2long {
  my $ip_address = shift;
  my(@octets, $octet, $ip_number, $number_convert);

  chomp $ip_address;
  @octets = split /\./, $ip_address;
  $ip_number = 0;

  foreach $octet (@octets) {
    $ip_number <<= 8;
    $ip_number |= $octet;
  }

  return $ip_number;
}

1;