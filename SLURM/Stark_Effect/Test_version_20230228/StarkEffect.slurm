#!/bin/bash
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -p kshcexclu15

NP=2

##############################################################################################################

# This script is designed for the calculation of Stark effect and giant Stark effect (GSE).

##############################################################################################################
# 此部分代码用于定义VASP计算的运行目录等关键路径，通过更改此部分代码，可以轻松管理不同的计算任务
main_dirname=GSE_pawpbe_MoS2  # 整个project的总目录名称，所有的脚本目录以及运算目录都应存放在此目录下
target_system=Test_SYM  # 目标系统的名称，同时也是VASP运行（算）的目录名
initial_input=Test_initial  # 对于Stark effect运算，我们需要不断地迭代计算波函数以及电荷密度对于电场的响应，因此需要统一原子结构，赝势等输入文件，这个变量指定了放置这些文件的目录名
script_dirname=scripts  # 存放计算脚本的目录，通常就用scripts，不必更改

# 从部分代码用于指定计算中用到的脚本的文件名
execute_script=Static_calculations.slurm  # 计算Stark effect时，循环迭代执行的脚本
# 不同阶段的计算准备脚本
SCF=SCF.slurm  # 静态自洽场
DOS=DOS.slurm  # 态密度
Ebands=Ebands.slurm  # 能带计算
##############################################################################################################
# 定义各种工作目录的地址
working_directory=~/${main_dirname}/${target_system}  # VASP运行的目标目录的地址
initial_directory=~/${main_dirname}/${initial_input}  # 存放初始输入文件的目录
script_directory=~/${main_dirname}/${script_dirname}/${target_system}  #此脚本用到的辅助脚本所在地址

# 清洗之前的计算结果（Purge old results），如果需要保留之前的计算结果，请把下列两行代码注释掉
rm -rf ${working_directory}
mkdir ${working_directory}
##############################################################################################################
cd ${script_directory}  # 进入脚本目录，即本脚本的运行目录

for i in 0.025 0.050 0.075 0.100 0.125 0.150 0.175 0.200 0.225 0.250 0.275 0.300 0.325 0.350 0.375 0.400 0.425 0.450 0.475 0.500 0.525 0.550
do 

sub_working_directory=${working_directory}/E_${i}    # 计算不同电场强度下系统性能的子目录地址，不同的电场的计算结果会储存在对应的目录当中
sub_script_directory=${script_directory}/E_${i}      # 执行不同电场强度计算的脚本子目录地址

cp -r ${initial_directory} ${sub_working_directory}  # 准备好计算所需的输入文件
mkdir ${sub_script_directory}                        # 创建脚本子目录，用于保存计算所用脚本

# 要计算不同电场下的系统演化，我们需要更改我们的计算脚本，为了方便以及防止出错，在此我们先定义好更改后的计算脚本文件名
execute_script_new=${execute_script}_${i}
SCF_new=${SCF}_${i}
DOS_new=${DOS}_${i}
Ebands_new=${Ebands}_${i}

# 单引号内嵌套单引号即可使用变量
# 把多个文件里的  http://forum.mimvp.com  替换为  //forum.mimvp.com ，需要用到转义符 \
# sed 's/2_GSE_test\/origin/'${workingdir_name}'\/'${i}'/g' Static_runs.slurm > Static_runs_${i}.slurm
# 替换计算流程脚本中的内容
sed 's/Example_homedir/'${main_dirname}'/g' ${execute_script} > ${execute_script}_${i}
sed -i 's/Example_workingdir/'${target_system}'/g' ${execute_script}_${i}
sed -i 's/Example_targetsys/E_'${i}'/g' ${execute_script}_${i}
# 替换计算输入文件准备脚本中的内容
sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${SCF} > ${SCF}_${i}
sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${DOS} > ${DOS}_${i}
sed 's/EFIELD = XXX/EFIELD = '${i}'/g' ${Ebands} > ${Ebands}_${i}

# 除了第一个电场，后面每个电场都读入上一个电场计算得到的WAVECAR跟CHGCAR还有CHG
if test "${i}" = "0.025"
then
    sleep 1s
else
    mv ${working_directory}/WAVECAR ${sub_working_directory}/WAVECAR
    mv ${working_directory}/CHGCAR ${sub_working_directory}/CHGCAR
    mv ${working_directory}/CHG ${sub_working_directory}/CHG
    sed -i 's/ISTART = 0/ISATRT = 1/g' ${SCF}_${i}
    sed -i 's/ICHARG = 2/ICHARG = 1/g' ${SCF}_${i}
fi

mv ${execute_script}_${i} ${sub_script_directory}/${execute_script}
mv ${SCF}_${i} ${sub_script_directory}/${SCF}
mv ${DOS}_${i} ${sub_script_directory}/${DOS}
mv ${Ebands}_${i} ${sub_script_directory}/${Ebands}

# 赋予更改后的脚本执行权力
for file in ${execute_script} ${SCF} ${DOS} ${Ebands}
do
chmod 777 ${sub_script_directory}/${file}
done

sbatch ${sub_script_directory}/${execute_script}

if test "${i}" = "0.025"
then
    sleep 5000s
else
    sleep 3600s
fi

cp ${sub_working_directory}/WAVECAR ${working_directory}/WAVECAR
cp ${sub_working_directory}/CHGCAR ${working_directory}/CHGCAR
cp ${sub_working_directory}/CHG ${working_directory}/CHG

done

