use Mojolicious::Lite;


any '/' => sub {
  my $self = shift;
  my $val=$self->validation;
  return $self->render unless $val->has_data;

  $val->required('user')->size(1, 20)->like(qr/^[a-z0-9]+$/);
  $val->required('pass_again')->equal_to('pass')
    if $val->optional('pass')->size(7, 500)->is_valid;


  $self->session( user => $self->param('user') ) unless $val->has_error;
} => 'index';

any '/logout' => sub {
  my $self = shift;
  $self->session( expires => 1 );
  $self->redirect_to('/');
};

app->start;

__DATA__

@@ index.html.ep

% my $user = session 'user';
% title $user ? "Registered as \u$user" : "Please register";
% layout 'basic';
<style>
  label.field-with-error { color: #dd7e5e }
  input.field-with-error { background-color: #fd9e7e }
</style>

<h1><%= title %></h1>

% unless ($user) {
  %= form_for '/' => method => 'POST' => begin
    %= label_for user => 'Username (required, 1-20 characters, a-z/0-9)'
    <br>
    %= text_field 'user', id => 'user'
    <br>
    %= label_for pass => 'Password (optional, 7-500 characters)'
    <br>
    %= password_field 'pass', id => 'pass'
    <br>
    %= label_for pass_again => 'Password again (equal to the value above)'
    <br>
    %= password_field 'pass_again', id => 'pass_again'
    %= submit_button
  % end
% }

