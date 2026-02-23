#!/usr/local/bin/perl

$HVITE="HVite";
$hviteConf="-T 1";
$LOC="Football";

# --- 核心文件配置 ---
$DIC="lists/keywordsplus.dic";
$NET2="lists/keywordsplus.net2"; 
$TEST="lists/lex1Football.txt";
$PHONES="lists/phonesFootballHTK";
$HMM="donnees/$LOC/hmms/hmm.3/HMMmacro";

# 结果保存目录 (已修改为 param/test)
$OUTDIR="donnees/$LOC/param/test";
unless(-d $OUTDIR){ mkdir $OUTDIR, 0755; }

print "=== 正在运行检测 (Step 2.3) ===\n";
print "使用网络: $NET2\n";
print "输出目录: $OUTDIR\n";
print "--------------------------------------------------\n";

open(FILELIST, $TEST) || die "无法打开 $TEST";
while(<FILELIST>) {
    chomp;
    s/\r//g; 
    next if /^\s*$/;
    
    # 1. 获取文件名 (如 Test)
    my @tokens = split(/\s+/, $_);
    $name = $tokens[0];
    
    # 2. 构造 .mfc 文件路径
    $mfcFile = "donnees/$LOC/param/test/$name.mfc";
    
    # 3. 检查文件是否存在，存在才跑
    if (-e $mfcFile) {
        # 直接运行 HVite，结果写入 $OUTDIR
        system("$HVITE $hviteConf -H $HMM -w $NET2 -l $OUTDIR $DIC $PHONES $mfcFile");
    } else {
        print "⚠️ 错误: 找不到文件 -> $mfcFile\n";
    }
}
close(FILELIST);

print "\n--------------------------------------------------\n";
print "✅ 完成。结果已保存在 $OUTDIR，可以进行评测了。\n";