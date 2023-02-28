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
# 此脚本专门用于执行VASP的静态计算（系统的结构不改变）
working_directory=~/Example_homedir/Example_workingdir/Example_targetsys  # VASP运行的目标目录的地址
saving_directory=${working_directory}/result  #计算结果储存地址
mkdir ${saving_directory}  # 创建计算结果储存文件夹
script_directory=~/Example_homedir/scripts/Example_workingdir/Example_targetsys  #此脚本用到的辅助脚本所在地址
##############################################################################################################

vasp=/public/home/nsccsz_user99/vasp_1/vasp.5.4.4_hpcx.2.7.4/bin/vasp_std  # 在本次计算中使用的vasp版本
# 自旋耦合及磁性相关计算可以使用非共线版本的vasp：/public/home/nsccsz_user99/vasp_1/vasp.5.4.4_hpcx.2.7.4/bin/vasp_ncl

log=${saving_directory}/calculation_log  # 用于记录计算日志的文件地址

# 不同阶段的计算准备脚本
SCF=SCF.slurm  # 静态自洽场
DOS=DOS.slurm  # 态密度
Ebands=Ebands.slurm  # 能带计算

rest_time=120s   #计算开始前用于运行输入文件生成脚本的睡眠时间

cd ${working_directory}  #进入V.A.S.P.输入文件所在的工作文件夹
# rm WAVECAR  # 移除之前的WAVECAR文件, 排除前面计算留下的影响，如需读取上一步的计算结果则需将注释此行

###################################################
#                                                 #
#     Part I: Self-consistent field (SCF)         #
#                                                 #
###################################################
echo 'Part I started' > ${log}  #标示第一部分计算开始

sbatch ${script_directory}/${SCF} >> ${log}  # 运行SCF脚本导入静态自洽场计算的输入文件
sleep ${rest_time}

# 运行V.A.S.P.进行静态自洽场的计算
echo -n "start time  " >> ${log} ; date >> ${log}  #计时以实现按顺序执行命令

srun --mpi=pmix_v3 ${vasp} &> output  # 使用非线性版本VASP以支持自旋轨道耦合(SOC)

echo -n "end   time  " >> ${log} ; date >> ${log}

E_fermi=`grep 'E-fermi' OUTCAR` 
echo "Fermi energy: " ${E_fermi} > Markdown_SCF

tar -czvf charge.tgz CHG*
mv charge.tgz ${saving_directory}/charge.tgz
cp POSCAR ${saving_directory}/crystal_structure
cp Markdown_SCF ${saving_directory}/Markdown_SCF
cp INCAR ${saving_directory}/INCAR_SCF
cp KPOINTS ${saving_directory}/KPOINTS_SCF
cp OUTCAR ${saving_directory}/OUTCAR_SCF
cp output ${saving_directory}/output_SCF  # 保存SCF的日志文件

###################################################
#                                                 #
#     Part II: Density of states (DOS)            #
#                                                 #
###################################################
echo 'Part II started' >> ${log}  #标示第二部分计算开始

sbatch ${script_directory}/${DOS} >> ${log}  # 运行SCF脚本导入静态自洽场计算的输入文件
sleep ${rest_time}

# 运行V.A.S.P.进行态密度的积分
echo -n "start time  " >> ${log} ; date >> ${log}  #计时以实现按顺序执行命令

srun --mpi=pmix_v3 ${vasp} &> output  # 使用非线性版本VASP以支持自旋轨道耦合(SOC)

echo -n "end   time  " >> ${log} ; date >> ${log}

cp INCAR ${saving_directory}/INCAR_DOS
cp KPOINTS ${saving_directory}/KPOINTS_DOS
cp DOSCAR ${saving_directory}/DOSCAR
cp PROCAR ${saving_directory}/PROCAR_DOS
cp output ${saving_directory}/output_DOS  # 保存DOS计算的日志文件

###################################################
#                                                 #
#   Part III: Electronic dispersion (E-bands)     #
#                                                 #
###################################################
echo 'Part III started' >> ${log}  #标示第三部分计算开始

sbatch ${script_directory}/${Ebands} >> ${log}  # 运行SCF脚本导入静态自洽场计算的输入文件
sleep ${rest_time}

# 运行V.A.S.P.进行能带的计算
echo -n "start time  " >> ${log} ; date >> ${log}  #计时以实现按顺序执行命令

srun --mpi=pmix_v3 ${vasp} &> output  # 使用非线性版本VASP以支持自旋轨道耦合(SOC)

echo -n "end   time  " >> ${log} ; date >> ${log}

cp INCAR ${saving_directory}/INCAR_Ebands
cp KPOINTS ${saving_directory}/KPOINTS_Ebands
cp EIGENVAL ${saving_directory}/EIGENVAL
cp PROCAR ${saving_directory}/PROCAR_Ebands  # 用于可视化每个原子对特定能带的贡献
cp output ${saving_directory}/output_Ebands  # 保存能带计算的日志文件

echo 'Calculation complete!' >> ${log}
