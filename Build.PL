use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Ivacuum::Utils',
    license             => 'artistic',
    dist_author         => q{Sergey Pankov <vacuum@ivacuum.ru>},
    dist_version_from   => 'lib/Ivacuum/Utils.pm',
    dist_abstract       => 'Collection of useful Utils',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'Ivacuum-Utils-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
