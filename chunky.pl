use IO::Socket;



my $sock = new IO::Socket::INET (

  PeerAddr => 'chiurcas001.techlabs.accenture.com',

  PeerPort => '7002',

  Proto => 'tcp',

);



die "Could not create socket: $!\n" unless $sock;



$input = qq{

So/RB far/RB ,/, Cummins/NNP says/VBZ ,/, grassroots/VBZ activists/NNS have/VBP beaten/VBN back/RP these/DT assaults/NNS ./.

};



print $sock $input . "\n";

print $sock "\n";

while(<$sock>) {

  if(/\w+/){

    print $_;

    <$sock>;

    last;

  }

}

