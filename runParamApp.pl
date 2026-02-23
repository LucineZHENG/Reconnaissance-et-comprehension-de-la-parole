#!/usr/local/bin/perl

$HCOPY="HCopy";
$hcopyConf="configs/hcopyWAV";
$LOC="Football";
$LEX="lex0Football.txt";

&HCopy("lists/$LEX", "donnees/$LOC/", "wav/apprentissage", "param/apprentissage");

#-------------------------------------------------------------------------
# HCopy: Appel de HCopy pour paramétriser des fichiers audio  
#-------------------------------------------------------------------------
sub HCopy {
   local($fileList, $refDir, $signal, $param)=@_;
   
   # 创建输出目录
   system("mkdir -p $refDir$param");
   
   open(FILELIST, $fileList) or die "Cannot open $fileList: $!\n";
   open(FILEPARAM, ">$refDir$param/files.txt") or die "Cannot create output file: $!\n";
   
   my $success = 0;
   my $failed = 0;
   
   print "\n=== Extracting MFCC Features ===\n";
   print "Input: $fileList\n";
   print "WAV dir: $refDir$signal\n";
   print "Output dir: $refDir$param\n\n";
   
   while(<FILELIST>) {  
      chomp($_);  # 使用 chomp 而不是 chop
      
      # 跳过空行和注释
      next if /^\s*$/;
      next if /^#/;
      
      # 使用 TAB 或多个空格分割，只取第一列（文件名）
      @liste = split(/\t/, $_);
      if ($#liste < 0) {
         @liste = split(/\s+/, $_);
      }
      
      my $filename = $liste[0];
      next if $filename eq "";
      
      my $wavFile = "$refDir$signal/$filename.wav";
      my $mfcFile = "$refDir$param/$filename.mfc";
      
      print "Processing: $filename ... ";
      
      # 检查 WAV 文件是否存在
      if (! -e $wavFile) {
         print "✗ WAV file not found\n";
         $failed++;
         next;
      }
      
      # 运行 HCopy（移除 -D 参数）
      my $ret = system("$HCOPY -C $hcopyConf $wavFile $mfcFile 2>&1");
      
      if ($ret == 0) {
         print "✓\n";
         print FILEPARAM ("$mfcFile\n");
         $success++;
      } else {
         print "✗\n";
         $failed++;
      }
   }
   
   close(FILELIST);
   close(FILEPARAM);
   
   print "\n=== Extraction Complete ===\n";
   print "Successful: $success\n";
   print "Failed: $failed\n";
}
