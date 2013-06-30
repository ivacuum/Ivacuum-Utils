package Ivacuum::Utils::DB;

use common::sense;
use Exporter qw(import);
use Ivacuum::Utils qw(print_event);

our $VERSION = v1.0.14;
our @EXPORT = qw(db_connect db_ping sql_do sql_query);
our @EXPORT_OK = @EXPORT;

my $db;
my $db_host = '';
my $db_name = '';
my $db_user = '';
my $db_pass = '';

#
# Подключение к БД
#
sub db_connect {
  $db = DBI->connect('DBI:mysql:database=' . $db_name . ';mysql_socket=' . $db_host, $db_user, $db_pass);

  while (!$db) {
    &print_event('CORE', "\nНевозможно подключиться к БД MySQL '$db_name', расположенной на '$db_host'\nОписание ошибки: $DBI::errstr");
    sleep(5);
    $db = DBI->connect('DBI:mysql:database=' . $db_name . ';mysql_socket=' . $db_host, $db_user, $db_pass);
  }

  &print_event('CORE', 'Успешное подключение к БД');
}

#
# Проверка связи с БД
#
sub db_ping {
  if (!$db->ping()) {
    &print_event('CORE', 'Утеряна связь с сервером. Переподключение...');
    &db_connect();
  }
}

sub set_db {
  $db = shift;
}

sub set_db_credentials {
  ($db_host, $db_name, $db_user, $db_pass) = @_;
}

#
# Выполнение sql запроса и возврат идентификатора
#
sub sql_do {
  my($sql) = @_;

  &db_ping();
  
  $db->do($sql);
}

#
# Кэширование и выполнение sql запроса и возврат идентификатора
#
sub sql_query {
  my($sql) = @_;
  
  &db_ping();

  my $result = $db->prepare($sql) or die("Невозможно подготовить запрос:\n$sql\n$DBI::errstr");
  $result->execute() or die("Невозможно выполнить запрос:\n$sql\n$DBI::errstr");

  return $result;
}

1;