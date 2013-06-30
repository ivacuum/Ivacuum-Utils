package Ivacuum::Utils;

use common::sense;
use Exporter qw(import);
use JSON qw(decode_json);
use POSIX qw(strftime);

our $VERSION = v1.0.13;
our @EXPORT = qw(close_connection date_format html_msg html_msg_simple load_json_config num_format parse_qs print_event);
our @EXPORT_OK = @EXPORT;

my $g_debug    = 1;
my $g_sitename = '';

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
# Оформленное сообщение
#
sub html_msg {
  my($session, $title, $msg) = @_;

  print $session <<HTML;
HTTP/1.1 200 OK
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Content-type: text/html; charset=utf-8
Cache-Control: no-cache, pre-check=0, post-check=0
Expires: Fri, 1 Jan 2010 00:00:00 GMT
Pragma: no-cache

<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <title>${title}</title>
  <link rel="shortcut icon" href="//ivacuum.org/i/_/server_network.png">
  <link rel="stylesheet" href="//ivacuum.org/i/bootstrap/2.3.1/css/bootstrap.min.css">
  <link rel="stylesheet" href="//ivacuum.org/i/bootstrap/2.3.1/expansion.css">
</head>
<body>
<div class="wrap-content">
  <div class="navbar navbar-fixed-top">
    <div class="navbar-inner">
      <div class="container">
        <a class="brand" href="/stats">${g_sitename}</a>
      </div>
    </div>
  </div>
  <div class="container">
    ${msg}
    <div class="wrap-push"></div>
  </div>
</div>
</body>
</html>
HTML

  return &close_connection($session);
}

sub html_msg_simple {
  my($session, $msg) = @_;

  print $session <<HTML;
HTTP/1.1 200 OK
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Content-type: text/html; charset=utf-8
Cache-Control: no-cache, pre-check=0, post-check=0
Expires: Fri, 1 Jan 2010 00:00:00 GMT
Pragma: no-cache

${msg}
HTML

  return &close_connection($session);
}

#
# Загрузка настроек из файла в формате json
#
sub load_json_config {
  my($file, $cfg) = @_;
  
  local $/;
  open my $fh, '<', "./$file";
  my $json = <$fh>;
  my $config = decode_json($json);
  @$cfg{keys %$config} = values %$config;
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
# Выводит информацию о событии (при $g_debug > 0)
#
sub print_event {
  my($code, $text) = @_;

  printf("%s: %s: %s\n", &get_timestamp(), $code, $text) if $g_debug > 1 or $code eq 'CORE';
}

sub set_debug_level {
  $g_debug = shift;
}

sub set_sitename {
  $g_sitename = shift;
}

1;