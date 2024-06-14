# udp聊天会话简易版

## 使用方法

1. 聊天会话的两台设备同时打开2个powershell窗口
2. 开启数据接收`.\Receive-ChatMessage.ps1 -LocalPort 11001`
3. 开启数据发送`.\Send-ChatMessage.ps1 -RemoteIPAddress 127.0.0.1 -RemotePort 11001`
4. 在数据发送里面发送需要传送的数据，即可。
