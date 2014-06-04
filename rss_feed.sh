#!/bin/sh

#　環境変数を定義
USERINFO=~/.bash_profile
source ${USERINFO}

#　RSS対象を定義
perl /root/rss_jvnipedia.pl ipedia http://jvndb.jvn.jp/ja/rss/jvndb.rdf jvn_ipedia.log info
perl /root/rss_feed.pl jvn http://jvn.jp/rss/jvn.rdf jvn.log info

