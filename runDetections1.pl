#!/usr/local/bin/perl

$HVITE="HVite";
$HPARSE="HParse";
$hviteConf="-T 1";

$LOC="Football";

# --- 2.1 节的文件配置 ---
$DIC="keywords.dic";
$NET="keywords.net";
$TEST="lex1Football.txt";
$PHONES="lists/phonesFootballHTK";

# HMM 模型路径
$HMM="donnees/$LOC/hmms/hmm.3/HMMmacro";

&HVite("lists/$DIC", "lists/$NET", $PHONES, "donnees/$LOC", "lists/$TEST", $HMM);
   

#-------------------------------------------------------------------------
# HVite: 关键词检测
#-------------------------------------------------------------------------
sub HVite {
    local($fileDic, $fileNet, $hmmList, $refDir, $fileList, $hmm)=@_;
    
    # 1. 编译网络
    print "=== Compiling Network ===\n";
    unless(-d "tmp"){ mkdir "tmp", 0755; }
    system("$HPARSE $fileNet tmp/net1");

    # 2. 准备输出目录 (已修改为 param/test)
    $outDir = "$refDir/param/test";
    unless(-d $outDir){ mkdir $outDir, 0755; }

    # 3. 逐个处理文件
    open(FILELIST, $fileList) || die "Cannot open $fileList: $!";
    
    print "\n=== Running Detection (Step 2.1) ===\n";
    while(<FILELIST>) {
        chomp;
        s/\r//g; 
        next if /^\s*$/;
        
        # 按空格分割，只取第一个元素作为文件名
        my @tokens = split(/\s+/, $_);
        $name = $tokens[0];
        
        $mfcFile = "$refDir/param/test/$name.mfc";
        
        if (! -e $mfcFile) {
            print "⚠️ Error: MFC file not found: $mfcFile\n";
            next;
        }

        # 运行 HVite
        system("$HVITE $hviteConf -H $hmm -w tmp/net1 -l $outDir $fileDic $hmmList $mfcFile");
    }
    close(FILELIST);
}