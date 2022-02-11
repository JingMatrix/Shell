#!/bin/sh
curl https://mp.weixin.qq.com/mp/appmsgalbum\?action\=getalbum\&album_id\=1536719688897003521 >/tmp/qinshi
sed -n -E "/^\s+title: '【秦空悟流】/,/url/!d;s/^\s+//;s/:/\t/;/_\w+\t '/d;p" /tmp/qinshi | head -4
