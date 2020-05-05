#!/Perl/bin/perl -w



my $content = qq [
 < a href = "http://www.google.com/calendar/event?action=TEMPLATE&sprop=website:http://a.asos-style.com/&sprop=name:amama&trp=true&text=%e3%82%b2%e3%83%bc%e3%83%a0%e3%83%bb%e3%83%9f%e3%83%a5%e3%83%bc%e3%82%b8%e3%83%83%e3%82%af+%2d+DIGITAL+DEVIL+SAGA%7e%e3%82%a2%e3%83%90%e3%82%bf%e3%83%bc%e3%83%ab%e3%83%81%e3%83%a5%e3%83%bc%e3%83%8a%e3%83%bc%7e1%26amp%3b2+Original+Sound+Track+%e5%ae%8c%e5%85%a8%e4%bd%93++ <-- HERE %e7%99%ba%e5%a3%b2&dates=20051222/20051223&details=http://a.asos-style.com/asin/B000BV7VBO. html" >
                             ];

print $content."\n";

my $temp_content = $content;
                while ($temp_content =~ m/<\s*a\s*href\s*=\s*["'](.*?)['"].*?>/gisx) {
                        $link_url = $1;
        print "$link_url \n";
                        $link_url_id = 123456567;

                                $link_url =~ s/\?/\\\?/gs;
                                $link_url =~ s/\*/\\\*/gs;
                                $link_url =~ s/\./\\\./gs;
                                $link_url =~ s/\+/\\\+/gs;
                                $link_url =~ s/\(/\\\(/gs;
                                $link_url =~ s/\)/\\\)/gs;
                                $link_url =~ s/\[/\\\[/gs;
                                $link_url =~ s/\]/\\\]/gs;
                        $content =~ s/<\s*a\s*href\s*=\s*["']$link_url['"].*?>/<a href = "$link_url_id" >/gis;
        print "$content \n";
                }



exit;