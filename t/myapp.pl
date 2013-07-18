#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;
use HTML::FillInForm::Lite;

plugin 'FormValidator::Lite' => {
    constraints  => [qw/Email File +t::lib::MyApp::Validator::Constraint/],
    message_data => {
        param => {
            username      => 'ユーザー名',
            email         => 'メールアドレス',
            homepage      => 'ホームページアドレス',
            profile_image => 'プロフィール画像',
        },
        function => 'ja',
    },
};

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

post '/' => sub {
    my $self = shift;
    $self->validator(
        message_data => {
            message => {
                'homepage.url' => '[_1] には正しいアドレスを入力してください',
            },
        },
    )->check(
        username      => [qw/NOT_NULL/],
        email         => [qw/NOT_NULL EMAIL_LOOSE/],
        homepage      => [qw/URL/],
        profile_image => [[FILE_SIZE => 1024 * 30]], # 30KB以下
    );

    if ( $self->validator->has_error ) {
        $self->stash( error => '登録に失敗しました' );
        $self->res->code(422);
        return $self->render_filled_html('index');
    }

    $self->stash( info => $self->param('username') . "を登録しました" );
    $self->render('index');
};

helper render_filled_html => sub {
    my ( $c, $template, $params ) = @_;
    $params ||= $c->req->params->to_hash || {};
    my $html = $c->render( $template, partial => 1 );
    $c->render(
        text   => HTML::FillInForm::Lite->fill( \$html, $params ),
        format => 'html'
    );
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'ユーザー登録';
<form action="/" method="post" enctype="multipart/form-data">
  <div>
    <label class="control-label" for="username">ユーザー名</label>
    <input type="text" name="username" id="username">
    % if (validator->is_error('username')) {
    <div>
      <span><%= join " ", validator->get_error_messages_from_param('username') %></span>
    </div>
    % }
  </div>
  <div>
    <label class="control-label" for="email">メールアドレス</label>
    <input type="text" name="email" id="email">
    % if (validator->is_error('email')) {
    <div>
      <span><%= join " ", validator->get_error_messages_from_param('email') %></span>
    </div>
    % }
  </div>
  <div>
    <label class="control-label" for="homepage">ホームページアドレス</label>
    <input type="text" name="homepage" id="homepage">
    % if (validator->is_error('homepage')) {
    <div>
      <span><%= join " ", validator->get_error_messages_from_param('homepage') %></span>
    </div>
    % }
  </div>
  <div>
    <label class="control-label" for="profile_image">プロフィール画像</label>
    <input type="file" name="profile_image" id="profile_image">
    % if (validator->is_error('profile_image')) {
    <div>
      <span><%= join " ", validator->get_error_messages_from_param('profile_image') %></span>
    </div>
    % }
  </div>
  <div>
    <button type="submit">登録</button>
  </div>
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body>
  % for my $level (qw/error warning success info/) {
    % if (my $message = $self->stash($level)) {
    <div class="alert alert-<%= $level %>">
      <%= $message %>
    </div>
    % }
  % }
  <%= content %>
  </body>
</html>
