#!/usr/local/bin/perl

# --- 1. 配置部分 ---
$HINIT="HInit";
$hinitConf="-T 1 -i 10 -H configs/HMMmacro";

$LOC="Football";
$LEX="lex0Football.txt";
$PHO="phonesFootballHTK";

# 定义音频参数所在的文件夹 (根据你的目录结构)
# 这一步至关重要，告诉系统 .mfc 到底在哪
$paramDir="donnees/$LOC/param/apprentissage";

# 确保 tmp 文件夹存在，用来放生成的路径列表
unless(-d "tmp"){ mkdir "tmp", 0755; }

# --- 2. 自动生成路径列表 (SCP文件) ---
# 我们不手动写，让脚本自动读取 lex0Football.txt 里的 T1, T2... 
# 然后把它们变成完整的路径: donnees/Football/param/apprentissage/T1.mfc
$scriptFile="tmp/train.scp";
print "正在生成路径列表文件: $scriptFile ...\n";

open(SRC, "lists/$LEX") || die "无法打开 lists/$LEX: $!";
open(DST, ">$scriptFile") || die "无法写入 $scriptFile: $!";

while(<SRC>) {
    chomp;
    next if /^\s*$/; # 跳过空行
    
    # 提取每行的第一个单词 (也就是文件名 T1, T2...)
    # 比如从 "T1 sil rr..." 提取出 "T1"
    my ($id) = split(/\s+/, $_);
    
    # 拼接完整路径并写入 scp 文件
    if ($id ne "") {
        print DST "$paramDir/$id.mfc\n";
    }
}
close(SRC);
close(DST);
print "✅ 路径列表生成完毕！\n";


# --- 3. 训练流程 (注意：现在所有 -S 参数都指向生成的 $scriptFile) ---

# HInit
print "\n=== 阶段 1: HInit (模型初始化) ===\n";
&HInit("lists/$PHO", "donnees/$LOC", $scriptFile, "hmms/hmm.0");

$HREST="HRest";
$hrestConf="-T 1 -i 10 -H configs/HMMmacro";
# HRest
print "\n=== 阶段 2: HRest (孤立词训练) ===\n";
&HRest("lists/$PHO", "donnees/$LOC", $scriptFile, "hmms/hmm.0", "hmms/hmm.1");

$HEREST="HERest";
$herestConf="-T 1 -H configs/HMMmacro";
# HERest
print "\n=== 阶段 3: HERest (嵌入式训练) ===\n";
&HERest("lists/$PHO", "donnees/$LOC", $scriptFile, "hmms/hmm.1", "hmms/hmm.2");

$HHED="HHEd";
$hhedConf="configs/divg.hed";
# HHEd (不需要 scp 文件)
print "\n=== 阶段 4: HHEd (模型混合/分裂) ===\n";
&HHEd("lists/$PHO", "donnees/$LOC", "hmms/hmm.2", "hmms/hmm.3");

# HERest
print "\n=== 阶段 5: HERest (最终训练) ===\n";
&HERest("lists/$PHO", "donnees/$LOC", $scriptFile, "hmms/hmm.3", "hmms/hmm.3");


# --- 子程序定义 ---

sub HInit {
    local($hmmList, $refDir, $scpFile, $destHMM)=@_;
    
    open(HMMLIST, $hmmList) or die "Cannot open $hmmList: $!\n";
    while(<HMMLIST>) {  
        chomp($_);
        next if /^\s*$/;
        
        # 使用 -S $scpFile 指向刚才生成的完整路径列表
        # -l $_ 表示我们要去 lab 文件里找哪个音素 (例如 -l rr)
        system("$HINIT $hinitConf -L $refDir/lab -l $_ -o $_ -M $refDir/$destHMM -S $scpFile configs/HMMproto");
    }
    close(HMMLIST);
}
    
sub HRest {
    local($hmmList, $refDir, $scpFile, $srcHMM, $destHMM)=@_;
    
    open(HMMLIST, $hmmList) or die "Cannot open $hmmList: $!\n";
    while(<HMMLIST>) {  
        chomp($_);
        next if /^\s*$/;
        
        system("$HREST $hrestConf -L $refDir/lab -l $_ -M $refDir/$destHMM -S $scpFile $refDir/$srcHMM/$_");
    }
    close(HMMLIST);
}
    
sub HERest {
    local($hmmList, $refDir, $scpFile, $srcHMM, $destHMM)=@_;
    $nbIter = 5;
    
    if ($srcHMM ne $destHMM) {
        system("$HEREST $herestConf -L $refDir/lab -M $refDir/$destHMM -S $scpFile -d $refDir/$srcHMM $hmmList");
    }
    for ($i = 0;$i < $nbIter;$i++) {
        system("$HEREST -T 1 -H $refDir/$destHMM/HMMmacro -L $refDir/lab -M $refDir/$destHMM -S $scpFile $hmmList");
    }
}
    
sub HHEd {
    local($hmmList, $refDir, $srcHMM, $destHMM)=@_;
    
    system("$HHED -H $refDir/$srcHMM/HMMmacro -M $refDir/$destHMM $hhedConf $hmmList");
}