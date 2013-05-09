package Ivacuum::Utils::DB;

use 5.006;
use strict;
use warnings FATAL => 'all';

our $VERSION = v1.0.0;

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
# Кэширование и выполнение sql запроса и возврат идентификатора
#
sub sql_query {
  my($sql) = @_;
  
  &db_ping();

  my $result = $main::db->prepare($sql) or die("Невозможно подготовить запрос:\n$sql\n$DBI::errstr");
  $result->execute() or die("Невозможно выполнить запрос:\n$sql\n$DBI::errstr");

  return $result;
}

#
# Выполнение sql запроса и возврат идентификатора
#
sub sql_do {
  my($sql) = @_;

  &db_ping();
  
  $main::db->do($sql);
}

1;