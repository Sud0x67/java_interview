# Jar包中的同名类
## 现象
服务在部分pod中启动不起来，报类中某个字段不存在，而在另外一些pod中确实正常的。
## 原因
服务的jar包中存在两个包名类名都相同的class， JVM随机加载到了其中一个，而两个类的具体实现又不一样。
```java
// package com.example.test
class A{
    public static B b;
}

// package com.example.test
class A{
    public static shaded.B b;
}

```
虽然两个类中都有小b，但是第二个class中的b确实shaded之后的类型，引用shaded.B b = A.b 时 如果加载到的是第一个类便会报字段不存在的错误。


## 为什么会有同包名同类名的class出现
- jar的打包方式有关

普通jar包：

spring-boot jar包：

## 如何排查
```
sc -d -f className
```

arthas ： https://arthas.aliyun.com/doc/quick-start.html