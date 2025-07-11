# IPTV IP 搜索与测速综合工具

## 功能说明

本工具合并了原来的 `update_ip.sh` 和 `speedtest_from_list.sh` 脚本功能，用 Python 重新实现，主要特性：

1. **IP 搜索**: 从 FOFA 和 Quake360 搜索 IPTV 相关 IP
2. **代理支持**: 支持随机代理访问，避免 IP 被封
3. **端口测试**: 并发测试 IP 端口连通性
4. **流媒体测速**: 使用类似 `all-z-new.py` 的逻辑进行 M3U8/TS 文件下载测速
5. **结果生成**: 自动生成测速结果和合并模板文件

## 文件说明

- `speedtest_integrated.py`: 完整版本，需要安装 requests 库
- `speedtest_simple.py`: 简化版本，仅使用 Python 标准库
- `proxy.txt`: 代理服务器列表文件
- `requirements.txt`: Python 依赖包列表

## 安装依赖

### 方式一：使用完整版 (推荐)
```bash
pip install -r requirements.txt
```

### 方式二：使用简化版 (无需安装额外依赖)
直接使用 `speedtest_simple.py`，仅需 Python 3.6+

## 配置文件

### 1. 代理文件 (proxy.txt)
每行一个代理，支持格式：
```
127.0.0.1:8080
192.168.1.100:3128
socks5://127.0.0.1:1080
http://proxy.example.com:8080
```

### 2. 省份配置文件
需要存在对应的省份配置文件，如：
- `Telecom_province_list.txt`
- `Unicom_province_list.txt` 
- `Mobile_province_list.txt`

格式：`省份名 城市名 流地址`

### 3. 模板文件
可选的模板文件，位于 `template/{ISP}/template_{城市}.txt`

## 使用方法

### 基本用法
```bash
# 使用完整版
python speedtest_integrated.py <省市> <运营商>

# 使用简化版
python speedtest_simple.py <省市> <运营商>
```

### 示例
```bash
python speedtest_simple.py Shanghai Telecom
python speedtest_simple.py Beijing Unicom
python speedtest_simple.py Guangzhou Mobile
```

## 输出文件

执行完成后会生成以下文件：

1. `sum/{ISP}/{城市}_sum.ip` - 所有可访问的 IP 列表
2. `sum/{ISP}/{城市}_uniq.ip` - 去重后的 IP 列表
3. `sum/tmp/{ISP}_result_fofa_{城市}.txt` - 测速结果 (>6MB/s)
4. `sum/{ISP}/{城市}.txt` - 合并模板后的最终结果
5. `{ISP}_speedtest_{城市}.log` - 详细测速日志

## 工作流程

1. **搜索阶段**: 
   - 从 FOFA 搜索 IP (使用代理，自动重试)
   - 从 Quake360 搜索 IP
   - 合并去重

2. **筛选阶段**:
   - 并发测试端口连通性
   - 过滤可访问的 IP

3. **测速阶段**:
   - 下载 M3U8 播放列表
   - 下载 TS 文件片段计算速度
   - 记录测速结果

4. **结果阶段**:
   - 筛选速度 >6MB/s 的 IP
   - 按速度排序
   - 生成结果文件
   - 合并模板文件

## 特性优势

### 相比原始 Shell 脚本的改进：

1. **代理支持**: 自动随机选择代理，避免 IP 被封
2. **错误处理**: 完善的异常处理和重试机制
3. **并发处理**: 并发测试端口和测速，提高效率
4. **测速改进**: 
   - 使用 HTTP 下载 TS 文件替代 ffmpeg
   - 避免 ffmpeg 超时和状态判断问题
   - 更稳定的网络测试

5. **跨平台**: 纯 Python 实现，Windows/Linux 通用
6. **易于维护**: 代码结构清晰，易于修改和扩展

## 注意事项

1. **代理配置**: 建议配置多个有效代理以提高成功率
2. **网络环境**: 确保网络连接稳定
3. **配置文件**: 确保省份配置文件存在且格式正确
4. **权限问题**: 某些操作系统可能需要管理员权限
5. **防火墙**: 确保防火墙允许网络连接

## 故障排除

### 常见问题：

1. **FOFA 访问失败**: 检查代理配置或网络连接
2. **找不到配置文件**: 确保 `{ISP}_province_list.txt` 存在
3. **没有找到 IP**: 可能是搜索条件过于严格或网络问题
4. **测速失败**: 检查目标 IP 的流地址是否正确

### 调试方法：

- 查看控制台输出了解详细进度
- 检查生成的日志文件
- 确认代理服务器可用性
- 验证省份和运营商参数正确性
