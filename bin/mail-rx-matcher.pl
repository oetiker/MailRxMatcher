#!/usr/bin/env perl

use FindBin;use lib "$FindBin::RealBin/../lib";use lib "$FindBin::RealBin/../thirdparty/lib/perl5"; # LIBDIR
use Mojo::Base -strict,-signatures;
use Email::MIME;
use HTML::Entities;
use HTML::FormatText;
use Mojo::Util qw(getopt);
use Encode;
use Pod::Usage;

getopt
  'charset=s' => \my $charset,
  'printbody' => \my $printbody,
  'onmatch=s' => \my $onmatch,
  'man|help' => \my $man;


$charset //= 'utf8';
$onmatch //= 'MATCH';

pod2usage(-verbose => 2, -exitval => 1) if $man or -t;

my $msg = join "", <STDIN>;

my $email = Email::MIME->new($msg);

my @matchers = map { decode($charset,$_) } @ARGV;

for (@matchers) {
   die "Regular Expression '$_' matches everything\n" 
    if 'asdfl;kjasdflkjaf98yp43rhoiu;adlksfjnbsdf' =~ /$_/;
}

$printbody = 1 unless @matchers;

for my $matcher (@matchers) {
  if ($email->header_str('Subject') =~ /$matcher/i){
     print $onmatch;
     exit 0;
  }
}


$email->walk_parts(sub {
    my ($part) = @_;
    return if $part->subparts; # multipart
    if ($part->content_type =~ m{^text/}i){
        my $body = decode_entities($part->body_str);
        if ($part->content_type =~ m{html}i){
            $body = HTML::FormatText->format_string(
                $body,
                leftmargin=>0,
                rightmargin=>80
            );
        }
        print encode($charset,$body) if $printbody;
        for my $matcher (@matchers) {
            if ($body =~ /$matcher/){
                print $onmatch;
                exit 0;
           }
        }
    }; 
});
# exit 1 for no match is helpful when writing simple procmail scripts
# which should eat any mail without backing it up ... 
exit 1;

=pod

=head1 NAME

mail-rx-match.pl - mail text extraction helper

=head1 SYNOPSYS

cat mail_message | mail-rx-match.pl [options] [rx1 [rx2 [...]]]

  --charset=x       specify the character-set in use in the shell
                    default is utf8

  --printbody       output the extracted text even when regular
                    expressions are specified

  --onmatch=y       print the given string to STDOUT if one of the
                    regular expressions matches. Default is MATCH.

=head1 DESCRIPTION

Extract the text content from a mail message to build a target for
keyword matching.

If called without rx arguments the extracted text from the mail message
goes out to STDOUT.

If there is one or more regular expressions specified as arguments, the
extracted text is matched against these regular expressions and if there
is a match, the text `MATCH` get printed to STDOUT. This makes it quite simple to use the program for spam filtering with procmail.

The program exits with 1 if there is NO match and with 0 if there is a match.

=head1 EXAMPLE

 # spam with image
 :0 BH
 * Content-Type.*jpeg
 CATCH=| ./opt/mail2txt/bin/mail-rx-match.pl --charset=utf8 '(Bad|Ugly|Words)'

 :0
 * ? test "$CATCH" = MATCH
 mail/spam

=head1 COPYRIGHT

2019 OETIKER+PARTNER AG

=head1 LICENSE

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=head1 AUTHOR

Tobias Oetiker E<lt>tobi@oetiker.chE<gt>

=head1 SEE ALSO

L<Email::MIME>, L<HTML::Entities>, L<HTML::FormatText>

