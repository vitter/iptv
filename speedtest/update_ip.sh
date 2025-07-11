#!/bin/bash

if [ $# -lt 2 ]; then
  echo "请输入省市和运营商参数，如: Shanghai Telecom"
  echo "用法: $0 <省市> <运营商>"
  echo "运营商可选: Telecom, Unicom, Mobile"
  exit 1
fi

# 格式化输入参数：首字母大写，其他字母小写
format_string() {
    local input="$1"
    # 转换为小写，然后首字母大写
    echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/^./\U&/'
}

region=$(format_string "$1")
isp=$(format_string "$2")
quake360token=" "  # 请在此处填写你的 quake360 token

# 创建必要的目录
mkdir -p sum/tmp
mkdir -p "sum/${isp}"

echo "===============从 fofa 检索 ip+端口================="
        url_fofa=$(echo  '"udpxy" && country="CN" && region="'$region'" && org="China '$isp' Group" && protocol="http"' | base64 |tr -d '\n')
        url_fofa="https://fofa.info/result?qbase64="$url_fofa

# 使用代理连接
curl -o test.html "$url_fofa"

grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$' test.html | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' > ip.tmp
echo "本次fofa搜索结果："
cat ip.tmp
echo "------结果保存至 ip.tmp------"

echo "===$region==="
curl -o quake.tmp --location 'https://quake.360.net/api/v3/search/quake_service' \
--header 'X-QuakeToken: '$quake360token \
--header 'Content-Type: application/json' \
--data "$(jq -n --arg province "$region" '{
    query: "\"udpxy\" AND country: \"CN\" AND province: \"\($province)\" AND org: \"China '$isp'\" AND protocol: \"http\"",
    start: 0,
    size: 50,
    ignore_cache: "False",
    latest: "True"
}')"
count=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}_[0-9]{1,5}' quake.tmp|wc -l)
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}_[0-9]{1,5}' quake.tmp|sed 's/_/:/' >> ip.tmp
echo "======quake360 结果 $count 个   追加到文件: ip.tmp========================"


# 调用speedtest_from_list.sh进行测速
echo "-----------------开始调用speedtest_from_list.sh测速----------------"
bash speedtest_from_list.sh ip.tmp $region $isp
echo "-----------------测速完成----------------"
echo "-----------------删除临时文件---------------"
rm quake.tmp test.html ip.tmp
echo "-----------------临时文件已删除---------------"
