package Ivacuum::Utils::DB;

use 5.006;
use strict;
use warnings FATAL => 'all';
use Exporter qw(import);
use Ivacuum::Utils qw(print_event);

our $VERSION = v1.0.2;
our @EXPORT = qw(db_connect db_ping sql_do sql_query);
our @EXPORT_OK = @EXPORT;

#
# Подключение к БД
#
sub db_connect {
  $main::db = DBI->connect('DBI:mysql:database=' . $main::db_name . ';mysql_socket=' . $main::db_host, $main::db_user, $main::db_pass);

  while (!$main::db) {
    &print_event('CORE', "\nНевозможно подключиться к БД MySQL '$main::db_name', расположенной на '$main::db_host'\nОписание ошибки: $DBI::errstr");
    sleep(5);
    $main::db = DBI->connect('DBI:mysql:database=' . $main::db_name . ';mysql_socket=' . $main::db_host, $main::db_user, $main::db_pass);
  }

  &print_event('CORE', 'Успешное подключение к БД');
}

#
# Проверка связи с БД
#
sub db_ping {
  if (!$main::db->ping()) {
    &print_event('CORE', 'Утеряна связь с сервером. Переподключение...');
    &db_connect();
  }
}

#
# Выполнение sql запроса и возврат идентификатора
#
sub sql_do {
  my($sql) = @_;

  &db_ping();
  
  $main::db->do($sql);
}

#
# Кэширование и выполнение sql запроса и возврат идентификатора
#
sub sql_query {
  my($sql) = @_;
  
  &db_ping();

  my $result = $main::db->prepare($sql) or die("Невозможно подготовить запрос:\n$sql\n$DBI::errstr");
  $result->execute() or die("Невозможно выполнить запрос:\n$sql\n$DBI::errstr");

  return $result;
}

1;