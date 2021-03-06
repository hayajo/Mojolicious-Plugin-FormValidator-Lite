use Mojo::Base -strict;

use utf8;
use Test::More;
use Test::Mojo;

require 't/myapp.pl';

my $t = Test::Mojo->new;

subtest 'validation' => sub {
    $t->post_ok( '/', form => {
        username => 'taro yamada',
        email    => 'taro.yamada@example.jp',
        homepage => 'http://taro.example.jp/',
        profile_image => {
            file           => 't/icon.png',
            'Content-Type' => 'image/png',
        },
    } )->status_is(200)
       ->content_like(qr/taro yamadaを登録しました/);

    $t->post_ok('/')
      ->status_is(422)
      ->content_like(qr/登録に失敗しました/)
      ->content_like(qr/ユーザー名 を入力してください/)
      ->content_like(qr/メールアドレス を入力してください/);

    $t->post_ok( '/', form => {
        name     => 'taro yamada',
        email    => 'taro.yamada_at_example.jp',
        homepage => "taro's homepage",
        profile_image => {
            file           => 't/icon_large.png',
            'Content-Type' => 'image/png',
        },
    } )->status_is(422)
       ->content_like(qr/メールアドレス にはメールアドレスを入力してください/)
       ->content_like(qr/ホームページアドレス には正しいアドレスを入力してください/)
       ->content_like(qr/プロフィール画像 のファイルサイズがただしくありません/);
};

done_testing;
