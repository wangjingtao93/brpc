#brpc知识拓展

##brpc代码阅读时的疑问
1. channel可以被所有线程共享是什么意思，怎么实现的
2. stub是什么，怎么构造
4.

##名词
1. 原子指令（atomic-instructions）
2. 自适应限流（auto_concurrency_limiter）


##涉及的知识点

###堆和栈
C++笔记上有记载，堆程序员释放，new出来了，栈操作系统释放

###bvar
 bvar是多线程环境下的计数器类库，方便记录和查看用户程序中的各类数值。**当想在多线程环境中计数并展现是**，应该想到使用bvar。

 当很多线程都在累加一个计数器时，每个线程只累加私有的变量而不参与全局竞争，在读取时累加所有线程的私有变量。虽然读比之前慢多了，但由于这类计数器的读多为低频的记录和展现，慢点无所谓。而写就快多了，极小的开销使得用户可以无顾虑地使用bvar监控系统，这便是我们设计bvar的目的

###protobuf
 protobuf是google开源的数据序列化和反序列工具，见[protobuf](https://blog.csdn.net/u012414189/article/details/84074036)。

 [protobuf的简单使用](https://www.cnblogs.com/luoxn28/p/5303517.html)。可以定义一个结构体，然后用程序将结构体信息写入文本，另一个程序将文本读出来

###数据序列号和反序列化
以c++为例，序列化就是将C++对象转化为字节流（二进制串）的过程，反序列化是相反的过程
**为什么要序列化呢**，主要是因为两个进程要通信，可以发送各种数据类型（文字、图片、音频和视频），但这些数据都是通过字节流（二进制串）再网络上传输的。
**好处**，可以实现远程通信，可以实现数据持久化，将数据保存在磁盘上。

###usleep和sleep
**主要区别**：当延迟时间是秒的时候，尽量用sleep,是毫秒的时候，尽量用usleep,usleep的单位是毫秒，sleep是秒

###client基本流程
[echo-c++](https://blog.csdn.net/huntinux/article/details/81124091)

channel可以**被所有线程共用**，你不需要为每个线程创建独立的Channel，也不需要用锁互斥。不过Channel的创建和Init并不是线程安全的，请确保在Init成功后再被多线程访问，在没有线程访问后再析构。

一些RPC实现中有ClientManager的概念，包含了Client端的配置信息和资源管理。brpc不需要这些，以往在ClientManager中配置的线程数、长短连接等等要么被加入了brpc::ChannelOptions，要么可以通过gflags全局配置，这么做的好处：

1. 方便。你不需要在创建Channel时传入ClientManager，也不需要存储ClientManager。否则不少代码需要一层层地传递ClientManager，很麻烦。gflags使一些全局行为的配置更加简单。
2. 共用资源。比如server和channel可以共用后台线程。(bthread的工作线程)
3. 生命周期。析构ClientManager的过程很容易出错，现在由框架负责则不会有问题。

就像大部分类那样，Channel必须在**Init**之后才能使用，options为NULL时所有参数取默认值，如果你要使用非默认值，这么做就行了：
```c++
brpc::ChannelOptions options;  // 包含了默认值
options.xxx = yyy;
...
channel.Init(..., &options);
```
注意Channel不会修改options，Init结束后不会再访问options。所以options一般就像上面代码中那样放栈上。Channel.options()可以获得channel在使用的所有选项。

Init函数分为连接一台服务器和连接服务集群。

**连接一台服务器：**
```c++
// options为NULL时取默认值
int Init(EndPoint server_addr_and_port, const ChannelOptions* options);
int Init(const char* server_addr_and_port, const ChannelOptions* options);
int Init(const char* server_addr, int port, const ChannelOptions* options);
```
这类Init连接的服务器往往有固定的ip地址，不需要命名服务和负载均衡，创建起来相对轻量。但是**请勿频繁创建使用域名的Channel**。这需要查询dns，可能最多耗时10秒(查询DNS的默认超时)。重用它们。

合法的“server_addr_and_port”：
- 127.0.0.1:80
- www.foo.com:8765
- localhost:9000

不合法的"server_addr_and_port"：
- 127.0.0.1:90000     # 端口过大
- 10.39.2.300:8000   # 非法的ip

**连接服务集群：**
```c++
int Init(const char* naming_service_url,
         const char* load_balancer_name,
         const ChannelOptions* options);
```
这类Channel需要定期从`naming_service_url`指定的命名服务中获得服务器列表，并通过`load_balancer_name`指定的负载均衡算法选择出一台机器发送请求。

你**不应该**在每次请求前动态地创建此类（连接服务集群的）Channel。因为创建和析构此类Channel牵涉到较多的资源，比如在创建时得访问一次命名服务，否则便不知道有哪些服务器可选。由于Channel可被多个线程共用，一般也没有必要动态创建。

当`load_balancer_name`为NULL或空时，此Init等同于连接单台server的Init，`naming_service_url`应该是"ip:port"或"域名:port"。你可以通过这个Init函数统一Channel的初始化方式。比如你可以把`naming_service_url`和`load_balancer_name`放在配置文件中，要连接单台server时把`load_balancer_name`置空，要连接服务集群时则设置一个有效的算法名称。

####bthread
[bthread](https://github.com/brpc/brpc/tree/master/src/bthread)是brpc使用的M:N线程库，目的是在提高程序的并发度的同时，降低编码难度，并在核数日益增多的CPU上提供更

####done
done由框架创建，递给服务回调，包含了调用服务回调后的后续动作，包括检查response正确性，序列化，打包，发送等逻辑。

**不管成功失败，done->Run()必须在请求处理完成后被用户调用一次。**

为什么框架不自己调用done->Run()？这是为了允许用户把done保存下来，在服务回调之后的某事件发生时再调用，即实现异步.

强烈建议使用**ClosureGuard**确保done->Run()被调用，即在服务回调开头的那句：

```c++
brpc::ClosureGuard done_guard(done);
```

不管在中间还是末尾脱离服务回调，都会使done_guard析构，其中会调用done->Run()。这个机制称为[RAII](https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization)。没有这个的话你得在每次return前都加上done->Run()，**极易忘记**。

在异步Service中，退出服务回调时请求未处理完成，done->Run()不应被调用，done应被保存下来供以后调用，乍看起来，这里并不需要用ClosureGuard。但在实践中，异步Service照样会因各种原因跳出回调，如果不使用ClosureGuard，一些分支很可能会在return前忘记done->Run()，所以我们也建议在异步service中使用done_guard，与同步Service不同的是，为了避免正常脱离函数时done->Run()也被调用，你可以调用done_guard.release()来释放其中的done。

一般来说，同步Service和异步Service分别按如下代码处理done：

```c++
class MyFooService: public FooService  {
public:
    // 同步服务
    void SyncFoo(::google::protobuf::RpcController* cntl_base,
                 const ::example::EchoRequest* request,
                 ::example::EchoResponse* response,
                 ::google::protobuf::Closure* done) {
         brpc::ClosureGuard done_guard(done);
         ...
    }
 
    // 异步服务
    void AsyncFoo(::google::protobuf::RpcController* cntl_base,
                  const ::example::EchoRequest* request,
                  ::example::EchoResponse* response,
                  ::google::protobuf::Closure* done) {
         brpc::ClosureGuard done_guard(done);
         ...
         done_guard.release();
    }
};
```

ClosureGuard的接口如下：

```c++
// RAII: Call Run() of the closure on destruction.
class ClosureGuard {
public:
    ClosureGuard();
    // Constructed with a closure which will be Run() inside dtor.
    explicit ClosureGuard(google::protobuf::Closure* done);
    
    // Call Run() of internal closure if it's not NULL.
    ~ClosureGuard();
 
    // Call Run() of internal closure if it's not NULL and set it to `done'.
    void reset(google::protobuf::Closure* done);
 
    // Set internal closure to NULL and return the one before set.
    google::protobuf::Closure* release();
};
```
有些server以等待后端服务返回结果为主，且处理时间特别长，为了及时地释放出线程资源，更好的办法是把done注册到被等待事件的回调中，等到事件发生后再调用done->Run()。

异步service的最后一行一般是done_guard.release()以确保正常退出CallMethod时不会调用done->Run()。例子请看[example/session_data_and_thread_local](https://github.com/brpc/brpc/tree/master/example/session_data_and_thread_local/)。

Service和Channel都可以使用done来表达后续的操作，但它们是**完全不同**的，请勿混淆：

####start server服务

调用以下[Server](https://github.com/brpc/brpc/blob/master/src/brpc/server.h)的接口启动服务。

```c++
int Start(const char* ip_and_port_str, const ServerOptions* opt);
int Start(EndPoint ip_and_port, const ServerOptions* opt);
int Start(int port, const ServerOptions* opt);
int Start(const char *ip_str, PortRange port_range, const ServerOptions *opt);  // r32009后增加
```

"localhost:9000", "cq01-cos-dev00.cq01:8000", “127.0.0.1:7000"都是合法的`ip_and_port_str`。

`options`为NULL时所有参数取默认值，如果你要使用非默认值，这么做就行了：

```c++
brpc::ServerOptions options;  // 包含了默认值
options.xxx = yyy;
...
server.Start(..., &options);
```
