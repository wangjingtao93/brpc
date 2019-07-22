## 编译 跑example步骤

**一个贼有意思的问题**如果make完了之后，在make install,他给的例子就会编译不过去，如果只make不install,则会正常


[brpc搭建、编译和使用](https://blog.csdn.net/u012414189/article/details/84111338)
需要三个开源库：是gflags, protobuf和levedb。
gflags是用于像Linux命令行那样指定参数的，
protobuf用于序列和反序列化以及他的rpc定义。
leveldb用来压缩的。

安装gflag见博客：google gflags 库完全使用
安装protobuf见博客：Protobuf安装步骤
安装leveldb见博客：Linux上搭建百度brpc框架

### 1. 安装步骤

**安装环境**：
   ```
   系统是centos7
   gcc版本是4.8.5，必须支持c++11
   gflag是2.1.1
   cmake是2.8.10
   protobuf是3.6.1
   ```
1. 安装依赖包。
  这里使用yum直接安装，所以系统没有yum，需要西安下载并安装，步骤如下
   -	#CentOS需要安装Epel，否则默认情况下许多软件包不可用。使用如下命令行：
sudo yum install epel-release

   -	通用的设备（deps）,使用如下命令行
sudo yum install git gcc-c++ make openssl-devel


   - 	安装gflags, protobuf, lebeldb:
  sudo yum install gflags-devel protobuf-devel protobuf-compiler leveldb-devel
   - 	如果须在在跑实列时启用CPU/堆分析器，安装如下：
sudo yum install gperftools-devel
   - 	如果需要运行测试，安装并且编译gtest-devel(尚未编译)：
sudo yum install gtest-devel

2. 下载brpc源代码编译安装
   -	 git clone https://github.com/brpc/brpc.git
   -	 cd ./brpc/
   -	 sh config_brpc.sh --headers=/usr/include --libs=/usr/lib64 --nodebugsymbols
   -	 make

3. 运行案例。
     百度给了很多案例，在git上，可以直接使用。这里使用最简单的读写列子。需注意的是，这里提供了两种编译方式，一种是编译成静态库，一种是编译成动态库。百度提供了静态库的makefile,直接make即可，动态库需要加上动态链接标志。

**静态链接**：
```
cd example/echo_c++
make
./echo_server &
./echo_client
```
**动态链接**：
```
cd example/echo_c++
LINK_SO=1 make
./echo_server &
./echo_client
```

**cmake**

除此之外，百度还提供了cmake的编译方式，给的案例中包含了cmakelist,我们只需要下载cmake工具，然后让他自己加载源文件，同时产生makefile,最后再编译成静态或者动态链接即可。

关于cmake工具的介绍与理解，可以看：[CMake简介](https://blog.csdn.net/u012414189/article/details/84111450)
```
cd example/echo_c++
mkdir bld && cd bld && cmake .. && make
./echo_server &
./echo_client
```
4. 结果
 ![运行结果](./images/运行结果.png)

5.	Brpc介绍
又称baidu-rpc,是百度开发的一款“远过程调用”网络框架，目前该项目已在github上开源。
从应用方面来看，brpc目前被应用与百度公司的各种核心业务，包括：高性能计算和模型迅雷和各种索引和排序服务，目前有超过100万以上个实例是基于brpc工作的。
主要关注他的设计思想、性能、易用性和主流开源的rpc的对比上。

## RPC
  rpc全程是Remote Procedure Call,即远过程调用。远过程调用的解释如下：
有a 和 b两个函数，b调用了a,即“过程调用”。若a b再同一台机器同一个进程和同一个线程被执行，就叫本地过程调用---local procedure call。

当a、b在同一台机器的不同进程种执行，这也是本地过程调用。当a需要执行的业务越来越负责，我们可能会让它独立成为一个进程而存在，这时候b想要调用a的函数，就需要使用管道等技术进行跨进程通信。
再进一步，a和b根本不再同一台机器上，此时b 调用a函数需要跨网络，这种调用就成为远过程调用。

b如和远过程调用a函数呢？一般a函数对应的进程会开放一个网络端口，它接受某种协议（比如HTTP）的请求，然后把结果打包成对应的协议戈斯和返回。b函数所在的进程则发起该请求，然后接收返回结果。

为了简化程序员的工作，就开发了rpc框架，brpc就是百度开发的。

可以使用它：
-	搭建能在一个端口支持多协议的服务, 或访问各种服务
-restful http/https, h2/gRPC。使用brpc的http实现比libcurl方便多了。从其他语言通过HTTP/h2+json访问基于protobuf的协议.
-	redis和memcached, 线程安全，比官方client更方便。
- rtmp/flv/hls, 可用于搭建流媒体服务.
- hadoop_rpc(可能开源)
- 支持rdma(即将开源)
- 支持thrift , 线程安全，比官方client更方便
- 各种百度内使用的协议: baidu_std, streaming_rpc, hulu_pbrpc, sofa_pbrpc, nova_pbrpc, public_pbrpc, ubrpc和使用nshead的各种协议.
- 基于工业级的RAFT算法实现搭建高可用分布式系统，已在braft开源。
- Server能同步或异步处理请求。
- Client支持同步、异步、半同步，或使用组合channels简化复杂的分库或并发访问。
- 通过http界面调试服务, 使用cpu, heap, contention profilers.
-	获得更好的延时和吞吐.
- 把你组织中使用的协议快速地加入brpc，或定制各类组件, 包括命名服务 (dns, zk, etcd), 负载均衡 (rr, random, consistent hashing)


## gflags
gflags是google开源的用于处理命令行参数的项目。
安装之前需要先安装cmake工具，[CMake简介](https://blog.csdn.net/u012414189/article/details/84111450)

安装好之后，可以进行基础使用[google gflags 库完全使用](https://blog.csdn.net/u012414189/article/details/84256667)

比如：我们有个程序需要知道服务器的ip和端口。程序中有默认指定参数，同时希望可以通过命令行来指定不同的值
```C++
#include <iostream>
#include <gflags/gflags.h>
/**
 *  定义命令行参数变量
 *  默认的主机地址为 127.0.0.1，变量解释为 'the server host'
 *  默认的端口为 12306，变量解释为 'the server port'
 */
DEFINE_string(host, "127.0.0.1", "the server host");
DEFINE_int32(port, 12306, "the server port");

int main(int argc, char** argv) {
    // 解析命令行参数，一般都放在 main 函数中开始位置
    gflags::ParseCommandLineFlags(&argc, &argv, true);
    // 访问参数变量，加上 FLAGS_
    std::cout << "The server host is: " << FLAGS_host
        << ", the server port is: " << FLAGS_port << std::endl;
    return 0;
}
```
然后编译运行
##	Cmake
1. cmake与make的区别

   **写程序的大体步骤为**:
     - 用编辑器编写源代码，如.cpp文件。
     - 用编译器商城目标文件，如.o
     - 用链接器生成可执行目标代码生成可执行文件，如.exe

  但是如果源文件太多，一个一个编译时就会特别麻烦，于是诞生make工具来批量处理编译源文件。可以用一条命令实现完全编译。但是你需要编写一个规则文件，make依据它来批量处理编译，这个文件就是makefile,所以编写makefile文件也是程序员必备的技能。

  但是工程较大时，编写makefile实在时复杂，所以出现了cmake工具，自动生成makefile。cmake能够输出各种各样的makefile或者project文件。但随之而来的就是编写cmakelist文件，他是cmake所依据的规则。
 ![make](./images/编译过程.png)
2. Centos7使用cmake
  [CMake简介](https://blog.csdn.net/u012414189/article/details/84111450)
