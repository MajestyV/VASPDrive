#!/bin/bash
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -p kshcexclu15

NP=2

# Written by Songwei Liu at 2023.04.14

target_dir=~/GSE_pawpbe_MoS2/Test_PEAD  # 要收集的数据所在的主目录
result_dirname=result  # 存放计算结果的文件夹名称
saving_dir=~/GSE_pawpbe_MoS2/Test_PEAD  # 存放收集好的数据的目录
data_label=GSE_Bilayer  # 收集好的数据存放的文件夹名称

rm -r ${saving_dir}/${data_label}  # 清理之前的结果
mkdir ${saving_dir}/${data_label}  # 重新创建存放收集数据用的文件夹

# 历遍所有指定的电场强度
for Efield in 0.025 0.050 0.075 0.100 0.125 0.150 0.175 0.200 0.225 0.250 0.275 0.300 0.325 0.350 0.375 0.400 0.425 0.450 0.475 0.500 0.525 0.550
do

sub_target_dirname=E_${Efield}  # 计算不同电场强度的具体工作文件夹名称

cp -r ${target_dir}/${sub_target_dirname}/${result_dirname} ${saving_dir}/${data_label}/${sub_target_dirname}  # 复制数据文件夹到指定的存放目录

done

# zip [选项] 指定压缩包生成目录/压缩包名 源文件或源目录列表
zip -q -r ${saving_dir}/${data_label}.zip ${saving_dir}/${data_label}  # 采用zip压缩收集好的数据文件夹方便下载和在windows上解压
# tar -zcvf ${saving_dir}/${data_label}.tar.gz ${saving_dir}/${data_label}  # 采用tar压缩收集好的数据文件夹方便下载，同时压缩效果较好，但是不方便在windows系统上解压数据
