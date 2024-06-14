param (
    [string]$RemoteIPAddress = "127.0.0.1",
    [int]$RemotePort = 11000
)

# 创建一个新的 UdpClient 实例
$udpClient = New-Object System.Net.Sockets.UdpClient

try {
    while ($true) {
        # 读取用户输入的消息
        $message = Read-Host "Enter message"

        # 将消息转换为字节数组
        $data = [System.Text.Encoding]::UTF8.GetBytes($message)

        # 创建远程终结点
        $remoteEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse($RemoteIPAddress), $RemotePort)

        # 发送消息
        $udpClient.Send($data, $data.Length, $remoteEndPoint)

        Write-Host "Message sent to ${RemoteIPAddress}:$RemotePort"
    }
} finally {
    # 关闭 UDP 客户端
    $udpClient.Close()
}
