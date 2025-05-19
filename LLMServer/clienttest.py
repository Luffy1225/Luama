import socket
import base64


def send_text(sock, message):
    sock.sendall(message.encode("utf-8"))


def send_image_base64(sock, image_path):
    with open(image_path, "rb") as img_file:
        base64_data = base64.b64encode(img_file.read()).decode("utf-8")
        sock.sendall(base64_data.encode("utf-8"))


def main():
    host = "192.168.56.1"  # 伺服器 IP
    port = 50007  # 伺服器 port

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((host, port))
        print("✅ 已連接伺服器")

        while True:
            cmd = input("請輸入文字訊息或 '/img 路徑' 傳送圖片，或輸入 /exit 離開：\n")
            if cmd == "/exit":
                break
            elif cmd.startswith("/img "):
                image_path = cmd[5:].strip()
                send_image_base64(sock, image_path)
            else:
                send_text(sock, cmd)

            # 接收回覆
            data = sock.recv(8192)
            print("📥 AI 回覆：", data.decode("utf-8"))


if __name__ == "__main__":
    main()
