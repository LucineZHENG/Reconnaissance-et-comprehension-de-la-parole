#!/usr/local/bin/perl

$HVITE="HVite";
$HPARSE="HParse";
$hviteConf="-T 1";

$LOC="Football";

# --- 2.2 节的文件配置 ---
$DIC="lists/keywordsplus.dic";        
$NET="lists/keywordsplus.net";      
$TEST="lex1Football.txt";         
$PHONES="lists/phonesFootballHTK";

# HMM 模型路径
$HMM="donnees/$LOC/hmms/hmm.3/HMMmacro";

# 执行函数
&HVite($DIC, $NET, $PHONES, "donnees/$LOC", "lists/$TEST", $HMM);
   

#-------------------------------------------------------------------------
# HVite: 关键词检测 (Step 2.2)
#-------------------------------------------------------------------------
sub HVite {
    local($fileDic, $fileNet, $hmmList, $refDir, $fileList, $hmm)=@_;
    
    # 1. 编译网络 (Text -> Lattice)
    print "=== Compiling Network ===\n";
    print "Source: $fileNet\n";
    unless(-d "tmp"){ mkdir "tmp", 0755; }
    
    # 检查源文件是否存在
    if (! -e $fileNet) {
        die "❌ Error: Cannot find network file: $fileNet\n(Please verify where you saved keywordsplus.net)";
    }

    system("$HPARSE $fileNet tmp/net2");

    # 2. 准备输出目录 (已修改为 param/test)
    $outDir = "$refDir/param/test";
    unless(-d $outDir){ mkdir $outDir, 0755; }

    # 3. 逐个处理文件
    open(FILELIST, $fileList) || die "Cannot open $fileList: $!";
    
    # 检查字典是否存在
    if (! -e $fileDic) {
        die "❌ Error: Cannot find dictionary file: $fileDic\n(Please verify where you saved keywordsplus.dic)";
    }

    print "\n=== Running Detection (Step 2.2) ===\n";
    print "Results will be shown below:\n\n";

    while(<FILELIST>) {
        chomp;
        s/\r//g; 
        next if /^\s*$/;
        
        my @tokens = split(/\s+/, $_);
        $name = $tokens[0];
        
        $mfcFile = "$refDir/param/test/$name.mfc";
        
        if (! -e $mfcFile) {
            print "⚠️ Error: MFC file not found: $mfcFile\n";
            next;
        }

        # 运行 HVite
        system("$HVITE $hviteConf -H $hmm -w tmp/net2 -l $outDir $fileDic $hmmList $mfcFile");
    }
    close(FILELIST);
}

