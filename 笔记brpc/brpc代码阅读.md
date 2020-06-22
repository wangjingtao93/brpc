
# 1. client
Client指发起请求的一端，在brpc中没有对应的实体，取而代之的是[brpc::Channel](https://github.com/brpc/brpc/blob/master/src/brpc/channel.h)，它代表和一台或一组服务器的交互通道，Client和Channel在角色上的差别在实践中并不重要，可以把Channel视作Client。
## 1.1. 基本执行过程
1. 在主程序外围定义命令行参数（全局）。包括attachment、protocol、connection_type、server、The algorithm for load balancin（负载均衡算法）、timeout_ms、max_retry（重连接次数）、interval_ms,具体的定义方式见代码。
2. **解析gflags**，gflags是google开源的用于处理命令行参数的项目，具体内容见[gflags库的完全使用](https://blog.csdn.net/u012414189/article/details/84256667)。一般再main函数的首行。<font color = 'red'>同步、异步、多线程这部分语法（过程）是相同的</font>
3. **与service建立通道channel，并初始化**，通道可以由程序中所用的线程共享。
   - 初始化通道，null代表使用默认参数
   - 多线程程序中增加了一条解析即：
   `if (FLAGS_enable_ssl) {
        options.mutable_ssl_options();
    }`,其他的三种的语法（过程）一样。
    ```C++
    //建立channel
    brpc::Channel channel;

    // channel初始化，NULL代表使用默认参数
    brpc::ChannelOptions options;
    options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.timeout_ms = FLAGS_timeout_ms/*milliseconds*/;
    options.max_retry = FLAGS_max_retry;
    if (channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options) != 0) {
        LOG(ERROR) << "Fail to initialize channel";
        return -1;
    }

    ```
4. **构造stub服务**，通常情况下echo不是直接调用一个通道，而是构造一个stub Service来封装通道，stub和通道channel一样可以被所有线程共享， <font color = 'red'>这一点同步和异步和多线程是相同的</font>，但是多线程会封装在一个send函数里，起多个线程。构造stub代码如下：
```C++
   example::EchoService_Stub stub(&channel);
```
5. **发送请求**，send request。这部分同步、异步和多线程诸多不同，在下面进行详细研究。接下来先看基本echo的send request的流程
  - 建立变量（对象）request、response、cntl，**注意**，同步的程序是将变量放在栈上（异步的程序是放在堆上），代码如下：
```C++
  example::EchoRequest request;
  example::EchoResponse response;
  brpc::Controller cntl;
```
  - 发送message,即`request.set_message("hello world");`
  - 计数，在循环外围设置变量log_id，`cntl.set_log_id(log_id ++);`
  - 设置attachement(附件)，直接和网络建立连接，无需序列化成protobuf格式，即`cntl.request_attachment().append(FLAGS_attachment);`，默认的是空的即“”；可以通过命令行设置attachment参数。
  - 同步程序里stub.Echo()的“dong”（最后一个参数）时NULL，即`stub.Echo(&cntl, &request, &response, NULL);`所以这个函数将等待响应返回（response back）,或者发生错误，包括超时（timeout）。这一点 <font color = 'red'>同步和多线程时一样的，和异步程序是不同的。</font>
  - 打印客户端和服务端的交互信息

## 1.2. 同步和异步比较

1. 同步时接收响应（response）,将变量放在堆上是安全的，但是异步是将对象（变量）放在堆上的。因为异步时，我们正在发送异步RPC (' done'不为空)，所以在调用'done'之前，这些对象必须保持有效。同步时对象是（变量）声明出来的，异步时对象是new出来的。
  - 同步代码
```C++
   example::EchoRequest request;
   example::EchoResponse response;
   brpc::Controller cntl;
```
  - 异步代码
```C++
   example::EchoResponse* response = new example::EchoResponse();
   brpc::Controller* cntl = new brpc::Controller
```
 - 异步的程序里，注意，不必创建新的request，request可以被修改，或者在stub之后销毁。和同步一样，异步也只需要执行`example::EchoRequest request;`

2. 同步的attachment(附件)可以直接连接到网络，而不是序列化成protobuf消息。异步时当判定条件为`FLAGS_send_attachment`,attachment的处理和同步相同，即：`cntl->request_attachment().append("foo");`，**否则异步的处理方式是**：使用protobuf的工具“NewCallback”，创建一个封闭的对象（closure object）,closure object可以回调"HandleEchoResponse"。并且closure object被调用一次之后会删除自己。**代码是**:
```C++
  google::protobuf::Closure* done = brpc::NewCallback(
          &HandleEchoResponse, cntl, response);
```

3. 同步程序，`stub.Echo()`的“dong”（最后一个参数）是NULL，所以这个函数将等待响应返回（response back）,或者发生错误，包括超时（timeout）。**但是异步**是在回调中取结果。注意下面红色部分的参数。
   - 同步，stub.Echo(<font color ='red'>&cntl</font>, &request, <font color ='red'>&response</font>, <font color ='red'>NULL</font>)
   - 异步，  stub.Echo(<font color ='red'>cntl</font>, &request, <font color ='red'>response</font>,<font color ='red'> done</font>);

### 1.2.1. 异步的回调函数`HandleEchoResponse`
1. 在主函数中，使用protobuf的工具“NewCallback”，创建一个封闭的对象（closure object）的过程中会调用。
2. 函数两个入参即`brpc::Controller* cntl,
        example::EchoResponse* response`，函数具体的流程：
   - **unique_ptr**，确保return前删除cntl/response。
   - 打印交互信息。
3. **总的来说**，brpc的异步调用指的是和同步调用相比，在进行rpc调用之后，此时callmethod就结束了，进行继续执行后续的动作，等到rpc返回之后，会调用事先注册的回调函数，回调函数进行后面rpc返回之后的操作。 在主函数中调用        `google::protobuf::Closure* done = brpc::NewCallback(
            &HandleEchoResponse, cntl, response);`,调用之后在执行stub.Echo函数。


## 1.3. 同步和多线程
echo同步和异步时连接的是一台服务器。**多线程连接的是服务器集群**，会有服务器列表。
  - 连接一台服务器
```C++
int Init(EndPoint server_addr_and_port, const ChannelOptions* options);
int Init(const char* server_addr_and_port, const ChannelOptions* options);
int Init(const char* server_addr, int port, const ChannelOptions* options);
```

  - 连接服务器集群
  ```c++
  int Init(const char* naming_service_url,
           const char* load_balancer_name,
           const ChannelOptions* options);
  ```
  这类Channel需要定期从`naming_service_url`指定的命名服务中获得服务器列表，并通过`load_balancer_name`指定的负载均衡算法选择出一台机器发送请求。
1.多线程初始化channel时，除了解析命令行参数protocol、connection_type、timeout_ms、max_retry，还需要解析enable_ssl、connect_timeout_ms，除了server，还需要判断attachment_size、request_size、 dummy_port是否合法、正确。

2.多线程，bthread,pthread,[bthread](https://github.com/brpc/brpc/tree/master/src/bthread)是brpc使用的M:N线程库，目的是在提高程序的并发度的同时，降低编码难度，并在核数日益增多的CPU上提供更好。初始化channel后，多线程程序会创建多个线程线程`pthread_create`，调用send函数完成request和response(请求和响应)

### 1.3.1. 多线程的send函数

1. 通常情况下echo不是直接调用一个通道，而是构造一个stub Service来封装通道，stub和通道channel一样可以被所有线程共享， <font color = 'red'>这一点同步和异步和多线程都是一样的</font>，但是多线程会封装在一个send函数里，起多个线程。代码如下：
```C++
   example::EchoService_Stub stub(&channel);
```
2. 和同步相同，多线程也是将对象（变量）放在堆上，这是安全可行的。
3. 在多线程send程序中，如果连不上服务器，这里时使用`bthread_usleep(50000)`让线程休眠。这里是为了防止线程旋转（spinnig）过快，但是在真正的业务生产服务器中，应该使其继续执行业务逻辑，而不是让其休眠。
4. 异步程序，定义了为request全局变量`std::string g_request;
std::string g_attachment;`
不再直接是"hello world".

# 2. server

## 2.1. 基本流程
一个server得基本执行流程：
1. 实现的EchoService基类即：example::EchoService,在主函数里，首先就需要实例化一个service，即`example::EchoServiceImpl echo_service_impl;`。
2. 同样是先解析gflags。
3. 建立一个service,执行'brpc::Server server;'
4. 实例化一个service,执行`example::EchoServiceImpl echo_service_impl;`。
5. 将service添加到服务端server，Service在插入[brpc.Server](https://github.com/brpc/brpc/blob/master/src/brpc/server.h)后才可能提供服务。代码如下：
```C++
 if (server.AddService(&echo_service_impl,
                      brpc::SERVER_DOESNT_OWN_SERVICE) != 0) {
    LOG(ERROR) << "Fail to add service";
    return -1;
}
```
6. 启动服务端，代码如下
```C++
brpc::ServerOptions options;
options.idle_timeout_sec = FLAGS_idle_timeout_s;
if (server.Start(FLAGS_port, &options) != 0) {
    LOG(ERROR) << "Fail to start EchoServer";
    return -1;
}
```

**example::EchoService**的实现

1. 他可以实现像RAII样式调用done->Run()，如果需要异步处理请求，则传递`done_guard.release()`。关于ClousureGuard的接口（暂未做研究）
2. 打印日志，帮助理解客户端与服务端之间的交换
3. 填充回复消息`        // Fill response.
        response->set_message(request->message());`,消息内容可以修改，这里是填充从客户端发来的，例如：“hello world”。
4. response可以通过控制器来压缩，但是代价可能很昂贵。通过函数`cntl->set_response_compress_type(brpc::COMPRESS_TYPE_GZIP)`来实现
5. 设置attachment,同样是直接和网络建立连接，不需要序列化成protobuf消息。

## 2.2. 同步和异步比较
1. 同步和异步的service程序，首先都是解析gflags，建立一个server( brpc::Server server;),实例化一个service,将service加入server，然后start server。
2. done由框架创建，递给服务回调，包含了调用服务回调后的后续动作，包括检查response正确性，序列化，打包，发送等逻辑。框架不自己调用done->Run()，用户可以把done保存下来，在服务回调之后的某事件发生时再调用，实现异步
3. 使用**ClosureGuard**确保done->Run()被调用，即在服务回调开头的那句：

```c++
brpc::ClosureGuard done_guard(done);
```
3. 异步时需要传递  `done_guard.release();`

4. 异步时done->Run()在Service回调之外被调用。


## 2.3. 同步和多线程的比较
1. 多线程定义了`max_concurrency`即并行处理request的限制，和`internal_port`即构建服务的端口限制，在start server时会用到这个两个参数。
```C++
DEFINE_int32(max_concurrency, 0, "Limit of request processing in parallel");
DEFINE_int32(internal_port, -1, "Only allow builtin services at this port");
```

2. 多线程创建变量string型变量help_str, 解析gflags时，增加`if (FLAGS_h)`判断。
```C++
std::string help_str = "dummy help infomation";
GFLAGS_NS::SetUsageMessage(help_str);
```

3. 启动server服务时，二者的不同：
    - 修改了option的诸多参数，包括`mutable_ssl_options()->default_cert.certificate`、`mutable_ssl_options()->default_cert.private_key`、`max_concurrency`、`.internal_port`
    - 注意options为NULL时所有参数取默认值
