#!/usr/bin/perl

# 必要なライブラリの読み込み
use strict;
use warnings;
use Encode;
use FindBin;
use YAML::Tiny;
use XML::FeedPP;
use Digest::MD5;

# 引数のチェック
if (@ARGV == 4){

my $ServiceName = $ARGV[0];
my $source = $ARGV[1];
my $rssfile =  $ARGV[2];
my $HashName = $ARGV[3];
my $haFile = $ServiceName . $HashName . ".status";
my $HashFile = "/" . $ServiceName . $HashName . ".status";


# ハッシュ値格納ファイルの存在チェック
if (-f $haFile) {
#   die "$haFile は、すでに存在します。";
}else{
#ファイルの作成
  open (HashStatus, ">", $haFile);
#    or die ("$HashFile を書き込みモードでオープンすることができません。: $!");
  print HashStatus $HashName.": ";
  close (HashStatus);
}

# 各種設定値の取得
my $status = (YAML::Tiny->read($FindBin::Bin . $HashFile))->[0];
my $lastHash = $status->{$HashName};

# RSS の読み込み
my $feed = XML::FeedPP->new($source);
$feed->sort_item();

# 最後取得した RSS アイテムより新しい RSS アイテムを調べる
my @updates;
for my $item ($feed->get_item()) {
    my $hash = &calcHash($item);
    last if $hash eq $lastHash;
    # 配列の頭から詰める
    unshift(@updates, $item);
}
# RSS の内容を順に取得
for my $item (@updates) {
    my $update = $item->pubDate() . ' ' . $item->title() . ' ' . $item->link();
# 取得した RSS を出力する
    open (OUT, ">>", $rssfile);
    print (OUT "[title]: ". $item->title(). "\n" . "[desc]: " . $item->description() . "\n" ."[severity:score]: " . $item->get('sec:cvss@severity') . " : " . $item->get('sec:cvss@score') . "\n" ."[vector]: " . $item->get('sec:cvss@vector') . "\n" . "[identifier]: " . $item->get('sec:identifier') . "\n" . "[link]: " . $item->link() . "\n". "[pubData]: ".$item->get('dcterms:issued') . "\n". "[lastData]: ".$item->pubDate() . "\n\n");
    close (OUT);
    $lastHash = &calcHash($item);
}

# 最後取得した RSS アイテムのハッシュ値を保存
YAML::Tiny::DumpFile($FindBin::Bin . $HashFile, {$HashName => $lastHash});

# RSS からハッシュ値を計算する
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
print "引数の数が足りません。\n";
}

