#!/usr/local/bin/perl

$HCOPY="HCopy";
$hcopyConf="configs/hcopyWAV";
$LOC="Football";
$LEX="lex1Football.txt";

# 调用处理函数
&HCopy("lists/$LEX", "donnees/$LOC/", "wav/test", "param/test");

   
#-------------------------------------------------------------------------
# HCopy: 提取 MFCC 特征
#-------------------------------------------------------------------------
sub HCopy {
    local($fileList, $refDir, $signal, $param)=@_;
   
    # 打印调试信息
    print "=== 开始提取特征 ===\n";
    print "列表文件: $fileList\n";
    print "WAV 目录: $refDir$signal\n";
    print "输出目录: $refDir$param\n";

    open(FILELIST, $fileList) || die "无法打开列表文件 $fileList: $!";
    open(FILEPARAM, ">$refDir$param/files.txt") || die "无法创建输出列表: $!";
    
    while(<FILELIST>) {  
        chomp($_);          # 去除末尾换行符
        s/\r//g;            # 【关键】去除 Windows 回车符
        next if /^\s*$/;    # 跳过空行

        @liste = split(/\s+/,$_); # 按空格分割
        $name = $liste[0];
        
        # 拼接完整路径
        $wavFile = "$refDir$signal/$name.wav";
        $mfcFile = "$refDir$param/$name.mfc";
        
        # 打印正在处理的文件，方便排查
        print "Processing: $wavFile -> $mfcFile\n";

        # 检查源文件是否存在
        if (! -e $wavFile) {
            print "❌ 错误: 找不到 WAV 文件: $wavFile\n";
            next;
        }

        # 【关键修正】去掉了 -D 参数
        $ret = system("$HCOPY -C $hcopyConf $wavFile $mfcFile");
        
        if ($ret == 0) {
            print FILEPARAM ("$mfcFile\n");
        } else {
            print "❌ HCopy 执行失败\n";
        }
    }
    close(FILELIST);
    close(FILEPARAM);
    print "=== 完成 ===\n";
}
