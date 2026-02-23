#!/usr/local/bin/perl

# --- 配置 ---
$HVITE="HVite";
$HPARSE="HParse";
$hviteConf="-T 1 -b sil"; 

$LOC="Football";
$LEX="lex0Football.txt"; 

# 【修正1】路径修正：指向 donnees/Football/hmms/...
$HMM="donnees/$LOC/hmms/hmm.3/HMMmacro";

# 确保这个文件存在
$PHONES="lists/phonesFootballHTK";

# 目录配置
$PARAMDIR="donnees/$LOC/param/apprentissage";
$LABDIR="donnees/$LOC/lab";

# 确保必要的文件夹存在
unless(-d "tmp"){ mkdir "tmp", 0755; }
unless(-d $LABDIR){ system("mkdir -p $LABDIR"); }

# --- 自动生成临时字典 ---
$DICT="tmp/dictPhoneme";
open(P, $PHONES) || die "无法打开 $PHONES: $!";
open(D, ">$DICT") || die "无法写入 $DICT: $!";
while(<P>) {
    chomp;
    next if /^\s*$/;
    print D "$_ $_\n"; 
}
close(P);
close(D);
print "✅ 已生成临时字典: $DICT\n";

# 开始对齐
&Segmentation("lists/$LEX", "$PARAMDIR", "$LABDIR", "$HMM");

#-------------------------------------------------------------------------
# Segmentation: 强制对齐 (Forced Alignment)
#-------------------------------------------------------------------------
sub Segmentation {
    local($fileList, $paramDir, $labDir, $hmm)=@_;
    
    print "=== 开始强制对齐 (Forced Alignment) ===\n";
    print "使用模型: $hmm\n";
    
    open(FILELIST, $fileList) || die "无法打开 $fileList: $!";
    
    my $count = 0;
    while(<FILELIST>) {
        chomp;
        next if /^\s*$/;
        
        # 解析每一行: T1 sil rr o# ...
        my @liste = split(/\s+/, $_);
        my $filename = shift @liste; 
        
        # 构建网络
        open(FILENET, ">tmp/net.txt");
        print FILENET "([sil] ";
        foreach $phone (@liste) {
            print FILENET "$phone ";
        }
        print FILENET "[sil])";
        close(FILENET);
        
        system("$HPARSE tmp/net.txt tmp/net.net");
        
        my $mfcFile = "$paramDir/$filename.mfc";
        
        if (! -e $mfcFile) {
            print "\n⚠️ 警告: 找不到 $mfcFile，跳过。\n";
            next;
        }

        # 【修正2】关键！在 $DICT 后面加上了 $PHONES
        # 现在的顺序是: HVite [参数] 字典 模型列表 音频
        system("$HVITE $hviteConf -a -H $hmm -m -t 250.0 -i $labDir/$filename.lab -w tmp/net.net -y lab $DICT $PHONES $mfcFile > /dev/null");
        
        $count++;
        if ($count % 10 == 0) { print "已处理 $count 个文件...\r"; }
    }
    close(FILELIST);
    print "\n✅ 对齐完成！已更新 $LABDIR 下的 .lab 文件。\n";
}