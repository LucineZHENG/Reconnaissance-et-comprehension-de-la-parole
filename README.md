# 语音识别与关键词检测  
## Reconnaissance et compréhension de la parole

本项目基于 **隐马尔可夫模型（HMM, Hidden Markov Model）** 实现一个简单的 **语音关键词检测系统（Keyword Spotting, KWS）**，用于从连续语音中检测特定关键词。

项目语料来自 **足球主题的法语语音数据**，系统目标是在连续语音流中识别预定义关键词，同时忽略无关语音信息。  

该项目为 **Master 2 – Sciences du Langage / Langue et Informatique** 课程项目。

---

# 项目目标

- 构建基于 **HMM 的语音识别模型**
- 实现 **关键词检测系统（Keyword Spotting）**
- 训练和测试语音模型
- 构建 **解码网络（Decoding Network）**
- 分析识别结果与系统性能

关键词检测适用于以下场景：

- 语音助手唤醒词检测  
- 媒体转录中的关键词定位  
- 会议记录自动检索  
- 语音信息检索系统  

---

# 项目结构

```
Reconnaissance-et-comprehension-de-la-parole
│
├── Football/                # 语音数据、特征参数、HMM模型等
├── configs/                 # 配置文件
├── lists/                   # 字典、音素列表、网络结构等
├── tmp/                     # 临时文件
├── generateNet2.pl          # 生成关键词检测网络
├── runAlign.pl              # 强制对齐（Forced Alignment）
├── runApprentissage.pl      # 模型训练脚本
├── runParamApp.pl           # 训练数据参数提取
├── runParamTest.pl          # 测试数据参数提取
├── runDetections1.pl        # 关键词检测实验 1
├── runDetections2.pl        # 关键词检测实验 2
├── runDetections3.pl        # 关键词检测实验 3
├── transcription.txt        # 语音转录文本
└── rapport.pdf              # 项目报告
```

---

# 数据与关键词

项目中的关键词包括 **10 个词**，分为两类：

## 1. 语料中频繁出现的词

- france
- match
- concert
- monde
- bresil

## 2. 足球主题词

- zidane
- ballon
- but
- supporters
- ronaldo

系统采用 **Keywords + Filler Model** 的解码网络结构，使系统可以区分：

- 关键词
- 非关键词语音
- 静音段

---

# 方法

## 1 语料处理

音频数据被分为：

- **训练集**：每段音频前 2 分钟  
- **测试集**：音频最后 1 分钟  

训练数据被分割为多个 **语音轮次（Tours）** 并进行音素标注。

---

## 2 声学模型

本项目使用：

**Hidden Markov Models (HMM)**

主要步骤：

1. 提取 **MFCC 特征**
2. 训练 **单音素 HMM**
3. 进行 **强制对齐（Forced Alignment）**
4. 更新模型参数

---

## 3 解码网络

解码网络结构：

```
sil -> keyword -> sil
       |
     filler
```

其中：

- **Keyword models**：目标关键词  
- **Filler model / World model**：非关键词语音  
- **sil**：静音  

识别过程使用 **Viterbi 算法**。

---

# 运行步骤

## 1 训练模型

```bash
perl runParamApp.pl
perl runApprentissage.pl
```

## 2 构建解码网络

```bash
HParse configs/grammairePhoneme.txt configs/networkPhoneme
```

## 3 生成测试特征

```bash
perl runParamTest.pl
```

## 4 语音识别

```bash
HVite -T 1 \
-H donnees/Football/hmms/hmm.3/HMMmacro \
-w configs/networkPhoneme \
-l donnees/Football/resultats \
lists/dictPhoneme \
lists/phonesFootballHTK \
donnees/Football/param/test/*.mfc
```

## 5 结果评估

```bash
HResults -p \
-L donnees/Football/param/test/DAP \
lists/phonesFootballHTK \
donnees/Football/resultats/*.rec
```

---

# 关键词检测实验

关键词检测通过以下脚本运行：

```bash
perl runDetections1.pl
perl runDetections2.pl
perl runDetections3.pl
```

并使用：

```
HResults
```

评估识别性能。

---

# 实验结果

实验主要关注以下指标：

- **Hits**：正确检测数  
- **False Alarms (FAs)**：误检数  
- **Accuracy**  
- **Figure of Merit (FOM)**  

实验结果显示：

- 系统能够检测部分关键词  
- 但 **误报率较高**  
- 因此 **FOM 仍然接近 0**

主要原因：

- 测试语音较短  
- 假警报过多  
- 解码网络权重仍需优化  

---

# 技术栈

- **HTK (Hidden Markov Model Toolkit)**
- **Perl**
- **Python**（用于部分语料处理）
- **Praat**（语音标注）

---

# 改进方向

未来可以从以下方面优化：

- 使用更大的训练语料  
- 改进音素词典  
- 优化关键词网络结构  
- 调整 **reward / penalty 参数**  
- 引入深度学习模型  
  - DNN-HMM  
  - End-to-End ASR  

---

# 作者

**ZHENG RUIXING**

Master 2  
Sciences du Langage – Langue et Informatique
