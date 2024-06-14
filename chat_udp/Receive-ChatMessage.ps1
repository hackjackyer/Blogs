param (
    [int]$LocalPort = 11000
)

# 创建一个新的 UdpClient 实例并绑定到指定的本地端口
$udpClient = New-Object System.Net.Sockets.UdpClient($LocalPort)

try {
    Write-Host "Listening for messages on port $LocalPort..."

    while ($true) {
        # 定义远程终结点
        $remoteEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, 0)

        # 接收数据（阻塞调用，直到数据包到达）
        $dataReceived = $udpClient.Receive([ref]$remoteEndPoint)

        # 将接收到的数据转换为字符串
        $message = [System.Text.Encoding]::UTF8.GetString($dataReceived)

        # 输出接收到的消息
        Write-Host "Received message from $($remoteEndPoint.Address.ToString()):$($remoteEndPoint.Port) - $message"
    }
} finally {
    # 关闭 UDP 客户端
    $udpClient.Close()
}
