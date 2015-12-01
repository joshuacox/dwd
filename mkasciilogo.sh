#/bin/sh
# make an ascii art logo from DDD.jpg
jp2a --color --background=dark --chars='  DDWWwwdd' -b --height=20 DWD.jpg | tee dwd.txt
echo 'https://github.com/joshuacox/dwd'>> dwd.txt
