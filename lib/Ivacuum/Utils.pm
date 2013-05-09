package Ivacuum::Utils;

use 5.006;
use strict;
use warnings FATAL => 'all';
use POSIX qw(strftime);

our $VERSION = v1.0.0;

#
# Завершение сеанса связи с клиентом
#
sub close_connection {
  my($session) = @_;

  $session->flush();
  shutdown $session, 2;

  return 0;
}

#
# Продолжительность
#
sub date_format {
  my $timestamp = shift;
  return sprintf('%d дн. %02d:%02d:%02d', $timestamp / 86400, $timestamp / 3600 % 24, $timestamp / 60 % 60, $timestamp % 60);
}

#
# Текущая метка времени
#
sub get_timestamp {
  my($format) = @_;
  my($sec, $min, $hour, $mday, $mon, $year) = localtime();

  $format = '%04d-%02d-%02d %02d:%02d:%02d' unless $format;

  return sprintf($format, $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
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

#
# Сообщение трекера
#
sub html_msg {
  my($session, $title, $msg) = @_;

  print $session "HTTP/1.1 200 OK\r\nDate: ", strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime), "\r\nServer: $main::g_server_string\r\nConnection: close\r\nContent-type: text/html; charset=utf-8\r\nCache-Control: no-cache, pre-check=0, post-check=0\r\nExpires: Fri, 1 Jan 2010 00:00:00 GMT\r\nPragma: no-cache\r\n\r\n".'<!DOCTYPE html><html lang="ru"><head><meta charset="utf-8"><title>', $title, '</title><link rel="shortcut icon" href="//ivacuum.org/i/_/server_network.png"><link rel="stylesheet" href="//ivacuum.org/i/bootstrap/2.0.0/style.css"><link rel="stylesheet" href="//ivacuum.org/i/bootstrap/2.0.0/expansion.css"></head><body><div class="navbar navbar-fixed-top"><div class="navbar-inner"><div class="container"><a class="brand" href="/stats">', $main::g_sitename, '</a></div></div></div><div class="container">', $msg, '</div></body></html>';

  return &close_connection($session);
}

sub html_msg_simple {
  my($session, $msg) = @_;

  print $session "HTTP/1.1 200 OK\r\nDate: ", strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime), "\r\nServer: $main::g_server_string\r\nConnection: close\r\nContent-type: text/html; charset=utf-8\r\nCache-Control: no-cache, pre-check=0, post-check=0\r\nExpires: Fri, 1 Jan 2010 00:00:00 GMT\r\nPragma: no-cache\r\n\r\n", $msg;

  return &close_connection($session);
}

#
# Форматирование числа
#
sub num_format {
  local $_ = shift;
  1 while s/^(-?\d+)(\d{3})/$1 $2/;
  return $_;
}

#
# Выделение из строки пар ключ=значение
#
sub parse_qs {
  my $s     = shift;
  my @pairs = split /&/, $s;
  my %hash;

  foreach my $pair (@pairs) {
    next unless $pair;
    my($key, $value) = split /=/, $pair;
    $hash{$key} = $value;
  }

  return %hash;
}

#
# Выводит информацию о событии (при $main::g_debug > 0)
#
sub print_event {
  my($code, $text) = @_;

  printf("%s: %s: %s\n", &get_timestamp(), $code, $text) if $main::g_debug > 1 or $code eq 'CORE';
}

1;