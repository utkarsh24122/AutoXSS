#!/usr/bin/env bash

target="$1"

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m AutoXSS started on "$target" ! \e[0m\n" 

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Running Subdomain Enumeration ... \e[0m\n" 

cp /home/admin/reconftw/reconftw.sh reconftw.sh
cp /home/admin/reconftw/install.sh install.sh
cp /home/admin/reconftw/reconftw.cfg reconftw.cfg

./reconftw.sh -d $target -s --deep &>/dev/null

echo -e "\n\e[36m[\e[32m*\e[36m]\e[92m $(cat $(pwd)/Recon/"$target"/subdomains/subdomains.txt | wc -l) active subdomains found & $(cat $(pwd)/Recon/"$target"/webs/webs.txt | wc -l) active webs probed !  \e[0m\n" 

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Fetching URLs ... \e[0m\n"

cd Recon/"$target"/webs

mkdir -p .tmp

cat webs.txt webs_uncommon_ports.txt > .tmp/webs_all.txt

cat .tmp/webs_all.txt | waybackurls | anew -q .tmp/url_extract_tmp.txt

cat .tmp/webs_all.txt | gau --subs | anew -q .tmp/url_extract_tmp.txt

gospider -S .tmp/webs_all.txt --js -d 2 --sitemap --robots -w -r > .tmp/gospider.txt


[ -s ".tmp/gospider.txt" ] && sed -i '/^.\{2048\}./d' .tmp/gospider.txt
[ -s ".tmp/gospider.txt" ] && cat .tmp/gospider.txt | grep -aEo 'https?://[^ ]+' | sed 's/]$//' | grep -E "^(http|https):[\/]{2}([a-zA-Z0-9\-\.]+\.$domain)" | anew -q .tmp/url_extract_tmp.txt

cd .tmp
cp url_extract_tmp.txt ../allurls.txt
cd ../
echo -e "\n\e[36m[\e[32m*\e[36m]\e[92m $(cat $(pwd)/allurls.txt | wc -l) URLs found and saved in $(pwd)/allurls.txt  \e[0m\n"

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Filtering Parameters ... \e[0m\n"

cat allurls.txt | grep "$target" | grep "=" | qsreplace -a | grep -aEiv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)$" | anew -q .tmp/url_extract_tmp2.txt

cat .tmp/url_extract_tmp2.txt | uro | anew -q .tmp/url_extract_uddup.txt

cd .tmp
cp url_extract_uddup.txt ../params.txt
cd ../
echo -e "\n\e[36m[\e[32m*\e[36m]\e[92m $(cat $(pwd)/params.txt | wc -l) Unique params found and saved in $(pwd)/params.txt  \e[0m\n"

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Fuzzing Parameters for XSS... \e[0m\n"

cat params.txt | qsreplace FUZZ | sed '/FUZZ/!d' | Gxss -c 100 -p Xss | qsreplace FUZZ | sed '/FUZZ/!d' | anew -q .tmp/xss_reflected.txt

echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Scanning for XSS using Dalfox... \e[0m\n"

touch xss.txt

cat .tmp/xss_reflected.txt | dalfox pipe --silence --no-color --no-spinner --skip-mining-dom --skip-mining-dict --only-poc r --ignore-return 302,404,403 --skip-bav -w 200 | anew -q xss.txt

if [[ $(cat xss.txt | wc -l) -le 1 ]]; then
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m No XSS found ... Better Luck Next time \e[0m\n" && rm xss.txt
 
 else 
  cat xss.txt | cut -d " " -f2 | uro > uniq_xss.txt
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m $(cat uniq_xss.txt | wc -l) XSS found and Saved in "$(pwd)"/uniq_xss.txt \e[0m\n" 
fi

rm -rf .tmp
