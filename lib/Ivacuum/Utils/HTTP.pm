package Ivacuum::Utils::HTTP;

use 5.006;
use strict;
use warnings FATAL => 'all';

our $VERSION = v1.0.0;

sub http_not_found {
  my($session, $url) = @_;

  my $msg = '<!DOCTYPE html><html><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL /' . $url . ' was not found on this server.</p></body></html>';

  print $session "HTTP/1.1 404 Not Found\r\nServer: $main::g_server_string\r\nDate: ", strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime), "\r\nConnection: close\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: ", length($msg), "\r\n\r\n", $msg;

  return &close_connection($session);
}

sub http_redirect {
  my($session, $url) = @_;

  print $session "HTTP/1.1 302 Found\r\nServer: $main::g_server_string\r\nDate: ", strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime), "\r\nConnection: close\r\nContent-Type: text/html\r\nLocation: ", $url, "\r\nContent-Length: 0\r\n\r\n";

  return &close_connection($session);
}

sub http_redirect_internal {
  my($session, $url) = @_;

  print $session "HTTP/1.1 302 Found\r\nX-Accel-Redirect: ", $url, "\r\n\r\n";

  return &close_connection($session);
}

1;