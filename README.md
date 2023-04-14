# VASPDrive, or vDrive for short, is a shell script toolkit for boosting *ab initio* calculation via the Vienna Ab initio Simulation Package (VASP).

## I. Introduction

## X. 疑难杂症解决办法

### 1. 不同的操作系统上换行符差异导致脚本报错

这个报错很可能是因为git导致的，在通过git上传代码时，如不设置，git会自动将LF换行符改成CRLF：

```
$ git add .
warning: in the working copy of 'XXX/XXX/XXX/XXX.XXX', LF will be replaced by CRLF the next time Git touches it
```

此时可以通过一下命令更改git的配置：

```
$ git config --global core.autocrlf true  # 提交时转换为LF，检出时转换为CRLF
$ git config --global core.autocrlf input  # 提交时转换为LF，检出时不转换
$ git config --global core.autocrlf false  # 提交检出均不转换
```

一些已经被更改的文件可以利用dos2unix或者unix2dos工具进行换行符的转换。更多问题可以参考：

[Git中CRLF与LF的转换](https://blog.csdn.net/u011069294/article/details/103809307)

[用懷念的 UNIX2DOS 與 DOS2UNIX 批次轉換檔案 (跨平台)](https://blog.miniasp.com/post/2010/08/20/UNIX2DOS-DOS2UNIX-Windows-Linux-Convertion)

[从windows到linux的换行转换工具dos2unix](https://blog.csdn.net/weixin_38233274/article/details/92962095)



## External links

