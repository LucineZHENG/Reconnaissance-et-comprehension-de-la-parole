#!/usr/local/bin/perl

# 配置路径
$HPARSE = "HParse";
$SOURCE = "lists/keywordsplus.net";      # 源文件 (语法)
$TARGET = "lists/keywordsplus.net2";     # 目标文件 (加权后的晶格)

# 1. 检查源文件是否存在
if (! -e $SOURCE) {
    die "❌ 错误: 找不到源文件 $SOURCE\n请确保 lists/keywordsplus.net 存在且内容正确。\n";
}

# 2. 第一步：编译 (使用 HParse 生成基础晶格)
print "=== 1.正在编译基础网络 (HParse) ===\n";
system("$HPARSE $SOURCE tmp_base.slf");

if (! -e "tmp_base.slf") {
    die "❌ 编译失败，请检查语法文件格式。\n";
}

# 3. 第二步：注入权重 (生成 net2)
print "=== 2.正在生成加权文件 ($TARGET) ===\n";

open(IN, "tmp_base.slf") || die "无法打开临时文件";
open(OUT, ">$TARGET") || die "无法创建目标文件 $TARGET";

# 定义你的10个关键词 (必须与字典一致)
%bonusWords = map { $_ => 1 } qw(france match concert monde bresil zidane ronaldo ballon but supporters);
%nodeWord = ();

# --- 第一次扫描：记录节点 ID 对应的单词 ---
while(<IN>) {
    if (/I=(\d+).*W=([^\s]+)/) {
        $nodeWord{$1} = $2;
    }
}
seek(IN, 0, 0); # 回到文件开头重新读取

# --- 第二次扫描：写入文件并添加权重 ---
while(<IN>) {
    chomp;
    $line = $_;
    
    # 检查这行是不是连接线 (J=... E=目标节点)
    if ($line =~ /J=\d+.*E=(\d+)/) {
        $endNode = $1;
        $word = $nodeWord{$endNode};
        
        # 情况 A: 如果连向关键词 -> 奖励 l=50.0
        if (exists $bonusWords{$word}) {
            print OUT "$line l=50.0\n";
        }
        # 情况 B: 如果连向 !NULL (跳转节点) -> 保持原样
        elsif ($word eq "!NULL") {
            print OUT "$line\n";
        }
        # 情况 C: 如果连向垃圾音素 -> 惩罚 l=-10.0 (为了更好的效果，建议加上)
        else {
            print OUT "$line l=-10.0\n";
        }
    } else {
        # 其他行 (Header, Node定义) 原样复制
        print OUT "$line\n";
    }
}

close(IN);
close(OUT);
unlink("tmp_base.slf"); # 删除临时文件

print "\n✅ 成功！文件已生成: $TARGET\n";
print "你现在可以使用 runDetections3.pl 直接调用这个文件了。\n";