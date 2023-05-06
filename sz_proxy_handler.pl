package sz;
use nginx;
use HTTP::Request;
use LWP::UserAgent;
use URI::Escape;
use Data::Dumper;

# our $our_host = "http://test.loc";
our $our_host = "http://localhost:8089";

sub webhandler {
	my $r = shift;
	
	if ($r->header_only) {
	    $r->send_http_header("text/html");
	    return OK;
	}
	
	if ( $r->uri =~ /^\/https?:\/\/?[a-z.]+\.wikipedia\.org/ || $r->uri =~ /test/ ) {
	    (my $uri = $r->uri) =~ s/\/(https?:\/)/\1\//;
	    $uri = uri_unescape($uri);
	    my $req = HTTP::Request->new();
	    $req->url($uri);
	    $req->method('GET');
	    $req->header('Referer' => 'https://wikipedia.org/');
	    my $ua = LWP::UserAgent->new();
	    $ua->agent('wget');
	    my $resp = $ua->request($req);
	    my $resp_headers = $resp->headers()->as_string;
	    
	    if ( $resp_headers =~ /Content-Type: text\/html/ ) {
		my $resp_content = $resp->content;
		$resp_content =~ s/(https?:\/\/upload.wikimedia.org)/$our_host\/\1/g;
		$resp_content =~ s/(\/\/[^\/]+\/wikipedia\/commons\/thumb)/$our_host\/https:\1/g;
#		$resp_content =~ s/\/w\/load\.php\?/$our_host\/https:\/\/ru.m.wikipedia.org\/w\/load.pnp\?/g;
		
		$r->send_http_header("text/html; charset=UTF-8");
		$r->print($resp_content);
	    }
	    else {
		$r->print( $resp_headers . $resp->content);
	    }
	    
#	    $r->send_http_header("text/html");
#	    $r->print($resp->as_string);
#	    $r->print(Dumper($resp));
	    return OK;
	}
	
	$r->send_http_header("text/html");
	(my $uri = $r->uri) =~ s/\/(https?:\/)/\1\//;
	$r->print(Dumper($r), $uri);
	return OK;
}
1;