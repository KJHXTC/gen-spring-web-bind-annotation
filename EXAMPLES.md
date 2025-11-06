# 使用示例

本文档展示如何使用 `gen-spring-web-bind-annotation.sh` 脚本。

## 示例 1: 使用默认配置

```bash
./gen-spring-web-bind-annotation.sh
```

输出:
```
==========================================
生成 spring-web-bind-annotation
==========================================
Spring Web Version: 6.1.13
Original GAV: org.springframework:spring-web:6.1.13
New GAV: com.custom.springframework:spring-web-bind-annotation:6.1.13
Output Directory: ./output
==========================================

Step 1: Downloading spring-web JAR...
Step 2: Extracting JAR...
Step 3: Filtering classes...
Step 4: Repackaging JAR...
Step 5: Generating POM...
Step 6: Copying to output directory...

==========================================
✓ Successfully generated!
==========================================
```

## 示例 2: 生成特定版本

生成 Spring Web 5.3.31 版本:

```bash
./gen-spring-web-bind-annotation.sh -v 5.3.31 -g com.mycompany.springframework -o ./my-output
```

## 示例 3: 安装到本地 Maven 仓库并在项目中使用

### 步骤 1: 生成文件

```bash
./gen-spring-web-bind-annotation.sh -v 5.3.31 -g com.company.springframework
```

### 步骤 2: 安装到本地 Maven 仓库

```bash
mvn install:install-file \
  -Dfile=./output/spring-web-bind-annotation-5.3.31.jar \
  -DpomFile=./output/spring-web-bind-annotation-5.3.31.pom
```

输出:
```
[INFO] Installing .../spring-web-bind-annotation-5.3.31.jar to ~/.m2/repository/...
[INFO] Installing .../spring-web-bind-annotation-5.3.31.pom to ~/.m2/repository/...
[INFO] BUILD SUCCESS
```

### 步骤 3: 在项目中使用

在 `pom.xml` 中添加依赖:

```xml
<dependency>
    <groupId>com.company.springframework</groupId>
    <artifactId>spring-web-bind-annotation</artifactId>
    <version>5.3.31</version>
</dependency>
```

### 步骤 4: 在代码中使用注解

```java
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class MyController {
    
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        // ...
    }
    
    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        // ...
    }
}
```

## 示例 4: 批量生成多个版本

创建一个批处理脚本来生成多个版本:

```bash
#!/bin/bash

versions=("5.3.31" "6.0.23" "6.1.13")
group_id="com.mycompany.springframework"

for version in "${versions[@]}"; do
    echo "Generating version ${version}..."
    ./gen-spring-web-bind-annotation.sh -v ${version} -g ${group_id} -o ./output-${version}
    
    # 安装到本地仓库
    mvn install:install-file \
        -Dfile=./output-${version}/spring-web-bind-annotation-${version}.jar \
        -DpomFile=./output-${version}/spring-web-bind-annotation-${version}.pom
done

echo "All versions generated and installed!"
```

## 文件对比

### 原始 spring-web JAR 大小
- spring-web-5.3.31.jar: ~1.5 MB

### 生成的 spring-web-bind-annotation JAR 大小  
- spring-web-bind-annotation-5.3.31.jar: ~26 KB

**大小减少约 98%！**

## 依赖对比

### 原始 spring-web POM
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-beans</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
    </dependency>
    <!-- 还有更多依赖... -->
</dependencies>
```

### 生成的 spring-web-bind-annotation POM
```xml
<!-- No dependencies - standalone annotations only -->
```

**零依赖！**

## 常见问题

### Q: 生成的 JAR 可以在运行时使用吗？

A: 这个 JAR 仅包含注解类（Java Annotation），注解只在编译时使用。如果你的代码需要 Spring 的运行时功能，仍然需要引入完整的 Spring 框架。这个工具适合只需要使用 Spring Web 注解进行代码标注的场景。

### Q: 支持哪些 Spring Web 版本？

A: 理论上支持所有 Spring Web 版本。建议使用 5.x 或 6.x 系列的版本。

### Q: 可以发布到 Maven 中央仓库吗？

A: 可以，但需要遵循 Maven 中央仓库的发布规范，并且需要有合适的 groupId（通常是你控制的域名）。

### Q: 生成的包含哪些注解？

A: 包含 `org.springframework.web.bind.annotation` 包下的所有注解，包括但不限于:
- @RequestMapping 及其变体 (@GetMapping, @PostMapping 等)
- @RequestParam, @PathVariable, @RequestBody
- @Controller, @RestController
- @ControllerAdvice, @ExceptionHandler
- 等等...
