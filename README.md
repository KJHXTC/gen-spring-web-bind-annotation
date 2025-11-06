# gen-spring-web-bind-annotation

生成 spring-web-bind-annotation 的工具脚本。

## 从 GitHub Packages 使用（推荐）

本仓库提供了自动构建的 Maven 包，发布在 GitHub Packages 上。当创建新的 tag 时，会自动构建并发布对应版本的包。

### 配置 Maven

在项目的 `pom.xml` 中添加仓库配置：

```xml
<repositories>
    <repository>
        <id>github</id>
        <url>https://maven.pkg.github.com/KJHXTC/gen-spring-web-bind-annotation</url>
    </repository>
</repositories>
```

在 `~/.m2/settings.xml` 中配置 GitHub 认证（需要 GitHub Personal Access Token）：

```xml
<servers>
    <server>
        <id>github</id>
        <username>YOUR_GITHUB_USERNAME</username>
        <password>YOUR_GITHUB_TOKEN</password>
    </server>
</servers>
```

### 添加依赖

在项目的 `pom.xml` 中添加：

```xml
<dependency>
    <groupId>com.kjhxtc.springframework</groupId>
    <artifactId>spring-web-bind-annotation</artifactId>
    <version>5.3.31</version>
</dependency>
```

版本号对应 Spring Web 的版本号。

## 快速开始（本地构建）

```bash
# 1. 克隆仓库（如果还没有）
git clone https://github.com/KJHXTC/gen-spring-web-bind-annotation.git
cd gen-spring-web-bind-annotation

# 2. 给脚本添加执行权限
chmod +x gen-spring-web-bind-annotation.sh

# 3. 运行脚本生成 JAR 和 POM
./gen-spring-web-bind-annotation.sh -v 5.3.31 -g com.mycompany.springframework

# 4. 安装到本地 Maven 仓库
mvn install:install-file \
  -Dfile=./output/spring-web-bind-annotation-5.3.31.jar \
  -DpomFile=./output/spring-web-bind-annotation-5.3.31.pom

# 5. 在项目的 pom.xml 中使用
# <dependency>
#   <groupId>com.mycompany.springframework</groupId>
#   <artifactId>spring-web-bind-annotation</artifactId>
#   <version>5.3.31</version>
# </dependency>
```

## 功能说明

该脚本从 Maven 中央仓库下载 `org.springframework:spring-web` 包，提取其中的 `org/springframework/web/bind/annotation` 包，删除其他所有类和包，然后重新打包生成一个精简版的 JAR 文件和对应的 POM 文件。

这样可以避免引入整个 spring-web 的所有依赖，只使用常用的注解类，减少项目的依赖体积。

## 使用方法

### 基本用法

```bash
./gen-spring-web-bind-annotation.sh
```

使用默认配置：
- Spring Web 版本: 6.1.13
- 新的 groupId: com.custom.springframework
- 输出目录: ./output

### 自定义参数

```bash
./gen-spring-web-bind-annotation.sh -v 5.3.31 -g com.mycompany.springframework -o ./dist
```

### 参数说明

- `-v VERSION`: Spring Web 版本号（例如: 5.3.31, 6.1.13）
- `-g GROUP_ID`: 新的 Maven groupId（例如: com.mycompany.springframework）
- `-o OUTPUT_DIR`: 输出目录路径
- `-h`: 显示帮助信息

## 输出说明

脚本会生成两个文件：

1. **JAR 文件**: `spring-web-bind-annotation-{version}.jar`
   - 仅包含 `org/springframework/web/bind/annotation` 包下的注解类
   - 文件大小约为原始 spring-web.jar 的 1/20

2. **POM 文件**: `spring-web-bind-annotation-{version}.pom`
   - groupId: 修改为指定的自定义 groupId
   - artifactId: 固定为 `spring-web-bind-annotation`
   - version: 保持与原始 spring-web 相同
   - dependencies: 无依赖（已删除所有依赖）

## 安装到本地 Maven 仓库

生成文件后，可以使用以下命令安装到本地 Maven 仓库：

```bash
mvn install:install-file \
  -Dfile=./output/spring-web-bind-annotation-5.3.31.jar \
  -DpomFile=./output/spring-web-bind-annotation-5.3.31.pom
```

## 在项目中使用

安装到本地 Maven 仓库后，在项目的 `pom.xml` 中添加依赖：

```xml
<dependency>
    <groupId>com.custom.springframework</groupId>
    <artifactId>spring-web-bind-annotation</artifactId>
    <version>5.3.31</version>
</dependency>
```

## 包含的注解类

生成的 JAR 包含以下常用的 Spring Web 注解：

- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@DeleteMapping`
- `@PatchMapping`
- `@RequestParam`
- `@PathVariable`
- `@RequestBody`
- `@ResponseBody`
- `@RestController`
- `@Controller`
- `@ControllerAdvice`
- `@ExceptionHandler`
- `@InitBinder`
- `@ModelAttribute`
- `@SessionAttribute`
- `@RequestAttribute`
- `@CookieValue`
- `@CrossOrigin`
- `@MatrixVariable`
- 等等...

## 系统要求

- Java 8 或更高版本
- Maven 3.x
- Bash shell
- jar 命令行工具（通常随 JDK 安装）

## 示例

### 生成 Spring Web 5.3.31 版本

```bash
./gen-spring-web-bind-annotation.sh -v 5.3.31 -g com.example.springframework
```

### 生成 Spring Web 6.1.13 版本

```bash
./gen-spring-web-bind-annotation.sh -v 6.1.13 -g com.example.springframework
```

### 输出到指定目录

```bash
./gen-spring-web-bind-annotation.sh -v 5.3.31 -o /path/to/output
```

## 注意事项

1. 脚本会自动创建临时工作目录，完成后自动清理
2. 确保有网络连接以便从 Maven 中央仓库下载依赖
3. 首次运行可能需要较长时间，因为需要下载 Maven 插件
4. 生成的 JAR 文件仅包含注解类，不包含 Spring Web 的其他功能

## CI/CD 自动构建

本仓库配置了 GitHub Actions，可以自动构建和发布包到 GitHub Packages。

### 触发自动构建

创建一个 git tag 即可触发自动构建和发布：

```bash
# 例如，发布 Spring Web 5.3.31 版本
git tag 5.3.31
git push origin 5.3.31

# 或者使用 v 前缀
git tag v6.1.13
git push origin v6.1.13
```

### 构建过程

当推送 tag 时，GitHub Actions 会自动：

1. 提取 tag 名称作为版本号（自动去除 `v` 前缀）
2. 运行 `gen-spring-web-bind-annotation.sh` 脚本生成 JAR 和 POM
3. 使用固定的 `groupId: com.kjhxtc.springframework`
4. 将构建的包部署到 GitHub Packages Maven 仓库
5. 上传构建产物（保留 90 天）

### 查看构建结果

- 构建状态：在仓库的 Actions 标签页查看
- Maven 包：在仓库的 Packages 标签页查看已发布的版本

## License

Apache License 2.0 - 遵循原始 Spring Framework 的许可协议
