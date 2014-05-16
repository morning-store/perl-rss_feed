#!/usr/bin/perl

# �K�v�ȃ��C�u�����̓ǂݍ���
use strict;
use warnings;
use Encode;
use FindBin;
use YAML::Tiny;
use XML::FeedPP;
use Digest::MD5;

# �����̃`�F�b�N
if (@ARGV == 4){

my $ServiceName = $ARGV[0];
my $source = $ARGV[1];
my $rssfile =  $ARGV[2];
my $HashName = $ARGV[3];
my $HashFile = '/status.yml';
# print $ServiceName .'.'. $HashName;

# �n�b�V���l�i�[�t�@�C���̑��݃`�F�b�N
#if (-f $HashFile) {
# �������Ȃ�
#}else{
#print"�t�@�C���͂���܂���I\n";
#�t�@�C���̍쐬
#}

# �e��ݒ�l�̎擾
#my $config = (YAML::Tiny->read($FindBin::Bin . '/config.yml'))->[0];
my $status = (YAML::Tiny->read($FindBin::Bin . $HashFile))->[0];
#my $source = $config->{'source'};
my $lastHash = $status->{$HashName};

# RSS �̓ǂݍ���
my $feed = XML::FeedPP->new($source);
$feed->sort_item();

# �Ō�擾���� RSS �A�C�e�����V���� RSS �A�C�e���𒲂ׂ�
my @updates;
for my $item ($feed->get_item()) {
    my $hash = &calcHash($item);
    last if $hash eq $lastHash;
    # �z��̓�����l�߂�
    unshift(@updates, $item);
}
# RSS �̓��e�����Ɏ擾
for my $item (@updates) {
    my $update = $item->pubDate() . ' ' . $item->title() . ' ' . $item->link();
# �擾���� RSS ���o�͂���
    open (OUT, ">>", $rssfile);
#   print (OUT $item->pubDate() . ',' . $item->title() . ',' . $item->link() . "\n");
    print (OUT $item->pubDate() . ',' . $item->title() . ',' . $item->description() .  ',' . $item->link() . "\n");
    close (OUT);
    $lastHash = &calcHash($item);
}

# �Ō�擾���� RSS �A�C�e���̃n�b�V���l��ۑ�
YAML::Tiny::DumpFile($FindBin::Bin . $HashFile, {$HashName => $lastHash});

# RSS ����n�b�V���l���v�Z����
sub calcHash {
    my $item = shift;
    my $id = $item->guid();
    my $url = $item->link();
    my $title = $item->title();
    my $pubDate = $item->pubDate();
    my $hashKey = '';
    $hashKey .= $id if $id;
    $hashKey .= $url if $url;
    $hashKey .= $title if $title;
    $hashKey .= $pubDate if $pubDate;
    return Digest::MD5->md5_hex($hashKey);
}

}else{
print "�����̐�������܂���B\n";
}