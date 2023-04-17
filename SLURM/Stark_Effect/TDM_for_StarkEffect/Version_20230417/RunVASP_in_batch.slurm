#!/bin/bash
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -p kshcexclu15

NP=2

##############################################################################################################

# This script is designed for the calculation of Stark effect and giant Stark effect (GSE).

##############################################################################################################
task_name=TDM_StarkEffect  # 本次计算总任务的名称
##############################################################################################################
# 此部分代码用于定义VASP计算的运行目录等关键路径，通过更改此部分代码，可以轻松管理不同的计算任务
main_dirname=GSE_pawpbe_MoS2  # 整个project的总目录名称，所有的脚本目录以及运算目录都应存放在此目录下
target_system=Test  # 目标系统的名称，同时也是VASP运行（算）的目录名
script_dirname=scripts  # 存放计算脚本的目录，通常就用scripts，不必更改

# 从部分代码用于指定计算中用到的脚本的文件名
execute_script=RunVASP_TDM_StarkEffect.slurm  # 指定要批量执行的脚本

rest_time=1800s  # 子任务之间的间隔时间
##############################################################################################################
# 定义各种工作目录的地址
working_directory=~/${main_dirname}/${target_system}  # VASP运行的目标目录的地址
script_directory=~/${main_dirname}/${script_dirname}/${target_system}  # 此脚本用到的辅助脚本所在地址

script_repository=${script_directory}/${task_name}  # 存放计算任务中所有生成的脚本的仓库文件夹
mkdir ${script_repository}
##############################################################################################################

for i in 0.025 0.050 0.075 0.100 0.125 0.150 0.175 0.200 0.225 0.250 0.275 0.300 0.325 0.350 0.375 0.400 0.425 0.450 0.475 0.500 0.525 0.550
do

subtask_dirname=E_${i}  # 要批量计算的任务中，每个子任务执行的具体文件夹

# subtask_working_directory=${working_directory}/${subtask_dirname}    # 计算不同电场强度下系统性能的子目录地址，不同的电场的计算结果会储存在对应的目录当中

cd ${script_directory}  # 进入脚本目录

# 单引号内嵌套单引号即可使用变量
# 把多个文件里的  http://forum.mimvp.com  替换为  //forum.mimvp.com ，需要用到转义符 \
# sed 's/2_GSE_test\/origin/'${workingdir_name}'\/'${i}'/g' Static_runs.slurm > Static_runs_${i}.slurm
# 替换计算流程脚本中的内容
sed 's/Example_maindir/'${main_dirname}'/g' ${execute_script} > ${execute_script}_${i}
sed -i 's/Example_targetsys/'${target_system}'/g' ${execute_script}_${i}
sed -i 's/Example_subtask/'${subtask_dirname}'/g' ${execute_script}_${i}
# 替换计算输入文件准备脚本中的内容
#sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${SCF} > ${SCF}_${i}
#sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${DOS} > ${DOS}_${i}
#sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${Ebands} > ${Ebands}_${i}

mv ${execute_script}_${i} ${script_repository}/${execute_script}
#mv ${SCF}_${i} ${sub_script_directory}/${SCF}

# 赋予更改后的脚本执行权力
cd ${script_repository}
chmod 777 ${execute_script}
sbatch ${execute_script}

sleep ${rest_time}

done

