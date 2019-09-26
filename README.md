## flutter和原生混编的情况下管理路由以及参数传递

**目前只实现了Android侧，iOS的还在开发中，之后会把代码打包成plugin形式**
目前是基于` v1.5.4-hotfix.2`

#### 问题场景
当我们在flutter页面中想要打开一个新的flutter页面，有两种方式
1. 使用flutter的Navigator去push一个新页面
2. 调用原生方法重新打开一个新的容器(Activity,ViewController)

方式1的优点：
1. 不需要重新创建新的容器去承载新的FlutterView，也就是意味着不需要重新初始化新的engine，多页面中可以共享上下文
方式1的缺点：
1. 在Android侧由于有物理返回键的原因，当我们不做处理时，点击返回键时关闭当前容器
2. 在返回上一页时调用pop需要判断当前页面是否可以进行pop，不能pop的情况下则关闭当前容器

方式2的优点
1. 不需要处理返回键的问题，有返回动作(物理返回键、页面中的操作等)则关闭当前容器就好
方式2的缺点
1. 每次都需要重新创建容器、FlutterView以及engine,内存开销较大
2. 多个flutter页面中无法共享上下文



#### 解决的问题
1. 在flutter侧打开原生任意页面
2. 在原生打开flutter任意页面
3. 打开新页面时传递数据
4. 返回上一页面传递数据
5. 支持使用flutter的Navigator方式在同一个FlutterView(Activity,ViewController)中路由(跳转返回)

#### 思路
1. 在Android侧拦截物理返回键，交给flutter进行处理
2. 在flutter侧判断当前页面是否可以pop，如果可以pop则进行pop；否则调用原生方法关闭容器
3. 打开新的容器时通过Uri的方式，将路由及参数附加在Uri中，在原生侧进行解析(任意原生页面打开任意flutter页面)
4. 统一返回操作，返回动作都去触发bridge.pop方法，由它来进行`2`的处理方式
5. 返回参数，如果是可以pop，则放在pop方法中。如果无法pop，则调用关闭容器方法在原生侧返回给上个页面
6. 若上个页面是flutter，则调用flutter侧注册的`on_result`方法进行处理


#### 主要代码
1. MainActivity充当容器，并在其中初始化channel，处理`close`及`openOther`方法，并在`onActivityResult`中接收上一界面返回的数据传递给flutter
2. bridge.dart则是桥梁，打开新容器(非push方式)、返回动作处理都在这里

#### 使用方式
flutter侧：
1. 在每个页面的build方法中需要将当前的BuildContext注册到bridge中，用来判断当前页面是否可以pop
` Bridge.getInstance().registerBuildContext(context);`
2. 由于在Android端将`MainActivity`配置了过滤器，所有符合`router:flutter`的Uri都将转发到这里
3. 打开新的容器时通过`bridge.openNative`进行，在`bridge`中封装了构建Uri的方法`getOpenNativeUrl`
4. 返回动作都通过调用`bridge.pop`方法进行





