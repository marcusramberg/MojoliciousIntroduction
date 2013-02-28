package Mojolicious::Plugin::SimpleSlides;

use Mojo::Base 'Mojolicious::Plugin';

has 'column_align' => 'top';

has 'column_template'  => 'simple_slides_column';
has 'columns_template' => 'simple_slides_columns';

has 'column_width';

has [qw/first_slide last_slide/] => 1;

sub register {
  my ($plugin, $app, $conf) = @_;

  push @{ $app->renderer->classes }, __PACKAGE__;

  $app->helper( simple_slides => sub { $plugin } );

  $app->helper( column  => \&_column );
  $app->helper( columns => \&_columns );

  $app->helper( prev_slide => sub {
    my $slide = shift->stash('slide');
    return $slide == 1 ? 1 : $slide - 1;
  });

  $app->helper( next_slide => sub {
    my $self = shift;
    my $slide = $self->stash('slide');
    return $slide == $self->simple_slides->last_slide ? $slide : $slide + 1;
  });

  $app->helper( code => sub {
    shift->tag('pre' => class => 'code-line' => @_);
  });

  $app->routes->any( 
    '/:slide',
    { slide => $plugin->first_slide },
    [ slide => qr/\d+/ ],
    sub {
      my $self = shift;
      my $slide = $self->stash( 'slide' );
      $self->layout( 'slide' );
      $self->render( $slide );
    }
  );

  return $plugin;
}

# helpers

sub _column { 
  my $c = shift;
  my $plugin = $c->simple_slides;
  my $content = pop || return;
  $content = ref $content ? $content->() : $content;

  my %args = @_;
  my $style = '';

  my $width = delete $args{width} // $plugin->column_width;        #/# highlight fix
  if ( $width ) {
    $style .= "width: $width%;";
  }

  if ( my $align = delete $args{align} || $plugin->column_align ) {
    $style .= "vertical-align: $align;";
  }
 
  return $c->render( 
    partial => 1, 
    'columns.style' => $style,
    'columns.column' => $content, 
    template => $plugin->column_template,
  );
}

sub _columns { 
  my $c = shift;
  return unless @_;
  my $content = shift->();
  return $c->render( 
    partial => 1, 
    'columns.content' => $content,
    template => $c->simple_slides->columns_template,
  );
}

1;

__DATA__

@@ simple_slides_column.html.ep
% my @tag = qw/div class column/;
% if ( my $style = stash 'columns.style' ) { push @tag, style => $style } 
%= tag @tag, begin
  %= stash 'columns.column'
% end

@@ simple_slides_columns.html.ep
<div class="columns-wrapper">
  <div class="columns">
    %= stash 'columns.content'
  </div>
</div>

@@ layouts/slide.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
    %= stylesheet '/ppi.css'
    %= stylesheet '/style.css'
    %= javascript '/ppi.js'
    %= javascript '/mousetrap.min.js'
    %= javascript begin
      Mousetrap.bind(['right', 'down', 'pagedown'], function(){
        window.location = "<%= url_for slide => { slide => next_slide } %>";
      });
      Mousetrap.bind(['left', 'up', 'pageup'], function(){
        window.location = "<%= url_for slide => { slide => prev_slide } %>";
      });
    % end
  </head>
  <body>
    <div class="container">
      <h1 class="center"><%= title %></h1>
      <div id="main">
        %= content
      </div>
      <div class="nav">
        <div class="nav-item">
          %= link_to Previous => slide => { slide => prev_slide }
        </div>
        <div class="nav-item">
          %= "Page $slide / " . simple_slides->last_slide
        </div>
        <div class="nav-item">
          %= link_to Next => slide => { slide => next_slide }
        </div>
      </div>
    </div>
  </body>
</html>
