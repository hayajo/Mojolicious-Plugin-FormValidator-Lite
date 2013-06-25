use Mojo::Base -strict;

use utf8;
use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'FormValidator::Lite' => {
    constraints  => [qw/Email +t::lib::MyApp::Validator::Constraint/],
    message_data => {
        param => {
            name     => '名前',
            email    => 'メールアドレス',
            homepage => 'ホームページアドレス',
        },
        function => 'ja',
    },
};

post '/user' => sub {
    my $self = shift;
    my $res = $self->validator(
        message_data => {
            message => {
                'email.email'  => '[_1] には正しいメールアドレスを入力してください',
                'homepage.url' => '[_1] には正しいホームページアドレスを入力してください',
            },
        },
    )->check(
        name     => [qw/NOT_NULL/],
        email    => [qw/NOT_NULL EMAIL/],
        homepage => [qw/URL/],
    );
    return $self->render( text => $self->param('name') ) if ( $res->is_valid );
    $self->res->code(422);
    $self->render( text => join("\n", $res->get_error_messages ) );
};

my $t = Test::Mojo->new;

subtest 'validation' => sub {
    $t->post_ok(
        '/user',
        form => {
            name     => 'taro yamada',
            email    => 'taro.yamada@example.jp',
            homepage => 'http://taro.example.jp/',
        },
    )->status_is(200)->content_is('taro yamada');

    $t->post_ok(
        '/user',
    )->status_is(422)->content_is("名前 を入力してください\nメールアドレス を入力してください");

    $t->post_ok(
        '/user',
        form => {
            name     => 'taro yamada',
            email    => 'taro.yamada_at_example.jp',
            homepage => "taro's homepage",
        },
    )->status_is(422)->content_is("メールアドレス には正しいメールアドレスを入力してください\nホームページアドレス には正しいホームページアドレスを入力してください");
};

done_testing;
