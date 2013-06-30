package Ivacuum::Utils::HTTP;

use common::sense;
use Exporter qw(import);
use Ivacuum::Utils qw(close_connection);

our $VERSION = v1.0.10;
our @EXPORT = qw(http_not_found http_redirect http_redirect_internal);
our @EXPORT_OK = @EXPORT;

sub http_not_found {
  my($session, $url) = @_;

  my $msg << HTML;
<!DOCTYPE html>
<html>
<head>
  <title>404 Not Found</title>
</head>
<body>
<h1>Not Found</h1>
<p>The requested URL /${url} was not found on this server.</p>
</body>
</html>
HTML

  print $session <<HTML;
HTTP/1.1 404 Not Found
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Content-Type: text/html; charset=utf-8
Content-Length: {length($msg)}

${msg}
HTML

  return &close_connection($session);
}

sub http_redirect {
  my($session, $url) = @_;

  print $session <<HTML;
HTTP/1.1 302 Found
Date: {strftime('%a, %e %b %Y %H:%M:%S GMT', gmtime)}
Connection: close
Location: ${url}

HTML

  return &close_connection($session);
}

sub http_redirect_internal {
  my($session, $url) = @_;

  print $session <<HTML;
HTTP/1.1 302 Found
X-Accel-Redirect: ${url}

HTML

  return &close_connection($session);
}

1;