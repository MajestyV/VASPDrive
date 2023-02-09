#!/bin/bash
#SBATCH -J vasp
#SBATCH -N 1
#SBATCH -n 32
#SBATCH -p kshcexclu15

NP=32

module purge
module load compiler/intel/2017.5.239
module load mpi/hpcx/2.7.4/intel-2017.5.239

##############################################################################################################

label=TDM  # 本次VASP计算的标签（名称）

##############################################################################################################
# 此部分代码用于定义VASP计算的运行目录等关键路径，通过更改此部分代码，可以轻松管理不同的计算任务

main_directory=~/MoS2_pawpbe_vasp5_D3BJ  # 整个project的总目录，所有的脚本目录以及运算目录都在此路径下
target_system=1  # 目标系统的名称，同时也是VASP运行（算）的目录名
result_dirname=TDM_monolayer_SOC  # 计算结果的存放目录名，此目录为运算目录的子目录
script_dirname=scripts  # 存放计算脚本的目录，通常就用scripts，不必更改

working_directory=${main_directory}/${target_system}  # VASP运行的目标目录的地址
saving_directory=${working_directory}/${result_dirname}  #计算结果储存地址
mkdir ${saving_directory}  # 创建计算结果储存文件夹
script_directory=${main_directory}/${script_dirname}/${target_system}  #此脚本用到的辅助脚本所在地址

##############################################################################################################

vasp=/public/home/nsccsz_user99/vasp_1/vasp.5.4.4_hpcx.2.7.4/bin/vasp_ncl  # 在本次计算中使用的vasp版本

input_preparation=TDM.slurm  # 生成VASP计算所需的输入文件的脚本

# K_path=K-path_bulk  #计算Dispersion relation用的k点路径文件名

rest_time=120s   #计算开始前用于运行输入文件生成脚本的睡眠时间

cd ${working_directory}  #进入V.A.S.P.输入文件所在的文件夹
rm WAVECAR

###################################################
#                                                 #
#            Starting VASP calculation            #
#                                                 #
###################################################
echo 'Calculation started' > ${script_directory}/out  # 标示计算开始

sbatch ${script_directory}/${input_preparation} >> ${script_directory}/out  # 运行Relaxation脚本导入晶格优化的输入文件
# cp ${working_directory}/${K_path} ${working_directory}/KPOINTS  # 用k点路径替代积分用k点网络
sleep ${rest_time}

# 运行V.A.S.P.
echo -n "start time  " > time  #计时以实现按顺序执行命令
date >> time

srun --mpi=pmix_v3 ${vasp} &> output

echo -n "end   time  " >> time ; date >> time
cat time >> ${script_directory}/out

# 保存基本运算结果
cp POTCAR ${saving_directory}/POTCAR  # 保存赝势文件以记录计算方法
cp POSCAR ${saving_directory}/original_structure
cp INCAR ${saving_directory}/INCAR_${label}
cp KPOINTS ${saving_directory}/KPOINTS_${label}
cp CONTCAR ${saving_directory}/relaxed_structure
cp OUTCAR ${saving_directory}/OUTCAR_${label}
cp output ${saving_directory}/output_${label}  # 保存VASP运行的日志文件
# 保存计算所得的电子结构
tar -czvf charge_${label}.tgz CHG*
mv charge_${label}.tgz ${saving_directory}/charge_${label}.tgz
tar -czvf wavefunction_${label}.tgz WAVECAR
mv wavefunction_${label}.tgz ${saving_directory}/wavefunction_${label}.tgz
# cp DOSCAR ${saving_directory}/DOSCAR_${label}  # 态密度
cp EIGENVAL ${saving_directory}/EIGENVAL_${label}  # 能带结构
# cp PROCAR ${saving_directory}/PROCAR_${label}  # 用于可视化每个原子对特定能带的贡献

echo 'Calculation completed!' >> ${script_directory}/out
